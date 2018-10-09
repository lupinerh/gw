module.exports = function(paths) {
    return {
        module: {
            loaders: [
                {
                    test: /\.scss$/,
                    include: paths,
                    use: [
                      'style-loader',
                      'css-loader',
                      'sass-loader'
                    ]
                }
            ]
        }
    };
};
