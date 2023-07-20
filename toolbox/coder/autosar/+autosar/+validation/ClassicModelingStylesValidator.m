classdef ClassicModelingStylesValidator<autosar.validation.PhasedValidator





    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyNoMessageTriggeredSubsystems(hModel);
        end
    end

    methods(Static,Access=private)
        function verifyNoMessageTriggeredSubsystems(hModel)







            msgTriggeredSSBlks=...
            autosar.simulink.msgTrigSS.Utils.findMessageTriggeredSubsystems(hModel);

            if~isempty(msgTriggeredSSBlks)
                modelName=get_param(hModel,'Name');
                slFuncBlkPaths=...
                autosar.validation.AutosarUtils.getFullBlockPathsForError(msgTriggeredSSBlks);
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:MsgTriggeredSSClassic',...
                modelName,slFuncBlkPaths);
            end
        end
    end
end


