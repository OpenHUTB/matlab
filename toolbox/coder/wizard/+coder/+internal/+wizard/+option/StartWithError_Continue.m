classdef StartWithError_Continue<coder.internal.wizard.OptionBase
    methods
        function obj=StartWithError_Continue(env)
            id='StartWithError_Continue';
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
