-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

function love.load()
  -- constants
  screen = {}
  screen.width = 706
  screen.height = 546

  parallelLines = {}
  parallelLines.size = 64
  parallelLines.index = {}
  for i = 1, (screen.width - 2) / parallelLines.size do
    parallelLines.index[i] = (i * parallelLines.size) + 1
  end

  randomLines = {}
  randomLines.size = 64
  randomLines.index = {}

  amountOfHits = 0
  estimationOfPi = 0
  -- Create data file.
  local success = love.filesystem.write("data.txt", "Data:\r\n", 7)
  if success == nil then
    print("Cannot write to file.")
    love.event.quit()
  end
  print("/* Trials | Hits / Pi Estimation (//) */")
  -- Nice blue shade.
  love.graphics.setBackgroundColor(144, 195, 212)
end

function slope(x1, y1, x2, y2)
  return (y2 - y1) / (x2 - x1)
end

function getx2andy2(x1, y1, x3, y3, distance)
  local slope = slope(x1, y1, x3, y3)
  -- Proved in another document, distance formula reworked.
  local x2 = (distance / math.sqrt((slope^2) + 1)) + x1
  -- Proved in another document, point-slope reworked.
  local y2 = (slope * (x2 - x1)) + y1
  if x2 < 2 or y2 < 2 or x2 > (screen.width - 2) or y2 > (screen.height - 2) then
    x2 = ((-1 * distance) / math.sqrt((slope^2) + 1)) + x1
    y2 = (slope * (x2 - x1)) + y1
  end
  return {x2, y2}
end

function generateRandomLine()
  local newLine = #randomLines.index + 1
  randomLines.index[newLine] = {}

  randomLines.index[newLine].x1 = love.math.random(2, screen.width - 1)
  randomLines.index[newLine].y1 = love.math.random(2, screen.height - 1)

  randomLines.index[newLine].temp_x3 = love.math.random(2, screen.width - 1)
  randomLines.index[newLine].temp_y3 = love.math.random(2, screen.height - 1)

  point2 = getx2andy2(
    randomLines.index[newLine].x1,
    randomLines.index[newLine].y1,
    randomLines.index[newLine].temp_x3,
    randomLines.index[newLine].temp_y3,
    randomLines.size)

  randomLines.index[newLine].x2 = point2[1]
  randomLines.index[newLine].y2 = point2[2]
end

function doesRandomLineHit()
  local currentLine = randomLines.index[#randomLines.index]
  for i = 1, #parallelLines.index do
    local parallelLine = parallelLines.index[i]
    if currentLine.x1 <= parallelLine and currentLine.x2 >= parallelLine then
      return true
    end
  end
  return false
end

function love.update(dt)
  generateRandomLine()

  if doesRandomLineHit() == true then
    amountOfHits = amountOfHits + 1
  end
  local success, errormsg = love.filesystem.append(
    "data.txt",
    #randomLines.index..", "..amountOfHits.."\r\n",
    string.len(tostring(#randomLines.index)..tostring(amountOfHits)) + 4)
  if success == nil then
    print(errormsg)
    love.event.quit()
  end
  print(#randomLines.index..", "..amountOfHits)

  if math.mod(#randomLines.index, 10) == 0 then
    estimationOfPi = (#randomLines.index / amountOfHits) * 2

    local success, errormsg = love.filesystem.append(
      "data.txt",
      "// "..#randomLines.index..", "..estimationOfPi.."\r\n",
      string.len(tostring(#randomLines.index)..tostring(estimationOfPi)) + 7)
    if success == nil then
      print(errormsg)
      love.event.quit()
    end
    print("// "..#randomLines.index..", "..estimationOfPi)
  end
end

function love.draw()
  -- outline (black)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("line", 1, 1, screen.width - 2, screen.height - 2)
  -- parallel lines (grey)
  love.graphics.setColor(64, 64, 64)
  for i = 1, #parallelLines.index do
    love.graphics.line(parallelLines.index[i], 2, parallelLines.index[i], screen.height - 1)
  end
  -- random lines (red)
  love.graphics.setColor(212, 144, 144)
  for i = 1, #randomLines.index do
    love.graphics.line(
      randomLines.index[i].x1,
      randomLines.index[i].y1,
      randomLines.index[i].x2,
      randomLines.index[i].y2)
  end
  love.timer.sleep(0.1)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

