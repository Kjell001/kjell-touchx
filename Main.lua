-- LuaKjell

function setup()
   DEBUG = true
   viewer.mode = STANDARD
   
   tc = TouchController()
   testTC()
   canvas = PinchPanCanvas()
   tc:addInstance(canvas)
end

function draw()
   background(28)
   tc:update()
   canvas:update()
   canvas:draw()
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
