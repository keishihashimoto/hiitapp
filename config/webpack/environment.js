const { environment } = require('@rails/webpacker')

// jquery導入部分
const webpack = require("webpack")
environment.plugins.prepend("Provide",
  new webpack.ProvidePlugin({
    $: "jquery/src/jquery",
    jQuery: "jquery/src/jquery"
  })
)
// jquery導入部分終わり

module.exports = environment
