module.exports = function(paths) {
    return {
        module: {
            loaders: [
                {
                    test: /\.css$/,
                    include: paths,
                    use: [
                        'style-loader',
                        'css-loader'
                    ]
                }
            ]
        }
    };
};
