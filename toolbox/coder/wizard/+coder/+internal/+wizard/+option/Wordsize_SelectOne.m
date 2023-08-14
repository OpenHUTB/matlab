classdef Wordsize_SelectOne<coder.internal.wizard.OptionBase
    methods
        function obj=Wordsize_SelectOne(env)
            id='Wordsize_SelectOne';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Optimization';
            obj.Type='radio';
            obj.Value=false;
        end
        function onNext(~)
        end
    end
end
