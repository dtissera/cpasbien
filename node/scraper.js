var fs = require("fs");
var util = require('util');
var mkdirp = require("mkdirp");
var cheerio = require("cheerio");
var request = require("request");
var rimraf = require("rimraf");
var _ = require("underscore");
var dao = require("./dao");
var when = require('when');
var TorrentInfo = require("./torrentinfo");
var TorrentPageInfo = require("./torrentpageinfo");

// var cmd = require("./cmd");
var tools = require('./tools');
var syno = require('./syno');
var config = require('./config');

var rootUrl = "http://www.cpasbien.pw";

var Scraper = function() {
	rimraf.sync("work");
	rimraf.sync("torrent");

	mkdirp.sync("work");
	// mkdirp.sync("torrent");
}

/**
 * HTTP behavior
 */
Scraper.prototype.postSearch = function(title) {
	var self = this;

	var options = {
		url: rootUrl+"/recherche/",
		method: "POST",
		headers: {
			//'Referer': referer,
			//'Host': host,
			//'origin': origin,
			'User-Agent': config.userAgent,
			'Content-Type': 'application/x-www-form-urlencoded'
		},
		form: {
			champ_recherche: title
		},
		followAllRedirects: true
	};

	console.log("Search: "+title);
	console.log("POST: "+options.url);

	var promise = when.promise(function(resolve, reject) {
		//request.debug = true;
		request(options, function (error, response, body) {
			if (!error) {
				if (response.statusCode == 200) {
					resolve({url: response.request.uri.href, body: body});
					return;
				}
			}
			reject(new Error(tools.extractHttpError(error, response)));
		}).pipe(fs.createWriteStream('work/search.html'));	
	});
	return promise;
}

/*
 * Utils
 */
Scraper.prototype.fail = function(err) {
	console.log("ERROR: "+err);
}

Scraper.prototype.urlToFileName = function(url) {
	var splited = url.split("/");
	if (splited.length == 0) {
		console.log ("aborted !")
		return
	}
	return splited[splited.length-1]
}

/*
 * Logic behavior
 */
Scraper.prototype.updateItemWithParsedData = function(searchInfo, parsedObject) {
	searchInfo.description = parsedObject.description;
	searchInfo.paginationUrls = parsedObject.paginationUrls;

	// Propagate enabled
	for (j = 0, lenj = parsedObject.torrentInfos.length; j < lenj; j++) {
		var tiParsed = parsedObject.torrentInfos[j];

		var founded = false
		for (i = 0, leni = searchInfo.torrentInfos.length; i < leni; i++) {
			var ti = searchInfo.torrentInfos[i];

			if (ti.name == tiParsed.name) {
				founded = true;
				tiParsed.enabled = ti.enabled;
				if (ti.torrentUrl) {
					tiParsed.torrentUrl = ti.torrentUrl;
				}
				break;
			}

		}

		if (!founded) {
			console.log(" + "+tiParsed.name);
			tiParsed.enabled = true;
		}
	}

	searchInfo.torrentInfos = parsedObject.torrentInfos;
	searchInfo.reorderByDate();
}

Scraper.prototype.parseSearchContent = function(content) {
	var self = this
	var $ = cheerio.load(content);

	var res = {
		description: "",
		paginationUrls: [],
		torrentInfos:[]
	}
	$("#titre").filter(function() {
		var data = $(this);

		res.description = data.text()
	});

	$("#gauche").find(".titre").each(function(i, element) {
		var data = $(this);

		var torrentPageUrl = {
			title: data.text(),
			url: data.attr('href')
		}

		// new logic
		var ti = new TorrentInfo();
		ti.name = data.text();
		ti.pageUrl = data.attr('href');
		ti.extraInfo = data.attr('title');
		ti.fileSize = data.parent().find(".poid").text();
		ti.parse();

		res.torrentInfos.push(ti);
	});
	
	return res;
}

