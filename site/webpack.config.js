const path = require('path');
const merge = require('webpack-merge');
const webpack = require('webpack');
const devserver = require('./webpack/devserver');
const sass = require('./webpack/sass');
const css = require('./webpack/css');
const extractCSS = require('./webpack/css.extract');



const PATHS = {
    source: path.join(__dirname, 'source/'),
    build: path.join(__dirname, 'build/'),
    test: path.join(__dirname, 'test/')
};

// development & production
const common = merge([
  {
    entry: {
        'js': PATHS.source + 'components/SignIn/SignIn.js'
    },
    output: {
        path: PATHS.build,
        filename: 'build.js'
    },
    module : {
      loaders : [
        {
          test : /\.js?/,
          include : PATHS.source,
          loader : 'babel-loader'
        }
      ]
    },
    plugins: [
        new webpack.ProvidePlugin({
            $: "jquery",
            jQuery: "jquery"
        })
    ]
  }
]);



module.exports = function(env) {
    if (env === 'production') {
      return merge([
          common,
          extractCSS(PATHS.source)
      ]);
    }
    if (env === 'development') {
        return merge([
          common,
          devserver(),
          sass(PATHS.source),
          css(PATHS.source)
        ]);
    }
};
