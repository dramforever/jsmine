gw = null
gh = null
num = null

levels = [
  [10, 10,  3],
  [20, 20, 20],
  [20, 20, 30],
  [20, 20, 50],
  [75, 40, 60]
]

ch_lnum = ["０", "１", "２", "３", "４", "５", "６", "７", "８", "９"]
ch_mine = "●"

mine = []
disp = []
eles = []
avoid = []

gameOver = false

skel = null

writeOutput = (msg) ->
  document.getElementById("output").innerHTML = msg

reset = () ->
  avoid.length = 0
  gameOver = false
  document.body.innerHTML = skel
  init()


over = (msg, lose) ->
  if gameOver then return

  writeOutput msg
  gameOver = true

  if lose
    x = 0
    while x <= gw
      y = 0

      while y <= gh
        if (mine[x][y])
          disp[x][y] = "M"
        else disp[x][y] = minesAround(x, y)
        y++
      x++

    document.getElementById("grid").className = "red"
    updateAll()
  else
    document.getElementById("grid").className = "green"

minesAround = (x, y) ->
  sum = 0

  if x > 0            then sum += mine[x-1][y  ]
  if y > 0            then sum += mine[x  ][y-1]
  if x < gw           then sum += mine[x+1][y  ]
  if y < gh           then sum += mine[x  ][y+1]
  if x > 0  && y > 0  then sum += mine[x-1][y-1]
  if x > 0  && y < gh then sum += mine[x-1][y+1]
  if x < gw && y > 0  then sum += mine[x+1][y-1]
  if x < gw && y < gh then sum += mine[x+1][y+1]

  return sum

hasWon = () ->
  a = 0
  while a <= gw
    b = 0
    while b <= gh
      if !mine[a][b] && disp[a][b] == undefined
          return false
      b++
    a++

  return true

hit = (x, y) ->
  if mine[x][y]
    over("Game over! Click anywhere below to restart", true)
    return

  if avoid.indexOf(x*1000+y) != -1 || gameOver then return

  avoid.push(x*1000+y)
  disp[x][y] = minesAround(x, y)
  updateGrid(x, y)

  if disp[x][y] == 0
    if x > 0            then hit(x-1, y  )
    if y > 0            then hit(x  , y-1)
    if x < gw           then hit(x+1, y  )
    if y < gh           then hit(x  , y+1)
    if x > 0  && y > 0  then hit(x-1, y-1)
    if x > 0  && y < gh then hit(x-1, y+1)
    if x < gw && y > 0  then hit(x+1, y-1)
    if x < gw && y < gh then hit(x+1, y+1)

  if hasWon()
    over("You win! Click anywhere below to restart", false)

gridUnknown = (x, y) ->
  eles[x][y].innerHTML = ""
  eles[x][y].className = "unknown"


gridZero = (x, y) ->
  eles[x][y].innerHTML = ""
  eles[x][y].className = ""

gridMine = (x, y) ->
  eles[x][y].innerHTML = ch_mine
  eles[x][y].className = "mine"

gridNum = (x, y) ->
  eles[x][y].innerHTML = ch_lnum[disp[x][y]]
  eles[x][y].className = ""

updateGrid = (x, y) ->
  switch disp[x][y]
    when undefined then gridUnknown(x, y)
    when 0 then gridZero(x, y)
    when "M" then gridMine(x, y)
    else gridNum(x, y)

updateAll = () ->
  x = 0
  while x <= gw
    y = 0
    while y <= gh
      updateGrid(x,y)
      y++
    x++

init = () ->
  lv = if location.hash.length > 1
    levels[parseInt(location.hash.slice(1))]
  else
    levels[parseInt( location.hash = prompt("Which level? (1-#{levels.length - 1})", "1"))]

  [gw, gh, num] = lv

  makeHitter = (x, y) ->
    () -> if gameOver then reset() else hit(x, y)

  gridEle = document.getElementById("grid")
  gridEle.innerHTML = ""

  x = 0
  while x <= gw
    tr = document.createElement("tr")
    gridEle.appendChild(tr)

    eles[x] = []

    y = 0
    while y <= gh
      eles[x][y] = document.createElement("td")

      eles[x][y].id            =  "grid-" + x.toString() + "-" + y.toString()
      eles[x][y].onclick       = makeHitter(x, y)

      tr.appendChild(eles[x][y])

      y++
    x++

  x = 0
  while x <= gw
    mine[x] = []

    y = 0
    while y <= gh
      mine[x][y] = 0
      y++
    x++

  i = 1
  while i <= num
    x = Math.floor(Math.random() * (gw + 1))
    y = Math.floor(Math.random() * (gh + 1))
    if mine[x][y]
        i--
    else
        mine[x][y] = 1

    i++

  x = 0
  while x <= gw
    disp[x] = []
    x++

  makeSelect = (l) ->
    () ->
      location.hash = l.toString()

  buttons = document.createElement "span"
  buttons.id = "level-select"

  textLevel = document.createTextNode "Level "
  buttons.appendChild textLevel

  i = 1
  while i < levels.length
    e = document.createElement("button")
    e.onclick = makeSelect(i)
    e.innerHTML = i.toString()
    buttons.appendChild(e)
    i++

  document.body.insertBefore buttons, document.getElementById("output")

  updateAll()
  writeOutput "Total " + num.toString() + " mines."

window.onload = () ->
  skel = document.body.innerHTML
  init()

window.onhashchange = () ->
  reset()
