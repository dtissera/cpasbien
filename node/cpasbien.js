var request = require('request');
var scraper = require('./scraper');
var program = require('commander');
var dao = require("./dao");
var cmd = require("./cmd");
var util = require('util');

program
	.version('0.0.1')
	.option('--list', 'list research')
	.option('--id [value]', 'display search <id>')
	.option('--remove [value]', 'remove search <id>')
	.option('--create [value]', 'new search <title>')
	.option('--update [value]', 'update search <id>')
	.option('--disable [value]', 'disable torrent <id,order?>')
	.option('--enable [value]', 'enable torrent <id,order?>')
	.option('--download [value]', 'downloads missing torrents <id>')
	.option('--compactdb', 'compact database')
	.parse(process.argv);

if (program.list) {
	cmd.searchAll();
}

if (program.id) {
	cmd.searchById(program.id);
}

if (program.remove) {
	cmd.searchRemoveById(program.remove);
}

if (program.create) {
	cmd.searchCreate(program.create);
}

if (program.update) {
	cmd.searchUpdate(program.update);
}

if (program.disable) {
	var arg = program.disable.split(",");
	cmd.searchDisable(arg[0], arg.length > 1 ? arg[1] : undefined);
}

if (program.enable) {
	var arg = program.enable.split(",");
	cmd.searchEnable(arg[0], arg.length > 1 ? arg[1] : undefined);
}

if (program.update) {
	cmd.searchUpdate(program.update);
}

if (program.download) {
	cmd.searchDownloadMissingTorrentById(program.download);
}
