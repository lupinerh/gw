const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = function(paths) {
    return {
        module: {
            loaders: [
                {
                    test: /\.scss$/,
                    include: paths,
                    loader: ExtractTextPlugin.extract({
                        publicPath: '../',
                        fallback: 'style-loader',
                        use: ['css-loader','sass-loader'],
                    }),
                },
                {
                    test: /\.css$/,
                    include: paths,
                    loader: ExtractTextPlugin.extract({
                        fallback: 'style-loader',
                        use: 'css-loader',
                    }),
                },
            ],
        },
        plugins: [
            new ExtractTextPlugin('./build.css'),
        ],
    };
};
