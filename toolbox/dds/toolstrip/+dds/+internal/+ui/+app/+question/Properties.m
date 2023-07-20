



classdef Properties<dds.internal.ui.app.base.QuestionBase

    properties
        HelpViewID='DDS_Wizard_AssociateDictionary';
    end

    methods
        function obj=Properties(env)






            id='Properties';
            topic=DAStudio.message('dds:toolstrip:uiWizardPropertiesTopic');

            obj@dds.internal.ui.app.base.QuestionBase(id,topic,env);


            obj.getAndAddOption('Properties_Dictionary');
            obj.getAndAddOption('Properties_SLDD');
            obj.getAndAddOption('Properties_Import');
            obj.getAndAddOption('Properties_Xml');
            obj.getAndAddOption('Properties_Default');


            obj.configureLookAndFeelForComponent();



            obj.NextQuestionId='Finish';
        end

        function onChange(obj)

            env=obj.Env;

            if~isempty(env.LastAnswer)&&isa(env.LastAnswer.Value,'struct')
                answers=env.LastAnswer.Value;

                obj.Options{1}.Answer=answers(1).value;
                obj.Options{3}.Answer=answers(3).value;
                obj.Options{5}.Answer=answers(5).value;
                if answers(1).value


                    obj.refreshOnFileSelection('Properties_SLDD');
                    obj.IsNextEnabled=~isempty(answers(2).value);
                elseif answers(3).value


                    obj.refreshOnFileSelection('Properties_Xml');
                    obj.IsNextEnabled=~isempty(answers(4).value);
                elseif answers(5).value
                    obj.IsNextEnabled=true;
                else
                    obj.IsNextEnabled=false;
                end
            end
        end


        function configureLookAndFeelForComponent(obj)

            dictOption=obj.Options(cellfun(@(x)strcmp(x.Id,'Properties_Dictionary'),obj.Options));
            importOption=obj.Options(cellfun(@(x)strcmp(x.Id,'Properties_Import'),obj.Options));
            defaultOption=obj.Options(cellfun(@(x)strcmp(x.Id,'Properties_Default'),obj.Options));
            dictOption{1}.Answer=true;
            importOption{1}.Answer=false;
            defaultOption{1}.Answer=false;
            obj.IsNextEnabled=~isempty(obj.Env.DDConn);


            obj.QuestionMessage=DAStudio.message('dds:toolstrip:uiWizardDDSProperties');
            obj.HintMessage=DAStudio.message('dds:toolstrip:uiWizardDDSPropertiesHelp');
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



