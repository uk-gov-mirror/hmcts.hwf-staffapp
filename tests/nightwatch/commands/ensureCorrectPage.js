'use strict';

var log = require('../modules/log');
var util = require('util');

exports.command = function(waitForSelector, pageUrl, textToContain, callback) {
  var client = this,
      testUrl = client.launchUrl + pageUrl;

  this.perform(function() {
    log.command('Checking the page is correct...');

    client
      .waitForElementVisible(waitForSelector, 5000,
        '  - Page is ready'
      )
      .assert.urlContains(testUrl,
        util.format('  - URL is %s', testUrl)
      );

    if(typeof textToContain === 'object' && Object.keys(textToContain).length) {
      Object.keys(textToContain).forEach(function(selector) {
        client.assert.containsText(selector, textToContain[selector],
          util.format('  - `%s` contains text \'%s\'', selector, textToContain[selector])
        );
      });
    }
  });

  if (typeof callback === 'function') {
    callback.call(client);
  }

  return client;
};
