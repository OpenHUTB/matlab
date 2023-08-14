

classdef Wordsize_HardwareFamily<coder.internal.wizard.OptionBase
    methods
        function obj=Wordsize_HardwareFamily(env)
            id='Wordsize_HardwareFamily';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Optimization';
            obj.Type='combobox';
            obj.HasHintMessage=false;
        end
        function onNext(~)
        end
    end
end


