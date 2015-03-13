var when = require('when');

var Tools = function() {
}

Tools.prototype.pad = function(width, string, padding) {
	if (typeof(string) === "string") {
		return (width <= string.length) ? string : this.pad(width, padding + string, padding);
	}
	return string;
}

Tools.prototype.extractHttpError = function(error, response) {
	var res;
	if (!error) {
		if (response.statusCode == 200) {
			res = "no error ! should not append";
		}
		else {
			res = response.statusCode;
		}
	}
	else {
		res = error;
	}
	return res;
}

Tools.prototype.fail = function(err) {
	return new Error(err);
}

Tools.prototype.isPositiveInteger = function(n) {
    return 0 === n % (!isNaN(parseFloat(n)) && 0 <= ~~n);
}

exports = module.exports = new Tools()