Scraper.prototype.parseSearchPaginationContent = function(content) {
	var self = this
	var $ = cheerio.load(content);

	var pageUrl = [];
	var promiseArray = [];

	var pagination = $("#pagination").find("a");
	pagination.each(function(i, element) {
		var data = $(this);
		var url = data.attr('href');
		if (!_.contains(pageUrl, url)) {
			pageUrl.push(url);
			console.log("PAGES: "+url);

			var options = {
				url: url,
				method: 'GET',
				headers: {
					'User-Agent': config.userAgent
				}
			};
			var promisePage = when.promise(function(resolve, reject) {
				request(options, function (error, response, body){
					if (!error && response.statusCode == 200) {
						resolve({url: options.url, body: body});
					}
					else {
						var err = tools.extractHttpError(error, response);
						reject(new Error(err));
					}
				}).pipe(fs.createWriteStream("work/search-"+(i+1)+".html"));
			});
			promiseArray.push(promisePage);
		}
	});
	var promiseResult = when.all(promiseArray);
	if (pagination.length === 0) {
		promiseResult = when.resolve();
	}
	return promiseResult
}

Scraper.prototype.parseSearch = function(content) {
	var self = this
	var promise = when.promise(function(resolve, reject) {
		var jsonContent = self.parseSearchContent(content);

		var p = self.parseSearchPaginationContent(content).then(function(array) {
			if (array) {
				for (i = 0, len = array.length; i < len; i++) {
					var arrayItem = array[i];
					if (arrayItem) {
						var item = self.parseSearchContent(arrayItem.body);
						jsonContent.torrentInfos = jsonContent.torrentInfos.concat(item.torrentInfos);
						jsonContent.paginationUrls.push(arrayItem.url);
					}
				}
			}
			resolve(jsonContent);
		}, 
		function(err) {
			reject(new Error(err));
		});
	});
	return promise;
}

Scraper.prototype.downloadTorrentPageAndExtractTorrentUrl = function(url, tag) {
	var self = this

	var promise = when.promise(function(resolve, reject) {
		var fname = "work/"+self.urlToFileName(url);

		var options = {
			url: url,
			method: 'GET',
			headers: {
				'User-Agent': config.userAgent
			}
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var $ = cheerio.load(body);
				var torrentUrl = undefined;
				var torrentFilename = undefined;
				$("#telecharger").filter(function() {
					var data = $(this);
					torrentUrl = rootUrl+data.attr('href');
					// torrentFilename = "torrent/"+self.urlToFileName(torrentUrl);
				});
				if (torrentUrl) {
					var tpi = new TorrentPageInfo(options.url, torrentUrl, tag);
					resolve(tpi);
				}
				else {
					reject(new Error("cannot find torrent url"));
				}
			}
			else {
				var err = tools.extractHttpError(error, response);
				reject(new Error(err));
			}
		}).pipe(fs.createWriteStream(fname));
	});
	return promise;
}

Scraper.prototype.refreshSearch = function(searchInfo) {
	var self = this

	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}
		self.postSearch(searchInfo.words).then(
			function(content) {
				self.parseSearch(content.body).then(
					function(parsedObject) {
						// Insert search url first
						parsedObject.paginationUrls.splice(0, 0, content.url);

						self.updateItemWithParsedData(searchInfo, parsedObject);

						// searchInfo contains new torrentInfo enabled with null torrentUrl
						// we need to resolve them
						var promiseArray = [when.resolve(null)];
						searchInfo.torrentInfosIterator(function(index, torrentInfo) {
							if (torrentInfo.enabled && !torrentInfo.torrentUrl) {
								promiseArray.push(
									self.downloadTorrentPageAndExtractTorrentUrl(torrentInfo.pageUrl, torrentInfo.order)
								);
							}
						});

						when.all(promiseArray).then(
							function(result) {
								// result -> array of TorrentPageInfo
								result.forEach(function(tpi) {
									// tpi -> TorrentPageInfo or null (if autoresolved)
									if (tpi) {
										searchInfo.updateTorrentInfoFromTorrentPageInfo(tpi);
									};
								});

								dao.updateItem(searchInfo).then(
									function(result) {
										resolve(searchInfo);
									},
									errorFct
								);

							},
							errorFct
						);

					},
					errorFct
				);
			},
			errorFct
		);
	});

	return promise;
}

exports = module.exports = new Scraper();

