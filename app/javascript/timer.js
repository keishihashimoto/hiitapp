jQuery(function($){
  // active_time, rest_time, 1 ~ 8種目目の種目名を取得する。
  $('.timer').on("click", function(){
    const activeTimeStr = $(this).parents(".card").find(".active_time").text().replace("1種目あたりの時間：", "").replace("秒", "")
    const activeTime = new Number(activeTimeStr)
    const restTimeStr = $(this).parents(".card").find(".rest_time").text().replace("休憩時間：", "").replace("秒", "")
    const restTime = new Number(restTimeStr)
    var menus = []
    for(var i = 0; i <= 7; i++){
      var menuName = $(this).parents(".card").find("span.menu_names")[i]
      menus.push($(menuName).text())
    }
    // hiitの合計時間を計算する
    var totalTime = 8 * activeTime + 7 * restTime
    var remainingTotalTime = totalTime
    // 一種目目の情報を表示する
    $('#cycle_count').text(1)
    $('#menu_name').text(menus[0])
    $('#time-area').text(activeTime)
    // totalTimeが0になったら終了するタイマーを仕掛ける
    setInterval(function(){
      if(remainingTotalTime == 0){
        clearInterval(this)
        $('#time-area').parent("div").text("終了です!!")
      } else {        
        remainingTotalTime--
        var cycleCount = 8 - Math.floor((remainingTotalTime + restTime) / (activeTime + restTime))
        if((remainingTotalTime + restTime) % (activeTime + restTime) == 0){
          cycleCount++
        }

        var calcTime = (totalTime - remainingTotalTime) - (cycleCount - 1) * (activeTime + restTime)
        if(calcTime <= activeTime){
          var doingMenuName = menus[(cycleCount - 1)]
        } else {
          var doingMenuName = "休憩時間"
        }
        if(doingMenuName == "休憩時間"){
          var displayTime = remainingTotalTime - (8 - 1 - cycleCount) * (activeTime + restTime) - activeTime
        } else {
          var displayTime = remainingTotalTime - (8 - cycleCount) * (activeTime + restTime)
        }
        $('#cycle_count').text(cycleCount)
        $('#menu_name').text(doingMenuName)
        $('#time-area').text(displayTime)
      }
    }, 1000)
  })
})