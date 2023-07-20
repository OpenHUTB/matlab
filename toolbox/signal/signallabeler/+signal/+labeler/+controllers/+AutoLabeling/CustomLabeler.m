

classdef CustomLabeler<signal.labeler.controllers.AutoLabeling.LabelerActionBase

    properties(Hidden)
        Method;
    end
    methods(Hidden)
        function this=CustomLabeler(model,setupData)

            this@signal.labeler.controllers.AutoLabeling.LabelerActionBase(model,setupData);
            this.Method=setupData.lablerInfo.functionName;
        end

        function nameValuePairCellArray=getLabelerSettingsArguments(this)
            nameValuePairCellArray={};
            if~isempty(this.LabelerSettings.Arguments)
                nameValuePairCellArray=signal.sigappsshared.Utilities.parseCommaSeperateString(this.LabelerSettings.Arguments);
            end
        end

        function y=getFunctionHandle(this,~)
            y=str2func(this.Method);
        end
    end
end

