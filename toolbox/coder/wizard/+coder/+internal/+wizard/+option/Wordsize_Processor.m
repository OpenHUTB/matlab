

classdef Wordsize_Processor<coder.internal.wizard.OptionBase
    methods
        function obj=Wordsize_Processor(env)
            id='Wordsize_Processor';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Optimization';
            obj.Type='combobox';
            obj.HasHintMessage=false;
        end
        function onNext(~)
        end
    end
end


