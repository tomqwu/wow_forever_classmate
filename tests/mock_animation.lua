-- A minimal native-animation test double; no addon warning decisions live here.
return function(methods)
    function methods:CreateAnimationGroup()
        local group={animations={},plays=0,stops=0,playing=false}
        self.warningPulseGroup=group
        function group:CreateAnimation(kind)
            local a={kind=kind}
            function a:SetFromAlpha(v) self.from=v end
            function a:SetToAlpha(v) self.to=v end
            function a:SetDuration(v) self.duration=v end
            function a:SetOrder(v) self.order=v end
            self.animations[#self.animations+1]=a
            return a
        end
        function group:SetLooping(value) self.looping=value end
        function group:IsPlaying() return self.playing end
        function group:Play() self.plays=self.plays+1;self.playing=true end
        function group:Stop() self.stops=self.stops+1;self.playing=false end
        return group
    end
end
