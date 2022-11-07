
_e1 = vec2(1, 0)

TouchController = class()

-- Facilitates managing touches in separated 'contexts'. Each context represents
-- an instance and a group of touches interacting with that instance only.
-- Instances should have an 'isTouched' method for it be managed by the controller.

function TouchController:init()
   self.touchxes = {}
   self.contexts = {}
   self.contextMap = {}
end

function TouchController:addInstance(instance)
   table.insert(self.contexts, TouchContext(instance))
end

function TouchController:insertInstance(instance, position)
   table.insert(self.contexts, position, TouchContext(instance))
end

-- Manage TouchXs
function TouchController:addTouchX(touchx)
   self.touchxes[touchx.id] = touchx
end

function TouchController:removeTouchX(touchx)
   self.touchxes[touchx.id] = nil
   self.contextMap[touchx] = nil
end

function TouchController:getTouchX(touch)
   -- Fetch existing TouchX
   local touchx = self.touchxes[touch.id]
   if touchx then
      touchx:updateAttributes(touch)
   else
      -- Create and store new TouchX
      touchx = TouchX(touch)
      self:addTouchX(touchx)
   end
   return touchx
end

-- Manage Contexts
function TouchController:assignContext(touchx, context)
   local contexts = self.contextMap[touchx]
   table.insert(contexts, context)
end

function TouchController:getContexts(touchx)
   -- Fetch assigned context
   local contexts = self.contextMap[touchx]
   if contexts then return contexts end
   -- No assigned contexts, determine appropriate contexts from isTouched methods
   self.contextMap[touchx] = {}
   local isTouched, fallThrough
   for i, context in ipairs(self.contexts) do
      isTouched, fallThrough = context:isTouched(touchx)
      if isTouched then
         self:assignContext(touchx, context)
         if not fallThrough then break end
      end
   end
   return self.contextMap[touchx]
end

function TouchController:update()
   for i, context in ipairs(self.contexts) do
      context:update()
   end
end

-- Process touches
function TouchController:touched(touch, ...)
   local touchx = self:getTouchX(touch)
   local contexts = self:getContexts(touchx)
   for i, context in ipairs(contexts) do
      context:touched(touchx, ...)
   end
   if touchx.state == ENDED or touchx.state == CANCELLED then
      self:removeTouchX(touchx)
   end
end
