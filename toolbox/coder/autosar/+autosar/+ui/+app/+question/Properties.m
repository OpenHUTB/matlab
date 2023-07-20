



classdef Properties<autosar.ui.app.base.QuestionBase

    properties
        HelpViewID='autosar_build_component_ar_properties';
    end

    methods
        function obj=Properties(env)






            id='Properties';
            topic=DAStudio.message('autosarstandard:ui:uiWizardPropertiesTopic');

            obj@autosar.ui.app.base.QuestionBase(id,topic,env);


            obj.getAndAddOption('Properties_Default');
            obj.getAndAddOption('Properties_Import');
            obj.getAndAddOption('Properties_Arxml');


            obj.configureLookAndFeelForComponent();

            if env.IsModelLinker


                obj.DisplayFixAllButton=true;
            else

                obj.NextQuestionId='Finish';
            end
        end

        function onChange(obj)

            env=obj.Env;

            if~isempty(env.LastAnswer)&&isa(env.LastAnswer.Value,'struct')
                answers=env.LastAnswer.Value;

                obj.Options{1}.Answer=answers(1).value;
                obj.Options{2}.Answer=answers(2).value;
                if answers(2).value


                    obj.refreshOnFileSelection('Properties_Arxml');
                end
            end
        end


        function configureLookAndFeelForComponent(obj)

            defaultOption=obj.Options(cellfun(@(x)strcmp(x.Id,'Properties_Default'),obj.Options));
            importOption=obj.Options(cellfun(@(x)strcmp(x.Id,'Properties_Import'),obj.Options));
            defaultOption{1}.Answer=true;
            importOption{1}.Answer=false;


            interfaceDictName=obj.Env.InterfaceDictName;
            if isempty(interfaceDictName)
                obj.QuestionMessage=DAStudio.message('autosarstandard:ui:uiWizardAutosarProperties');
                obj.HintMessage=DAStudio.message('autosarstandard:ui:uiWizardAutosarPropertiesHelp');
            else
                modelName=getfullname(obj.Env.ModelHandle);
                obj.QuestionMessage=DAStudio.message('autosarstandard:ui:uiWizardAutosarPropertiesInterfaceDict',...
                modelName,interfaceDictName);
                obj.HintMessage=DAStudio.message('autosarstandard:ui:uiWizardAutosarPropertiesInterfaceDictHelp');
            end
        end


        function configureLookAndFeelForSubComponent(obj)

            defaultOption=obj.Options(cellfun(@(x)strcmp(x.Id,'Properties_Default'),obj.Options));
            importOption=obj.Options(cellfun(@(x)strcmp(x.Id,'Properties_Import'),obj.Options));
            defaultOption{1}.Answer=false;
            importOption{1}.Answer=true;


            obj.QuestionMessage=DAStudio.message('autosarstandard:ui:uiWizardAutosarPropertiesSubComponent');
            obj.HintMessage=DAStudio.message('autosarstandard:ui:uiWizardImportPropertiesHelp');
        end

        function ret=onNext(obj)


            ret=0;
            for i=1:length(obj.Options)
                ret=obj.Options{i}.applyOnNext();
                if ret<0
                    return
                end
            end
        end
    end
end



