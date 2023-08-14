



classdef ImportCompFromArxml_ModelPeriodicRunnablesAs<autosar.ui.app.base.OptionBase
    methods
        function obj=ImportCompFromArxml_ModelPeriodicRunnablesAs(env)





            id='ImportCompFromArxml_ModelPeriodicRunnablesAs';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='combobox';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiImporterModelPeriodicRunnablesAs');
            obj.Value={'Auto','AtomicSubsystem','FunctionCallSubsystem'};
            obj.Answer='Auto';


            obj.DepInfo=struct('Option','ImportCompFromArxml_Modeling','Value',true);
            obj.Indent=1;
        end
    end
end


