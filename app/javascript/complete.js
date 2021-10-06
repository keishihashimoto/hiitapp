jQuery(function($){
  $(".hiit-complete").on("click", function(e){
    e.preventDefault()
    var url = $(this).attr("href")
    var hiitId = $(this).attr("id")
    var target = $(this).parents(".card").find(".completed")
    var text = $(target).text()
    $.ajax({
      url: url,
      type: "POST",
      dataType: "json",
      cache: false,
      data: { hiitId: hiitId}
    }).done(function(){
        if(text === "未実施"){
          $(target).text("実施済み!!")
        }else{
          $(target).text("未実施")
        }
    }).fail(function(){
        alert("通信に失敗しました。画面を再度読み込んでください。")
      })
  })
})