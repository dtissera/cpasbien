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
	.option('--compactdb', 'compact database')

	.option('--search [value]', 'search torrents')
	.option('--id [value]', 'display search <id>')
	.option('--idraw [value]', 'display raw search <id>')
	.option('--removeall', 'remove all searches')
	.option('--disableid [value]', 'disable torrent <id,order?>')
	.option('--enableid [value]', 'enable torrent <id,order?>')
	.option('--missingid [value]', 'missing downloads <id>')
	.option('--downloadid [value]', 'downloads missing torrents <id>')
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

if (program.compactdb) {
	cmd.compactDatabase();
}




if (program.removeall) {
	dao.removeItems();
}

if (program.disableid) {
	var arg = program.disableid.split(",");
	dao.cmdItemsChangeState(arg[0], arg.length > 1 ? arg[1] : undefined, false);
}

if (program.enableid) {
	var arg = program.enableid.split(",");
	dao.cmdItemsChangeState(arg[0], arg.length > 1 ? arg[1] : undefined, true);
}

if (program.missingid) {
	dao.cmdItemMissingDowloads(program.missingid);
}

if (program.downloadid) {
	scraper.cmdDownloadMissingTorrentsForId(program.downloadid);
}

