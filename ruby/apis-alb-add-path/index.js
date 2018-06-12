var spawn = require('child_process').spawn;

var invokeRubyApp = "./app";

exports.handler = function(event, context) {
  console.log("Starting process: " + invokeRubyApp);
  console.log("ALB_ARN: " + process.env.ALB_ARN);
  console.log("TG_GROUP: " + process.env.TG_GROUP);
  console.log("PATH_PATTERN: " + process.env.PATH_PATTERN);
  var child = spawn(invokeRubyApp, [JSON.stringify(event, null, 2), JSON.stringify(context, null, 2), process.env.ALB_ARN, process.env.TG_GROUP, process.env.PATH_PATTERN]);

  child.stdout.on('data', function (data) { console.log("stdout:\n"+data); });
  child.stderr.on('data', function (data) { console.log("stderr:\n"+data); });

  child.on('close', function (code) {
    if(code === 0) {
      context.succeed("Process completed: " + invokeRubyApp);
    } else {
      context.fail("Process \"" + invokeRubyApp + "\" exited with code: " + code);
    }
  });
}