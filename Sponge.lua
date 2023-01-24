Sponge = class()

function Sponge:init()
   self:resetOffset()
   self:resetScale()
   self:resetAngle()
   self:enableMoveX()
   self:enableMoveY()
   self:enableZoom()
   self:enableRotate()
end

function Sponge:setOffset(newOffset)
   if self.allowMoveX then self.offset.x = newOffset.x end
   if self.allowMoveY then self.offset.y = newOffset.y end
end

function Sponge:adjustOffset(deltaOffset)
   self:setOffset(self.offset + deltaOffset)
end

function Sponge:getOffset()
   return self.offset
end

function Sponge:resetOffset()
   self.offset = vec2(0, 0)
end

function Sponge:setScale(newScale)
   self.scale = newScale
end

function Sponge:getScale()
   return self.scale
end

function Sponge:resetScale()
   self.scale = 1
end

function Sponge:setAngle(newAngle)
   self.angle = newAngle % (2 * math.pi)
end

function Sponge:getAngle()
   return self.angle
end

function Sponge:resetAngle()
   self.angle = 0
end

function Sponge:defineGesture(context)
   self.gesture = context:defineGesture(1, 2)
   self.vector = self.offset - self.gesture.centroid
   self.refVector = self.vector
   self.refScale = self.scale
   self.refOffset = self.offset
   self.refAngle = self.angle
end

function Sponge:getGesture()
   return self.gesture
end

function Sponge:removeGesture()
   self.gesture = nil
end

function Sponge:disableMoveX()
   self.allowMoveX = false
end

function Sponge:enableMoveX()
   self.allowMoveX = true
end

function Sponge:disableMoveY()
   self.allowMoveY = false
end

function Sponge:enableMoveY()
   self.allowMoveY = true
end

function Sponge:disableZoom()
   self.allowZoom = false
end

function Sponge:enableZoom()
   self.allowZoom = true
end

function Sponge:disableRotate()
   self.allowRotate = false
end

function Sponge:enableRotate()
   self.allowRotate = true
end

function Sponge:isTouched(touchx)
   return true
end

function Sponge:manipulate(touchx, context)
   -- Move with single touch
   if context.n <= 1 then
      if touchx.state == CHANGED then
         -- Translation
         self:adjustOffset(touchx.delta)
      end
   end
   -- Move, pinch-zoom and pinch-rotate with two-touch gesture
   if self.gesture and self.gesture:contains(touchx) then
      if self.gesture.state == ENDED then
         self:removeGesture()
      elseif self.gesture.state == CHANGED then
         self.vector = self.refVector
         -- Zoom
         if self.allowZoom then
            local gestureScale = self.gesture.dist / self.gesture.initDist
            self:setScale(self.refScale * gestureScale)
            self.vector = self.vector * gestureScale
         end
         -- Rotation
         if self.allowRotate then
            self:setAngle(self.refAngle + self.gesture.angle)
            self.vector = self.vector:rotate(self.gesture.angle)
         end
         -- Translation
         self:setOffset(self.gesture.centroid + self.vector)
      end
   end
   -- Define gesture if enough touches and no gesture exists
   if context.n > 1 and not self.gesture then
      self:defineGesture(context)
   end
end

function Sponge:touched(touchx, context)
   self:manipulate(touchx, context)
end
