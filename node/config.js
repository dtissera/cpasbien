var Config = function() {
	this.serverPort = 8080;
	this.userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.94 Safari/537.36";

	this.synoHost = "192.168.1.20";
	this.synoPort = 5000;
	this.synoAccount = "download";
	this.synoPasswd = "download";
	this.synoDownloadDestinationFolder = "downloads";
}

exports = module.exports = new Config()