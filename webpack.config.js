const path = require('path');

module.exports = {
    entry: './app/js/target_index.js',
    output: {
        path: path.resolve(__dirname, 'build', 'js'),
        filename: 'bundle.js',
    },
    mode: 'development',
}
