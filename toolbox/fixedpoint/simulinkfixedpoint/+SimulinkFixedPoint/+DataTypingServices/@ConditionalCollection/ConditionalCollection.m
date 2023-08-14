classdef ConditionalCollection<SimulinkFixedPoint.DataTypingServices.Collection







    methods(Access=public)
        function this=ConditionalCollection(sysToScaleName,refMdls,proposalSettings)
            this=this@SimulinkFixedPoint.DataTypingServices.Collection(sysToScaleName,refMdls,proposalSettings);
        end

    end

    methods(Access=public,Hidden=true)
        performCollection(this)
    end
end