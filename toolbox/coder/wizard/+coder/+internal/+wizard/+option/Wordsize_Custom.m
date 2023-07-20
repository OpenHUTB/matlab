classdef Wordsize_Custom<coder.internal.wizard.OptionBase
    methods
        function obj=Wordsize_Custom(env)
            id='Wordsize_Custom';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Optimization';
            obj.Type='radio';
            obj.Value=false;
        end
        function onNext(~)

        end
    end
end
