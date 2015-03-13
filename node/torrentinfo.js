var _ = require("underscore");
var __ = require('lodash');
var util = require('util');

function pickProp(value, key, object) {
	return (object.hasOwnProperty(key) && !_.isFunction(value))
}

var TorrentInfo = function(param) {
	this.order = -1;
	this.name = "";
	this.pageUrl = "";
	this.fileSize = "";
	this.extraInfo = "";
	this.enabled = false;
	this.torrentUrl = null;

	this.calc_isSerie = null;
	this.calc_dateStr = null;
	this.calc_date = null;

	if (_.isObject(param)) {
		// constructor from model
		_.extend(this, __.cloneDeep(param));
	}

}

TorrentInfo.prototype.model = function () {
	var self = this;

	var model = __.cloneDeep(_.extend({}, _.pick(self, pickProp)));

	return model;
}

TorrentInfo.prototype.parse = function() {
	if (typeof(this.fileSize) == "string") {
		this.fileSize = this.fileSize.trim();
	}
	if (typeof(this.extraInfo) == "string") {
		this.calc_isSerie = this.extraInfo.split("<br>")[0] == "Séries";

		var array = this.extraInfo.split("- ");
		if (array.length > 1) {
			this.calc_dateStr = array[1];

			if (this.calc_dateStr && typeof(this.calc_dateStr) == "string") {
				var pattern = /^(\d{2})\/(\d{2})\/(\d{4})$/;
				var res = this.calc_dateStr.match(pattern);
				if (res) {
					this.calc_date = new Date(this.calc_dateStr.replace(pattern,'$3-$2-$1'));
				}
			}
		}
	}
}

TorrentInfo.prototype.toApi = function() {
	var self = this;

	var torrent = {
		order: self.order,
		name: self.name,
		enabled: self.enabled,
		fileSize: self.fileSize,
		date: self.calc_date,
		url: self.torrentUrl
	};

	return torrent;
}

exports = module.exports = TorrentInfo