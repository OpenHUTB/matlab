classdef Start_Continue<simulinkcoder.internal.wizard.OptionBase
    methods
        function obj=Start_Continue(env)
            id='Start_Continue';
            obj@simulinkcoder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Flavor';
            obj.Type='hidden';
            obj.Value=true;
            obj.DepInfo='';
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
    end
end
