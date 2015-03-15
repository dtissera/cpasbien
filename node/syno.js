var util = require('util');
var request = require('request');
var tools = require('./tools');
var when = require('when');
var config = require('./config');

var Syno = function() {
	this.session = "DownloadStation";

	this.downloadStation_url = util.format("http://%s:%d/webapi/DownloadStation/task.cgi", config.synoHost, config.synoPort);
	this.fileStation_url = util.format("http://%s:%d/webapi/FileStation/file_share.cgi", config.synoHost, config.synoPort);
    this.auth_url = util.format("http://%s:%d/webapi/auth.cgi", config.synoHost, config.synoPort);
}

Syno.prototype.errorFromCode = function(code) {
	switch(code) {
		case 100: return util.format("Unknown error (%d)", code);
		case 101: return util.format("Invalid parameter (%d)", code);
		case 102: return util.format("The requested API does not exist (%d)", code);
		case 103: return util.format("The requested method does not exist (%d)", code);
		case 104: return util.format("The requested version does not support the functionality (%d)", code);
		case 105: return util.format("The logged in session does not have permission (%d)", code);
		case 106: return util.format("Session timeout (%d)", code);
		case 107: return util.format("Session interrupted by duplicate login (%d)", code);
		case 400: return util.format("File upload failed (%d)", code);
		case 401: return util.format("Max number of tasks reached (%d)", code);
		case 402: return util.format("Destination denied (%d)", code);
		case 403: return util.format("Destination does not exist (%d)", code);
		case 404: return util.format("Invalid task id (%d)", code);
		case 405: return util.format("Invalid task action (%d)", code);
		case 406: return util.format("No default destination (%d)", code);
		case 407: return util.format("Set destination failed (%d)", code);
		case 408: return util.format("File does not exist (%d)", code);
		default:
			return code;
	}
}

Syno.prototype.login = function() {
	var self = this;

	var options = {
		url: self.auth_url,
		json: true,
		method: 'GET',
		qs: {
			api: "SYNO.API.Auth",
			account: config.synoAccount,
			passwd: config.synoPasswd,
			version: "2",
			method: "login",
			session: self.session,
			format: "sid"
		}

	};
	var promise = when.promise(function(resolve, reject) {
		//request.debug = true;
		request(options, function (error, response, obj) {
			if (!error && response.statusCode == 200) {
				if (obj.success) {
					resolve({sid: obj.data.sid});
				}
				else {
					var err = self.errorFromCode(obj.error.code);
					reject(new Error(err));
				}
			}
			else {
				var err = tools.extractHttpError(error, response);
				reject(new Error(err));
			}
		});
	});
	return promise;
}

Syno.prototype.logout = function(sid) {
	var self = this;

	var options = {
		url: self.auth_url,
		json: true,
		method: 'GET',
		qs: {
			api: "SYNO.API.Auth",
			version: "1",
			method: "logout",
			session: self.session,
			_sid: sid
		}
	};
	var promise = when.promise(function(resolve, reject) {
		request(options, function (error, response, obj) {
			if (!error && response.statusCode == 200) {
				if (obj.success) {
					resolve(obj);
				}
				else {
					var err = self.errorFromCode(obj.error.code);
					reject(new Error(err));
				}
			}
			else {
				var err = tools.extractHttpError(error, response);
				reject(new Error(err));
			}
		});
	});
	return promise;
}

Syno.prototype.create = function(sid, uri) {
	var self = this;

	var options = {
		url: self.downloadStation_url,
		json: true,
		method: 'GET',
		qs: {
			api: "SYNO.DownloadStation.Task",
			version: "1",
			method: "create",
			uri: uri,
			destination: config.synoDownloadDestinationFolder,
			_sid: sid
		}
	};
	var promise = when.promise(function(resolve, reject) {
		request(options, function (error, response, obj) {
			if (!error && response.statusCode == 200) {
				if (obj.success) {
					resolve(obj);
				}
				else {
					var err = self.errorFromCode(obj.error.code);
					reject(new Error(err));
				}
			}
			else {
				var err = tools.extractHttpError(error, response);
				reject(new Error(err));
			}
		});
	});
	return promise;
}

Syno.prototype.list = function(sid, path) {
	var self = this;

	var options = {
		url: self.fileStation_url,
		json: true,
		method: 'GET',
		qs: {
			api: "SYNO.FileStation.List",
			version: "1",
			method: "list",
			folder_path: path,
			additional: 'real_path,size',
			sort_by: 'name',
			_sid: sid
		}
	};
	var promise = when.promise(function(resolve, reject) {
		request(options, function (error, response, obj) {
			if (!error && response.statusCode == 200) {
				if (obj.success) {
					resolve(obj);
				}
				else {
					var err = self.errorFromCode(obj.error.code);
					reject(new Error(err));
				}
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
Syno.prototype.apiList = function(path) {
	var self = this;
	var promise = when.promise(function(resolve, reject) {
		self.login().then(
			function(result) {
				var sid = result.sid;

				self.list(sid, path).then(
					function(result) {
						resolve(result);
					},
					function(error) {
						reject(new Error(error));
					}
				);

			},
			function(error) {
				reject(new Error(error));
			}
		);
	});
	return promise;
}

exports = module.exports = new Syno()

