var _ = require("underscore");
var __ = require("lodash");
var util = require("util");
var tools = require("./tools");
var TorrentInfo = require("./torrentinfo");
var TorrentPageInfo = require("./torrentpageinfo");
//console.log(util.inspect(_, {showHidden: true, depth: null}));

function pickProp(value, key, object) {
	return (object.hasOwnProperty(key) && !_.isFunction(value) && key !== "_id")
}

var SearchInfo = function(param) {
	var self = this;
	var id_;

	this.getId = function() {
		return id_;
	}

	self.words = "";
	self.description =  "";
	self.paginationUrls = [];
	self.torrentInfos = [];
	self.added = null;
	self.updated = null;

	if (!(_.isNull(param) || _.isUndefined(param))) {
		// Simple constructor
		if (_.isString(param)) {
			// constructor from searchString
			_.extend(self, {
				words: param,
				added: new Date()
			});
		}
		else if (_.isObject(param)) {
			// constructor from model
			id_ = param._id;
			_.extend(self, __.cloneDeep(_.pick(param, pickProp)));
			for (i = 0, len = self.torrentInfos.length; i < len; i++) {
				self.torrentInfos[i] = new TorrentInfo(self.torrentInfos[i]);
			}
		}
		else {
			console.log("DEV: not implemented");
		}
	}
}

SearchInfo.prototype.model = function () {
	var self = this;

	var model = __.cloneDeep(_.extend({}, _.pick(self, pickProp)));
	model.torrentInfos = [];

	for (i = 0, len = self.torrentInfos.length; i < len; i++) {
		model.torrentInfos.push(self.torrentInfos[i].model());
	}

	model._id = self.getId();

	return model;
}

SearchInfo.prototype.torrentInfosIterator = function(iter) {
	var self = this;

	for (i = 0, len = self.torrentInfos.length; i < len; i++) {
		var ti = self.torrentInfos[i];

		iter(i, ti);
	}
}

SearchInfo.prototype.removeTorrentInfo = function(order) {
	var self = this;
	var res = false
	if (tools.isPositiveInteger(order)) {
		if (order < self.torrentInfos.length) {
			self.torrentInfos.splice(order, 1);
			self.reorderByPosition();
			res = true;
		}
	}
	return res;
}

SearchInfo.prototype.reorderByPosition = function() {
	var self = this;

	// Index torrents
	self.torrentInfosIterator(function(index, torrentInfo) {
		torrentInfo.order = index;
	});
}

SearchInfo.prototype.missingTorrents = function() {
	var self = this;

	var tis = [];

	self.torrentInfosIterator(function(index, torrentInfo) {
		if (torrentInfo.enabled) {
			tis.push(torrentInfo);
		}
	});

	return tis;
}

SearchInfo.prototype.reorderByDate = function() {
	var self = this;
	// Sort torrents DESC
	var ti = self.torrentInfos.sort(function(ti1, ti2) {
		if (ti1.calc_date < ti2.calc_date) {
			return 1;
		}
		else if (ti1.calc_date > ti2.calc_date) {
			return -1;
		}
		else {
			return 0;
		}
	});

	self.torrentInfos = ti;
	self.reorderByPosition();
}

SearchInfo.prototype.changeState = function(state, order) {
	var self = this;

	var res = [];

	if (typeof(order) !== "undefined") {
		var setted = false;
		if (tools.isPositiveInteger(order)) {
			order = Math.floor(order);
			if (order < self.torrentInfos.length) {
				var ti = self.torrentInfos[order];
				var newState = !!state;

				// push only modifications
				if (newState != ti.enabled) {
					res.push(ti.order);
				}

				ti.enabled = newState; 
				setted = true;
			}
		}

		if (!setted) {
			//errorFct("wrong order !");
			return;
		}
	}
	else {
		for (i = 0, len = self.torrentInfos.length; i < len; i++) {
			var ti = self.torrentInfos[i];
			var newState = !!state;

			// push only modifications
			if (newState != ti.enabled) {
				res.push(ti.order);
			}

			ti.enabled = !!state;
		}
	}
	return res;
}

SearchInfo.prototype.updateTorrentInfoFromTorrentPageInfo = function(tpi) {
	var self = this;
	var res = false;
	if (tools.isPositiveInteger(tpi.order)) {
		if (tpi.order < self.torrentInfos.length) {
			self.torrentInfos[tpi.order].torrentUrl = tpi.torrentUrl;
		}
	}
	return res;
}

SearchInfo.prototype.toApi = function(compact) {
	var self = this;

	var res = {
		id: self.getId(),
		research: self.words,
		missingCount: null,
		count: null,
		added: self.added,
		updated: self.updated
	}

	if (!compact) {
		res.torrents = [];
	}

	// count torrents to download
	count = 0;
	self.torrentInfosIterator(function(index, torrentInfo) {
		if (torrentInfo.enabled) {
			count++;
		}
		if (!compact) {
			// console.log(util.inspect(torrentInfo, {showHidden: true, depth: null}));
			res.torrents.push(torrentInfo.toApi());
		}
	});

	res.missingCount = count;
	res.count = self.torrentInfos.length;
	return res;
}

exports = module.exports = SearchInfo