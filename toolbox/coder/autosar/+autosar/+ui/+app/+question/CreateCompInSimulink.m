



classdef CreateCompInSimulink<autosar.ui.app.base.QuestionBase

    properties(Access=private,Constant)
        UndefinedString='<Undefined>';
        HelpViewIDForComponent='autosar_importer_app_component_create_options';
        HelpViewIDForComposition='autosar_importer_app_composition_create_options';
    end

    properties
        HelpViewID;
    end

    methods

        function val=get.HelpViewID(obj)
            if isa(obj.Env,'autosar.ui.app.import.ComponentImportWizard')
                val=obj.HelpViewIDForComponent;
            else
                val=obj.HelpViewIDForComposition;
            end

        end

        function obj=CreateCompInSimulink(env)





            isImportingComponent=isa(env,'autosar.ui.app.import.ComponentImportWizard');


            id='CreateCompInSimulink';
            if isImportingComponent
                topic=DAStudio.message('autosarstandard:ui:uiCreateComponentTopic');
            else
                topic=DAStudio.message('autosarstandard:ui:uiCreateCompositionTopic');
            end

            obj@autosar.ui.app.base.QuestionBase(id,topic,env);


            obj.getAndAddOption('ImportCompFromArxml_CompName');

            obj.getAndAddOption('ImportCompFromArxml_Modeling');

            if obj.Env.isParentAdaptiveArch()

                obj.getAndAddOption('ImportCompFromArxml_DataDictionary');
            else
                obj.getAndAddOption('ImportCompFromArxml_ModelPeriodicRunnablesAs');
                if isImportingComponent
                    obj.getAndAddOption('ImportCompFromArxml_InitializationRunnable');
                end
                obj.getAndAddOption('ImportCompFromArxml_DataDictionary');
                obj.getAndAddOption('ImportCompFromArxml_PredefinedVariant');
                if~isImportingComponent
                    obj.getAndAddOption('ImportCompFromArxml_ComponentModels');
                    obj.getAndAddOption('ImportCompFromArxml_ExcludeInternalBehavior');
                end
            end



            obj.DisplayFinishButton=true;


            if isImportingComponent
                obj.QuestionMessage=DAStudio.message('autosarstandard:ui:uiImporterCreateComponentAsModel');
                obj.HintMessage=DAStudio.message('autosarstandard:ui:uiImporterCreateComponentAsModelHelp');
            else
                obj.QuestionMessage=DAStudio.message('autosarstandard:ui:uiImporterCreateComposition');
                obj.HintMessage=DAStudio.message('autosarstandard:ui:uiImporterCreateCompositionHelp');
            end
        end

        function onChange(obj)

            env=obj.Env;

            if~isempty(env.LastAnswer)&&isa(env.LastAnswer.Value,'struct')

                env.setCompName(obj.getSelectedCompName());

                env.setModelPeriodicRunnablesAs(obj.getSelectedModelPeriodicRunnablesAs());
                env.setDataDictionary(obj.getSelectedDataDictionary());
                env.setPredefinedVariant(obj.getSelectedPredefinedVariant());
                if isa(obj.Env,'autosar.ui.app.import.ComponentImportWizard')

                    env.setInitializationRunnable(obj.getSelectedInitRunnable());
                else

                    env.setExcludeInternalBehavior(obj.getSelectedExcludeInternalBehavior());
                    obj.refreshOnFileSelection('ImportCompFromArxml_ComponentModels');
                    env.setComponentModels(obj.getSelectedComponentModels());
                end
            end
        end

        function preShow(obj)



            obj.updateCompNameWidget();
            if~obj.Env.isParentAdaptiveArch()
                obj.updatePredefinedVariantWidget();
                if isa(obj.Env,'autosar.ui.app.import.ComponentImportWizard')
                    obj.updateInitRunnableWidget();
                end
            end
        end
    end

    methods(Access=private)

        function compName=getSelectedCompName(obj)

            optionName='ImportCompFromArxml_CompName';
            compName=obj.getOptionValue(optionName);
        end

        function modelPeriodicRunnablesAs=getSelectedModelPeriodicRunnablesAs(obj)

            optionName='ImportCompFromArxml_ModelPeriodicRunnablesAs';
            modelPeriodicRunnablesAs=obj.getOptionValue(optionName);
        end

        function initRunnable=getSelectedInitRunnable(obj)

            optionName='ImportCompFromArxml_InitializationRunnable';
            initRunnable=obj.getOptionValue(optionName);
            if strcmp(initRunnable,autosar.ui.app.question.CreateCompInSimulink.UndefinedString)

                initRunnable='';
            end
        end

        function dataDictionary=getSelectedDataDictionary(obj)

            dataDictionary=obj.getOptionValue('ImportCompFromArxml_DataDictionary');

            option=obj.Env.getOption('ImportCompFromArxml_DataDictionary');
            [folder,file,ext]=fileparts(dataDictionary);
            option.Value.file=[file,ext];
            option.Value.folder=folder;
        end

        function predefinedVariant=getSelectedPredefinedVariant(obj)

            optionName='ImportCompFromArxml_PredefinedVariant';
            predefinedVariant=obj.getOptionValue(optionName);
            if strcmp(predefinedVariant,autosar.ui.app.question.CreateCompInSimulink.UndefinedString)

                predefinedVariant='';
            end
        end

        function componentModels=getSelectedComponentModels(obj)

            optionName='ImportCompFromArxml_ComponentModels';
            componentModelsVal=obj.getOptionValue(optionName);
            if strcmp(componentModelsVal,autosar.ui.app.question.CreateCompInSimulink.UndefinedString)

                componentModels='';
            else
                componentModels=eval(sprintf('cellstr({%s})',componentModelsVal));
            end
        end

        function excludeInternalBehavior=getSelectedExcludeInternalBehavior(obj)

            optionName='ImportCompFromArxml_ExcludeInternalBehavior';
            excludeInternalBehavior=obj.getOptionValue(optionName);
            if strcmp(excludeInternalBehavior,autosar.ui.app.question.CreateCompInSimulink.UndefinedString)

                excludeInternalBehavior='';
            end
        end

        function setDefaultCompName(obj)




            compNameOption=obj.Env.getOption('ImportCompFromArxml_CompName');
            compQNames=obj.Env.getCompNames();
            compNameOption.Answer=compQNames{1};



            if strcmp(get_param(obj.Env.getSLSourceH(),'Type'),'block')
                compQNames=obj.Env.getCompNames();
                [~,compNames]=autosar.utils.splitQualifiedName(compQNames);
                nameMatch=obj.Env.doesSelectionMatchBlockCompName(compNames);
                assert(sum(nameMatch)<=1,...
                'Expected to find no more than matching name');
                if any(nameMatch)


                    compNameOption.Answer=compQNames{nameMatch};
                else


                    nameIdx=find(~nameMatch,1,'first');
                    compNameOption.Answer=compQNames{nameIdx};
                end
            end



            obj.Env.setCompName(compNameOption.Answer);
        end

        function updateCompNameWidget(obj)


            env=obj.Env;
            compNameOption=env.getOption('ImportCompFromArxml_CompName');


            if isempty(compNameOption.Value)||...
                ~ismember(compNameOption.Answer,env.getCompNames())

                compNameOption.Value=env.getCompNames();

                obj.setDefaultCompName();
            end
        end

        function updateInitRunnableWidget(obj)




            env=obj.Env;
            undefinedRunnableStr=autosar.mm.mm2sl.InitRunnableFinder.UndefinedInitRunnableName;
            runnableNames=[{undefinedRunnableStr},obj.Env.getInitRunnableNamesForSelectedComponent()];


            initRunnableOption=env.getOption('ImportCompFromArxml_InitializationRunnable');
            initRunnableOption.Value=runnableNames;

            if isempty(initRunnableOption.Answer)||...
                ~any(ismember(runnableNames,initRunnableOption.Answer))




                initRunnableOption.Answer=runnableNames{1};
                obj.Env.setInitializationRunnable('');
            end
        end
        function updatePredefinedVariantWidget(obj)




            env=obj.Env;
            predefinedVariantOption=env.getOption('ImportCompFromArxml_PredefinedVariant');

            if isempty(predefinedVariantOption.Value)



                predefinedVariantNames{1}=autosar.ui.app.question.CreateCompInSimulink.UndefinedString;

                predefinedVariantNames=[predefinedVariantNames,env.getPredefinedVariants()];

                predefinedVariantOption.Value=predefinedVariantNames;
                predefinedVariantOption.Answer=predefinedVariantNames{1};
                env.setPredefinedVariant('');
            end
        end
    end
end



