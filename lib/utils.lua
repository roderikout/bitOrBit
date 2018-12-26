--20-11-2017

local Utils = {}

function Utils.norm(value, min, max) -- Normaliza un valor entre dos límites X y Y a un valor entre 0 y 1
  return (value - min) / (max - min)
end

function Utils.lerp(norm, min, max) -- Inverso a norm(), devuelve un valor entre los límites X y Y ingresando un valor entre 0 y 1
  return (max - min) * norm + min
end

function Utils.map(value, sourceMin, sourceMax, destMin, destMax) -- Mezcla de norm() y lerp(). Traslada un valor entre X y Y a un valor entre A y B
  return Utils.lerp(Utils.norm(sourceMin, sourceMax), destMin, destMax)
end

function Utils.clamp(value, min, max) -- Limita un valor a que no se pase de los límites mínimo y máximo
  return math.min(math.max(value, min), max)
end

function Utils.randomRange(min, max) -- Da un número aleatorio entre un valor mínimo y un máximo
  return min + (love.math.random() * (max - min))
end

function Utils.randomInt(min, max) -- Da un número aleatorio entre un valor mínimo y un máximo
    return min + (love.math.random() * (max - min + 1))
end

function Utils.round(n, deci)
    deci = 10^(deci or 0) 
    return math.floor(n*deci+.5)/deci
end

function Utils.roundToPlaces(value, places) -- Redondea un numero de decimales al deseado. p.ej> rTP(10,45566334, 3) => 10,455
  local mult = math.pow(10, places)
  return math.floor(value * mult) / mult
end

function Utils.roundToNeares(value, nearest) --Redondea al numero más cercano en un rango
  return math.floor(value/nearest) * nearest
end

function Utils.randomDist(min, max, iterations) --Da un valor aleatorio en rango medio normal dentro de la campana de gauss de los valores min y max
  local total = 0
  for i=0, iterations, 1 do
    total = total + Utils.randomRange(min, max)
  end
  return total / iterations
end

function Utils.intersect(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y) -- busca si los vectores (p0, p1) y (p2,p3) se intersectan en algún punto
  local a1 = p1y - p0y
  local b1 = p0x - p1y
  local c1 = a1 * p0x + b1 * p0y
  local a2 = p3y - p2y
  local b2 = p2x - p3y
  local c2 = a2 * p2x + b2 * p2y

  local denominator = a1 * b2 - a2 * b1

  if denominator == 0 then
    return nil
  end

  return {x = (b2 * c1 - b1 * c2) / denominator, y = (a1 * c2 - a2 * c1) / denominator}

end

function Utils.intersectSegment(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y) -- busca si los segmentos de vectores (p0, p1) y (p2,p3) se intersectan en algún punto
  local a1 = p1y - p0y
  local b1 = p0x - p1x
  local c1 = a1 * p0x + b1 * p0y
  local a2 = p3y - p2y
  local b2 = p2x - p3x
  local c2 = a2 * p2x + b2 * p2y

  local denominator = a1 * b2 - a2 * b1

  if denominator == 0 then
    return nil
  end

  intersectX = (b2 * c1 - b1 * c2) / denominator
  intersectY = (a1 * c2 - a2 * c1) / denominator

  rx0 = (intersectX - p0x) / (p1x - p0x)
  ry0 = (intersectY - p0y) / (p1y - p0y)
  rx1 = (intersectX - p2x) / (p3x - p2x)
  ry1 = (intersectY - p2y) / (p3y - p2y)

  if ((rx0 >= 0 and rx0 <= 1) or (ry0 >= 0 and rx0 <= 1)) and ((rx1 >= 0 and rx1 <= 1) or (ry1 >= 0 and ry1 <= 1)) then
    return {x = intersectX, y = intersectY}
  else
    return nil
  end
end

function Utils.tableCount(tt, item) -- cuenta la cantidad de elementos repetidos en una tabla
  local count
  count = 0
  for ii,xx in pairs(tt) do
    if item == xx then count = count + 1 end
  end
  return count
end

function Utils.tableUnique(tt) -- remueve duplicados de una tabla array (no funciona con tablas clave - valor)
  local newtable
  newtable = {}
  for ii,xx in ipairs(tt) do
    if(Utils.table_count(newtable, xx) == 0) then
      newtable[#newtable+1] = xx
    end
  end

  return newtable
end

function Utils.distanceTo(x1, y1, x2, y2)
  local distX = x1 - x2
  local distY = y1 - y2
  local distToCenter = math.sqrt((distX * distX) + (distY * distY))
  local angleToCenter = math.atan2(distY, distX)
  return distToCenter, distX, distY, angleToCenter
end

function Utils.has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

return Utils