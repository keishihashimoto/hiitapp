jQuery(function($){
  var cardImageContainer = $('.card-image-container')
  for(var i = 0; i <= cardImageContainer.length; i++){
    var container = cardImageContainer[i]
    var length = $(container).width()
    console.log(container)
    $(container).height(length)
    if($(container).find("img").height() > length){
      $(container).find("img").height(length)
    }
  }
})