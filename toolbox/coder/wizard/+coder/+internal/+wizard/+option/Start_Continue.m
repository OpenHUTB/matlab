classdef Start_Continue<coder.internal.wizard.OptionBase
    methods
        function obj=Start_Continue(env)
            id='Start_Continue';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='System';
            obj.Type='hidden';
            obj.Value=true;
            obj.DepInfo='';
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
    end
end
