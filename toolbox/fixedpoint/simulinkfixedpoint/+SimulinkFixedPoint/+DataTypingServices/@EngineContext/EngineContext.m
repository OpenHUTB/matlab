classdef EngineContext<handle









    properties(Constant,Hidden)
        invalidActionMessageID='SimulinkFixedPoint:autoscaling:commandNotFound';
        invalidSUDMessageID='SimulinkFixedPoint:autoscaling:topSubsysNotValid';
        SUDNotUnderTopMessageID='SimulinkFixedPoint:autoscaling:sudNotUnderTop';
        topModelNotLoadedMessageID='SimulinkFixedPoint:autoscaling:ModelNotLoaded';
    end

    properties(SetAccess=private)
topModel
systemUnderDesign
proposalSettings
action
    end

    properties(SetAccess=private,Hidden)
topModelModelReferences
systemUnderDesignModelReferences
simIn
    end

    methods
        function this=EngineContext(topModel,systemUnderDesign,proposalSettings,action,simIn)
            if nargin<5||isempty(simIn)
                this.simIn=Simulink.SimulationInput(bdroot(topModel));
            else
                this.simIn=simIn;
            end


            this.topModel=SimulinkFixedPoint.AutoscalerUtils.repnewline(topModel);
            this.systemUnderDesign=SimulinkFixedPoint.AutoscalerUtils.repnewline(systemUnderDesign);
            this.proposalSettings=proposalSettings;
            this.action=action;


            this.getModelReferences();


            this.performSanityChecks();


            this.setupContext();
        end
    end

    methods(Access=public,Hidden)
        getModelReferences(this);
        setupContext(this);
        performSanityChecks(this);
    end
end


