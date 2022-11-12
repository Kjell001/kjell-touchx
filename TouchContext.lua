TouchContext = class()

-- Wrapper around an instance to manage associated touches. Allows for defining
-- 'gestures', which provide an easy interface with multi-touch gestures.

function TouchContext:init(instance)
   self.instance = instance
   self.touchxIndex = {}
   self.gestures = WeakSet()
   self.n = 0
   self.callbacks = {}
end

function TouchContext:setIndex(touchx, index)
   self.touchxIndex[touchx] = index
end

function TouchContext:resetIndex(touchx)
   self.touchxIndex[touchx] = nil
end

function TouchContext:getIndex(touchx)
   return self.touchxIndex[touchx]
end

-- Manage TouchXs in context
function TouchContext:logIndices()
   log("Context indices:")
   for t, index in pairs(self.touchxIndex) do
      log("", index, t.id)
   end
end

function TouchContext:addTouchX(touchx)
   self.n = self.n + 1
   self:setIndex(touchx, self.n)
end

function TouchContext:removeTouchX(touchx)
   -- Redetermine indices
   local refIndex = self:getIndex(touchx)
   self:resetIndex(touchx)
   for t, index in pairs(self.touchxIndex) do
      self:setIndex(t, index > refIndex and index - 1 or index)
   end
   self.n = self.n - 1
   -- Clear callbacks
   self:removeCallback(touchx)
end

function TouchContext:getTouchX(index)
   assert(index <= self.n, "Index greater than amount of touches in context")
   for touchx, i in pairs(self.touchxIndex) do
      if i == index then return touchx end
   end
end

-- Manage Gestures in context
function TouchContext:addGesture(gesture)
   self.gestures:add(gesture)
end

function TouchContext:defineGesture(...)
   local touchxes = {}
   for i, index in ipairs(table.pack(...)) do
      table.insert(touchxes, self:getTouchX(index))
   end
   local gesture = Gesture(touchxes)
   self:addGesture(gesture)
   return gesture
end

-- Process TouchX in context
function TouchContext:isTouched(touchx)
   return self.instance:isTouched(touchx)
end

function TouchContext:touched(touchx, ...)
   -- Add touch if new
   if not self:getIndex(touchx) then self:addTouchX(touchx) end
   -- Remove ended touches
   if touchx.state == ENDED or touchx.state == CANCELLED then
      self:removeTouchX(touchx)
   end
   -- Update gestures
   for gesture in self.gestures:items() do
      if gesture:contains(touchx) then
         gesture:update()
      end
   end
   -- Relay touch to instance
   self.instance:touched(touchx, self, ...)
end

-- Manage time-based features
function TouchContext:setHoldCallback(touchx, func, wait, tolerance, ...)
   local callback = {
      func = func,
      wait = wait,
      tolerance = tolerance or 0,
      arg = {...}
   }
   self.callbacks[touchx] = callback
end

function TouchContext:removeCallback(touchx)
   self.callbacks[touchx] = nil
end

function TouchContext:update()
   for touchx, callback in pairs(self.callbacks) do
      if touchx:getDuration() >= callback.wait and touchx.tapCount == 1 then
         if touchx.travel:len() <= callback.tolerance then
            callback.func(table.unpack(callback.arg))
            log("Callback on touch", touchx.id)
         end
         self:removeCallback(touchx)
      end
   end
end
