Gesture = class()

-- Represents a set of TouchX's and aggregated metrics. Serves as interface for
-- dealing with multi-touch gestures. Managed by a TouchContext

function Gesture:init(touchxes)
   self.state = BEGAN
   self._touchxesSet = Set(touchxes)
   self._touchxes = self._touchxesSet:toTable()
   self.n = #self._touchxes
   self._refAngle = self:getAngle()
   self:update()
   self.initCentroid = self.centroid
   self.initDist = self.dist
end

function Gesture:contains(touchx)
   return self._touchxesSet:contains(touchx)
end

function Gesture:getAngle()
   local p1 = self._touchxes[1].pos
   local p2 = self._touchxes[2].pos
   return _e1:angleBetween(p2 - p1) % (2 * math.pi)
end

function Gesture:update()
   -- Ended gestures are not updated and return nil
   if self.state == ENDED then return end
   self.state = CHANGED
   -- Set up calculation
   local posSum = vec2(0, 0)
   local maxDist = 0
   local other, dist
   -- Collect data across touches
   for i, touchx in ipairs(self._touchxes) do
      -- Update status
      if touchx.state == ENDED or touchx.state == CANCELLED then
         self.state = ENDED
         log("Gesture ended")
         return
      end
      -- Continue calculations
      posSum = posSum + touchx.pos
      for j = i + 1, self.n do
         other = self._touchxes[j]
         dist = touchx.pos:dist(other.pos)
         maxDist = math.max(dist, maxDist)
      end
   end
   -- Update attributes
   self.prevCentroid = self.centroid
   self.centroid = posSum / self.n
   self.travel = self.centroid - (self.initCentroid or self.centroid)
   self.delta = self.centroid - (self.prevCentroid or self.centroid)
   self.dist = maxDist
   self.angle = (self:getAngle() - self._refAngle) % (2 * math.pi)
end
