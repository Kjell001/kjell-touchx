TouchX = class()

-- An extension of the standard touch entity. Provides extra metrics and persists
-- as an instance throughout the lifetime of a touch.
local test = nil

function TouchX:init(touch)
   self.id = touch.id
   self.initPos = touch.pos
   self.traversed = 0
   self:updateAttributes(touch)
   self.initTimestamp = os.time()
end

function TouchX:updateAttributes(touch)
   assert(touch.id == self.id, "Can't update TouchX with different id")
   -- Basic attributes
   self.state = touch.state
   self.pos = touch.pos
   self.prevPos = touch.prevPos
   self.delta = touch.delta
   self.tapCount = touch.tapCount
   -- Calculated attributes
   self.travel = self.pos - self.initPos
   self.traversed = self.traversed + self.delta:len() 
   self.angle = _e1:angleBetween(self.travel)
   return self
end

function TouchX:getDuration()
   return os.difftime(os.time(), self.initTimestamp)
end
