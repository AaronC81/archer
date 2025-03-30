const path = require('path');

module.exports = {
    entry: './app/js/target_index.js',
    output: {
        path: path.resolve(__dirname, 'build', 'js'),
        filename: 'bundle.js',
    },
    mode: 'development',

    module: {
        rules: [
            {
                test: /\.(js|jsx)$/,
                exclude: /node_modules/,
                use: { loader: 'babel-loader' },
            }
        ]
    }
}
