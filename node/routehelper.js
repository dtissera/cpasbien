var _ = require('lodash');

var RouteHelper = function() {

}

RouteHelper.prototype.print = function(rootUrl, router) {
	console.log(rootUrl);
	if (router && router.stack instanceof Array) {
		router.stack.forEach(function(s) {
			var route = s.route;
			if (route) {
	 			route.stack.forEach(function(handle) {
					console.log(_.padRight(handle.method.toUpperCase(), 7)+route.path);
				});
			}
		})
	}
	console.log("");
}

exports = module.exports = new RouteHelper();