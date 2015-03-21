var util = require('util');
var request = require('request');
var tools = require('./tools');
var when = require('when');
var config = require('./config');

var Syno = function() {
	this.session = "DownloadStation";

	this.fileStation_url = util.format("http://%s:%d/webapi/FileStation/", config.synoHost, config.synoPort);
	this.downloadStation_url = util.format("http://%s:%d/webapi/DownloadStation/task.cgi", config.synoHost, config.synoPort);
	this.fileStationFileShare_url = util.format("http://%s:%d/webapi/FileStation/file_share.cgi", config.synoHost, config.synoPort);
	this.fileStationFileRename_url = util.format("http://%s:%d/webapi/FileStation/file_rename.cgi", config.synoHost, config.synoPort);
    this.auth_url = util.format("http://%s:%d/webapi/auth.cgi", config.synoHost, config.synoPort);
}

Syno.prototype.errorFromCode = function(api, code) {
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
	}
	if (api === 'SYNO.FileStation.CopyMove') {
		switch(code) {
			case 1000: return util.format('Failed to copy files/folders (%d)', code);
			case 1001: return util.format('Failed to move files/folders (%d)', code);
			case 1002: return util.format('An error occurred at the destination (%d)', code);
			case 1003: return util.format('Cannot overwrite or skip the existing file because no overwrite parameter is given (%d)', code);
			case 1004: return util.format('File cannot overwrite a folder with the same name, or folder cannot overwrite a file with the same name (%d)', code);
			case 1006: return util.format('Cannot copy/move file/folder with special characters to a FAT32 file system (%d)', code);
			case 1007: return util.format('Cannot copy/move a file bigger than 4G to a FAT32 file system (%d)', code);
		}
	}
	return util.format('Internal error (%d)', code);
}

Syno.prototype.login = function() {
	var self = this;
	var api = "SYNO.API.Auth";
	var options = {
		url: self.auth_url,
		json: true,
		method: 'GET',
		qs: {
			api: api,
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
					var err = self.errorFromCode(api, obj.error.code);
					console.log(obj.error);
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
	var api = "SYNO.API.Auth";

	var options = {
		url: self.auth_url,
		json: true,
		method: 'GET',
		qs: {
			api: api,
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
					var err = self.errorFromCode(api, obj.error.code);
					console.log(obj.error);
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
	var api = "SYNO.DownloadStation.Task";

	var options = {
		url: self.downloadStation_url,
		json: true,
		method: 'GET',
		qs: {
			api: api,
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
					var err = self.errorFromCode(api, obj.error.code);
					console.log(obj.error);
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
	var api = "SYNO.FileStation.List";

	var options = {
		url: self.fileStationFileShare_url,
		json: true,
		method: 'GET',
		qs: {
			api: api,
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
					var err = self.errorFromCode(api, obj.error.code);
					console.log(obj.error);
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

Syno.prototype.rename = function(sid, path, name) {
	var self = this;
	var api = "SYNO.FileStation.Rename";

	var options = {
		url: self.fileStationFileRename_url,
		json: true,
		method: 'GET',
		qs: {
			api: api,
			version: "1",
			method: "rename",
			path: path,
			name: name,
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
					var err = self.errorFromCode(api, obj.error.code);
					console.log(obj.error);
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

Syno.prototype.move = function(sid, path, destpath) {
	var self = this;
	var api = "SYNO.FileStation.CopyMove";

	var options = {
		url: util.format("%s%s", self.fileStation_url, "file_MVCP.cgi"),
		json: true,
		method: 'GET',
		qs: {
			api: api,
			version: "1",
			method: "start",
			path: path,
			dest_folder_path: destpath,
			overwrite: true,
			remove_src: true,
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
					var err = self.errorFromCode(api, obj.error.code);
					console.log(obj.error);
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

Syno.prototype.apiRename = function(path, name) {
	var self = this;
	var promise = when.promise(function(resolve, reject) {
		self.login().then(
			function(result) {
				var sid = result.sid;

				self.rename(sid, path, name).then(
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

Syno.prototype.apiMove = function(path, destpath) {
	var self = this;
	var promise = when.promise(function(resolve, reject) {
		self.login().then(
			function(result) {
				var sid = result.sid;

				self.move(sid, path, destpath).then(
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

