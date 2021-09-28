jQuery(function($){
  // 画像表示部分の縦横比を調整
  const height = $('#card-image-container').width()
  $('#card-image-container').height(height)
  // active_time, rest_time, 1 ~ 8種目目の種目名を取得する。
  $('.timer').on("click", function(){
    // 計測スタートボタン押下時に、画面を一番上までスクロールさせる
    $("main").scrollTop($("#cycle_count").scrollTop())
    // もし一度タイマーを動かした後であれば、鳴っている音楽を全て止める
    $('#countdownAudio')[0].pause()
    $('#finishAudio')[0].pause()
    // タイマー終了までボタンを押せないようにする
    $('.timer').prop("disabled", true)
    var target = this
    var restImage = $('#rest_image').clone().css("display", "inline-block")
    var hiitMenuImages = $(target).parents(".card").find("img")
    var activeTimeStr = $(this).parents(".card").find(".active_time").text().replace("1種目あたりの時間：", "").replace("秒", "")
    var activeTime = new Number(activeTimeStr)
    var restTimeStr = $(this).parents(".card").find(".rest_time").text().replace("休憩時間：", "").replace("秒", "")
    var restTime = new Number(restTimeStr)
    var menus = []
    for(var i = 0; i <= 7; i++){
      var menuName = $(this).parents(".card").find("span.menu_names")[i]
      menus.push($(menuName).text())
    }
    // hiitの合計時間を計算する
    var totalTime = 8 * activeTime + 7 * restTime
    var remainingTotalTime = totalTime
    // 一種目目の情報を表示する
    $('#cycle_count').text(1)// 1回目
    $('#menu_name').text(menus[0])// 種目名
    $('#time-area').text(activeTime)// 秒数
    var firstMenuImage = $(hiitMenuImages)[0]
    var firstMenuImageSrc = $(firstMenuImage).attr("src")
    $("#ready_image").attr("src", firstMenuImageSrc).width("100%").height("100%")// 画像
    // プログレスバー
    $('#progress-area').html("<div></div>")
    var progress = $('#progress-area').find("div").addClass("progress")
    $(progress).html("<div></div>")
    $(progress).find("div").addClass("progress-bar")
    $(".progress-bar").width("100%").attr("aria-valuemin", "0").attr("aria-valuemax", activeTimeStr)
    // totalTimeが0になったら終了するタイマーを仕掛ける
    const timeCount = setInterval(function(){
           
      remainingTotalTime--
      var cycleCount = 8 - Math.floor((remainingTotalTime + restTime) / (activeTime + restTime))
      if((remainingTotalTime + restTime) % (activeTime + restTime) == 0){
        cycleCount++
      }

      var calcTime = (totalTime - remainingTotalTime) - (cycleCount - 1) * (activeTime + restTime)
      if(calcTime < activeTime){
        var doingMenuName = menus[(cycleCount - 1)]
      } else {
        var doingMenuName = "休憩時間"
      }
      if(doingMenuName == "休憩時間"){
        var displayTime = remainingTotalTime - (8 - 1 - cycleCount) * (activeTime + restTime) - activeTime
        var menuImage = $(restImage).addClass("img-fluid").width("100%").height("100%")
      } else {
        var displayTime = remainingTotalTime - (8 - cycleCount) * (activeTime + restTime)
        var menuImageOriginal = hiitMenuImages[(cycleCount - 1)]
        var menuImageSrc = $(menuImageOriginal).attr("src")
        var menuImage = $("<img>")
        $(menuImage).addClass("img-fluid").width("100%").height("100%").attr("src",menuImageSrc)
      }
      $('#cycle_count').text(cycleCount)
      $('#menu_name').text(doingMenuName)
      $('#time-area').text(displayTime)
      $("#card-image-container").html(menuImage)
      console.log(displayTime)
      // progress-barの補正
      if(doingMenuName == "休憩時間"){
        var percent = Math.floor((displayTime / restTime) * 100)
        var valueMax = restTimeStr
      } else {
        var percent = Math.floor((displayTime / activeTime) * 100)
        var valueMax = activeTimeStr
      }
      $('.progress-bar').width(`${percent}%`).attr("aria-valuemax", valueMax).attr("aria-valuenow", percent)

      // 音声ファイルの制御部分
      // displayTimeが残り3秒になったらcountdown音楽を再生
      // 残り時間が0になったら終了音楽を再生
      if(displayTime == 3){
        $("#countdownAudio")[0].play()
      }
      
    }, 1000)

    // 完了時の処理
    setTimeout(function(){
      // timeCount関数を停止する処理
      clearInterval(timeCount)
      //表示を終了時のものに修正
      $('#time-area').text("--")
      $('#menu_name').text("お疲れ様でした")
      $('#cycle_count').text("終了")
      const finishImage = $('#finish_image').clone().css("display", "inline-block").addClass("img-fluid")
      $("#card-image-container").html(finishImage)
      $("#finishAudio")[0].play()
      $('#countdownAudio')[0].pause()
      $('.progress-bar').width(0)
    }, totalTime * 1000)
  })
})