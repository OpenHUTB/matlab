classdef Application<SimulinkFixedPoint.DataTypingServices.AbstractAction
















    methods(Access=public)
        function this=Application(sysToScaleName,refMdls,proposalSettings)
            this.sysToScaleName=sysToScaleName;
            this.refMdls=refMdls;
            this.proposalSettings=proposalSettings;
        end

        execute(this)
    end

    methods(Access=public,Hidden)
        scale_apply(this,bd,mdl,runObj)
    end
end


