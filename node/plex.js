var util = require('util');
var request = require('request');
var tools = require('./tools');
var when = require('when');
var config = require('./config');
var _ = require('lodash');

var Plex = function() {
	this.rootUrl = util.format("http://%s:%d/", config.plexHost, config.plexPort);
}

Plex.prototype.sections = function() {
	var self = this;

	var options = {
		url: util.format("%s%s", self.rootUrl, "library/sections/"),
		json: true,
		method: 'GET',
		headers: {
			"User-Agent": config.userAgent,
        	"Accept": "application/json"
    	}
	}

	var promise = when.promise(function(resolve, reject) {
		request(options, function (error, response, obj) {
			if (!error && response.statusCode == 200) {
				var result = [];
				obj._children.forEach(function(section) {
					result.push(section);
				});
				resolve(result);
			}
			else {
				var err = tools.extractHttpError(error, response);
				reject(new Error(err));
			}
		});
	});
	return promise;

}

Plex.prototype.refreshSection = function(section) {
	var self = this;

	var options = {
		url: util.format("%slibrary/sections/%s/refresh", self.rootUrl, section.key),
		json: true,
		method: 'GET',
		headers: {
			"User-Agent": config.userAgent,
        	"Accept": "application/json"
    	}
	}

	var promise = when.promise(function(resolve, reject) {
		request(options, function (error, response, obj) {
			if (!error && response.statusCode == 200) {
				resolve({key: section.key, title: section.title});
			}
			else {
				var err = tools.extractHttpError(error, response);
				reject(new Error(err));
			}
		});
	});
	return promise;
}

/*
 * For api
 */
Plex.prototype.apiRefresh = function(key) {
	var self = this;

	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}

		self.sections().then(
			function(result) {
				var promiseArray = [];
				result.forEach(function(section) {
					var p = self.refreshSection(section);
					promiseArray.push(p);
				});

				// if no section reject !
				if (promiseArray.length == 0) {
					errorFct("no plex section to refresh !");
				};

				// wait scraping
				when.all(promiseArray).then(
					function(result) {
						var keys = _.map(result, "key").toString();
						//console.log(_(result).chain().value());
						resolve({keys: keys});
					},
					errorFct
				)
			},
			errorFct
		);


	});

	return promise;
}



exports = module.exports = new Plex()