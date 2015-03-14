var util = require('util');
var when = require('when');
var fs = require('fs');
var _ = require('lodash');
// console.log(util.inspect(result, {showHidden: true, depth: null}));

var Config = function() {
	this.serverPort = 8080;
	this.userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.94 Safari/537.36";

	this.synoHost = "192.168.1.20";
	this.synoPort = 5000;
	this.synoAccount = "download";
	this.synoPasswd = "download";
	this.synoDownloadDestinationFolder = "downloads";
}

Config.prototype.print = function() {
	console.log(util.format('  serverPort: %d', this.serverPort));
	console.log(util.format('  userAgent: %s', this.userAgent));
	console.log(util.format('  syno: %s@%s:%d', this.synoAccount, this.synoHost, this.synoPort));
	console.log(util.format('  synoDownloadDestinationFolder: %s', this.synoDownloadDestinationFolder));
}

Config.prototype.load = function() {
	var self = this;

	var promise = when.promise(function(resolve, reject) {
		var errorFct = function(err) {
			reject(new Error(err));
		}
		fs.exists('./configuration/config.json', function (exists) {
			if (exists) {
				fs.readFile('./configuration/config.json', function (err, data) {
					if (err) {
						errorFct(util.format('Error while loading configuration: %s', err.message));
					}
					else {
						try {
							result = JSON.parse(data);
							_.assign(self, result);
							resolve(true);
						}
						catch(e) {
							errorFct(util.format('Error while loading configuration: %s', e.message));
						}
					}
				});
			}
			else {
				errorFct("File missing: <configuration/config.json> !");
			}
		});
	});
	return promise;

	
}

exports = module.exports = new Config()