var util = require('util');
var when = require('when');
var dao = require("./dao");
var scraper = require("./scraper");
var SearchInfo = require("./searchinfo");
var syno = require("./syno");
var tools = require("./tools");
var TorrentPageInfo = require("./torrentpageinfo");
//console.log(util.inspect(_, {showHidden: true, depth: null}));

var Api = function() {
}

Api.prototype.searchAll = function() {
	var self = this;
	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}

		dao.findAll().then(
			function(docs) {
				var res = [];
				docs.forEach(function(item) {
					res.push(item.toApi(true));
				});

				resolve(res);
			},
			errorFct
		);
	});

	return promise;
}

Api.prototype.searchCreate = function(title) {
	var self = this

	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}

		var t = (typeof(title) === "string") ? title.trim() : ""
		if (t.length === 0) {
			errorFct("empty search !");
			return;
		}

		dao.createEmptyItem(t).then(
			function(item) {
				scraper.refreshSearch(item).then(
					function(newItem) {
						resolve(newItem.toApi());
					},
					errorFct
				);
			},
			errorFct
		);
	});
	return promise;
}

Api.prototype.searchUpdate = function(id) {
	var self = this

	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}

		var t = (typeof(id) === "string") ? id.trim() : ""
		if (t.length === 0) {
			errorFct("unknown search !");
			return;
		}
		dao.findItemById(id).then(
			function(item) {
				scraper.refreshSearch(item).then(
					function(newItem) {
						resolve(newItem.toApi());
					},
					errorFct
				);
			},
			errorFct
		);
	});
	return promise;
}

Api.prototype.searchById = function(id) {
	var self = this;

	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}

		dao.findItemById(id).then(
			function(item) {
				resolve(item.toApi());
			},
			errorFct
		);
	});
	return promise;
}

Api.prototype.searchRemoveById = function(id, order) {
	if (tools.isPositiveInteger(order)) {
		// remove torrent instead of search
		var promise = when.promise(function(resolve, reject) {
			var errorFct = function(err) {
				reject(new Error(err));
			}

			dao.findItemById(id).then(
				function(searchInfo) {
					if (searchInfo.removeTorrentInfo(order)) {
						dao.updateItem(searchInfo).then(
							function(result) {
								resolve(searchInfo.toApi());
							},
							errorFct
						);
					}
					else {
						errorFct(util.format("fail to remove item <%d>", order));
					}
				},
				errorFct
			);

		});
		return promise;

	}
	return dao.removeItem(id);
}

Api.prototype.searchChangeTorrentState = function(id, state, order) {
	var self = this;

	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}

		dao.findItemById(id).then(
			function(searchInfo) {
				var modifiedOrders = searchInfo.changeState(state, order);
				var promiseArray = [];

				if (modifiedOrders.length == 0) {
					errorFct("Cannot find torrent to update !");
				}

				modifiedOrders.forEach(function(order) {
					var ti = searchInfo.torrentInfos[order];
					var p;
					var newState = !!state;
					if (newState) {
						p = scraper.downloadTorrentPageAndExtractTorrentUrl(ti.pageUrl, order);
					}
					else {
						// reset torrent url
						var tpi = new TorrentPageInfo(ti.pageUrl, null, order);
						p = when.resolve(tpi);
					}
					promiseArray.push(p);
				});

				// if unchanged resolve !
				if (promiseArray.length == 0) {
					promiseArray.push(when.resolve(null));
				};

				// wait scraping
				when.all(promiseArray).then(
					function(result) {
						// result -> array of TorrentPageInfo
						result.forEach(function(tpi) {
							// tpi -> TorrentPageInfo or null (if autoresolved)
							if (tpi) {
								/*
								var ti = searchInfo.torrentInfos[tpi.order];
								ti.torrentUrl = tpi.torrentUrl;
								*/
								searchInfo.updateTorrentInfoFromTorrentPageInfo(tpi);
							};
						});
					},
					errorFct
				).then(
					function() {
						// console.log(searchInfo);
						dao.updateItem(searchInfo).then(
							function(result) {
								resolve(searchInfo.toApi());
							},
							errorFct
						);
					},
					errorFct
				);
			},
			errorFct
		)
	});

	return promise;
}

Api.prototype.searchDownloadMissingTorrentById = function(id) {
	var self = this;
	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}

		dao.findItemById(id).then(
			function(searchInfo) {
				var downloaded = [];
				syno.login().then(
					function(result) {
						var sid = result.sid;
						var missArray = searchInfo.missingTorrents();
						var promiseArray = [];

						missArray.forEach(
							function(torrentInfo) {
								var p = syno.create(sid, torrentInfo.torrentUrl).then(
                                    function(result) {
                                    	downloaded.push(torrentInfo.torrentUrl);
                                        searchInfo.changeState(false, torrentInfo.order);
                                    },
									errorFct
								);
								promiseArray.push(p);
							}
						);

						if (promiseArray.length == 0) {
							promiseArray.push(when.resolve(null));
						};

						when.all(promiseArray).then(
							function(result) {
								dao.updateItem(searchInfo).then(
									function(result) {
										resolve(searchInfo.toApi());
									},
									errorFct
								);
							},
							errorFct
						);

					}
				);
			},
			errorFct
		);
	});
	return promise;
}

Api.prototype.compactDatabase = function() {
	return dao.compactDatabase();
}

exports = module.exports = new Api();