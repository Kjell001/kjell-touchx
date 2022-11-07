PinchPanCanvas = class()

function PinchPanCanvas:init(x)
   self.offset = vec2(0, 0)
   self.offsetVelocity = vec2(0, 0)
   self.offsetDamping = 30
   self.scale = 1
   self.angle = 0
   self.allowPanX = true
   self.allowPanY = true
   self.allowZoom = true
   self.allowRotate = true
end

function PinchPanCanvas:disablePanningX()
   self.allowPanX = false
end

function PinchPanCanvas:enablePanningX()
   self.allowPanX = true
end

function PinchPanCanvas:disablePanningY()
   self.allowPanY = false
end

function PinchPanCanvas:enablePanningY()
   self.allowPanY = true
end

function PinchPanCanvas:disableZooming()
   self.allowZoom = false
end

function PinchPanCanvas:enableZooming()
   self.allowZoom = true
end

function PinchPanCanvas:disableRotation()
   self.allowRotate = false
end

function PinchPanCanvas:enableRotation()
   self.allowRotate = true
end

function PinchPanCanvas:update()
   
end

function PinchPanCanvas:draw()
   background(32, 32, 64)
   pushMatrix()
   translate(self.offset.x, self.offset.y)
   rotate(math.deg(self.angle))
   scale(self.scale)
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
   if self.gesture then
      local p = self.gesture.centroid
      local rv = p + self.refVector
      local v = p + self.vector
      fill(255)
      ellipse(p.x, p.y, 10)
      strokeWidth(1)
      stroke(255, 127)
      for t in self.gesture._touchxesSet:items() do
         line(t.pos.x, t.pos.y, p.x, p.y)
      end
      stroke(255, 0, 0)
      line(p.x, p.y, rv.x, rv.y)
      stroke(255)
      line(p.x, p.y, v.x, v.y)
   end
   popStyle()
end

function PinchPanCanvas:isTouched(touchx)
   return true
end

function PinchPanCanvas:defineGesture(context)
   self.gesture = context:defineGesture(1, 2)
   self.vector = self.offset - self.gesture.centroid
   self.refVector = self.vector
   self.refScale = self.scale
   self.refOffset = self.offset
   self.refAngle = self.angle
end

function PinchPanCanvas:removeGesture()
   self.gesture = nil
end

function PinchPanCanvas:setOffset(newOffset)
   if self.allowPanX then self.offset.x = newOffset.x end
   if self.allowPanY then self.offset.y = newOffset.y end
end

function PinchPanCanvas:adjustOffset(deltaOffset)
   self:setOffset(self.offset + deltaOffset)
end

function PinchPanCanvas:setScale(newScale)
   if not self.allowZoom then return end
   self.scale = newScale
end

function PinchPanCanvas:setAngle(newAngle)
   if not self.allowRotate then return end
   self.angle = newAngle % (2 * math.pi)
end

function PinchPanCanvas:manipulate(touchx, context)
   -- Pan with single touch
   if context.n <= 1 then
      if touchx.state == CHANGED then
         -- Translation
         self:adjustOffset(touchx.delta)
      end
   end
   -- Pan, pinch-zoom and pinch-rotate with two-touch gesture
   if self.gesture and self.gesture:contains(touchx) then
      if self.gesture.state == ENDED then
         self:removeGesture()
      elseif self.gesture.state == CHANGED then
         local gestureDelta = self.gesture.delta
         local gestureScale = self.gesture.dist / self.gesture.initDist
         -- Zoom
         self:setScale(self.refScale * gestureScale)
         -- Rotation
         self:setAngle(self.refAngle + self.gesture.angle)
         -- Translation
         self.vector = (gestureScale * self.refVector):rotate(self.gesture.angle)
         self:setOffset(self.gesture.centroid + self.vector)
      end
   end
   -- Define gesture if enough touches and no gesture exists
   if context.n >= 2 and not self.gesture then
      self:defineGesture(context)
   end
end

function PinchPanCanvas:touched(touchx, context)
   self:manipulate(touchx, context)
end
