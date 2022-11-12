-- LuaKjell

function setup()
   DEBUG = true
   viewer.mode = STANDARD
   
   tc = TouchController()
   --testTC()
   sponge = Sponge()
   tc:addInstance(sponge)
end

function draw()
   tc:update()
   -- Draw debug canvas
   background(32, 32, 64)
   pushMatrix()
   translate(sponge:getOffset():unpack())
   rotate(math.deg(sponge:getAngle()))
   scale(sponge:getScale())
   pushStyle()
   noStroke()
   ellipseMode(RADIUS)
   fill(255, 0, 0)
   ellipse(0, 0, 20)
   fill(0, 255, 0)
   ellipse(200, 0, 20)
   fill(0, 0, 255)
   ellipse(0, 200, 20)
   popMatrix()
   -- Debug graphics
   local gesture = sponge:getGesture()
   if gesture then
      local p = gesture.centroid
      local rv = p + sponge.refVector
      local v = p + sponge.vector
      fill(255)
      ellipse(p.x, p.y, 10)
      strokeWidth(1)
      stroke(255, 127)
      for t in gesture._touchxesSet:items() do
         line(t.pos.x, t.pos.y, p.x, p.y)
      end
      stroke(255, 0, 0)
      line(p.x, p.y, rv.x, rv.y)
      stroke(255)
      line(p.x, p.y, v.x, v.y)
   end
   popStyle()
end

function touched(touch)
   tc:touched(touch)
end

function testTC()
   local f = function(x, y) print("HODOR!!", x, y) end
   
   inst1 = {}
   function inst1:isTouched(touch)
      return touch.pos.y > HEIGHT / 2
   end
   function inst1:touched(touch, context)
      if touch.state == BEGAN then
         print("Touched 1 at", touch.timestamp)
         context:setHoldCallback(touch, f, 3, 10, touch.tapCount, context.n)
      elseif touch.state == ENDED then
         
      end
   end
   tc:addInstance(inst1)
   
   inst2 = {}
   function inst2:isTouched(touch)
      return touch.pos.x > WIDTH / 2
   end
   function inst2:touched(touch, context)
      if touch.state == BEGAN then
         print("Touched 2 at", touch.pos)
      elseif touch.state == ENDED then
         print("Travel 2", touch.travel)
      end
   end
   --tc:addInstance(inst2)
end
