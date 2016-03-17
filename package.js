Package.describe({
  summary: "Meteor Forecast.io Wrapper",
  version: "0.0.1"
});

Npm.depends({
  "request" : "2.51.0"
});

Package.onUse(function (api) {
  api.versionsFrom('0.9.0');
  api.use([
    'coffeescript',
    'meteorhacks:npm',
    'mrt:moment',
    'http'
  ], ['server']);
  api.export('Forecast', 'server');
  api.addFiles('index.coffee', 'server');
});