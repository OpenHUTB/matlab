




classdef CompImportWizardBase<autosar.ui.app.base.GuiBase

    properties(Access=protected)

        ArxmlImporter arxml.importer
        CompName=''
        CompNames={}
        ModelPeriodicRunnablesAs='Auto'
        DataDictionary=''
        PredefinedVariant=''
        ComponentModels={}
        ExcludeInternalBehavior=false
    end

    properties(SetAccess=immutable,GetAccess=protected)
SLSourceH
    end

    methods
        function env=CompImportWizardBase(manager,slSourceH)







            env.Manager=manager;
            env.SLSourceH=get_param(slSourceH,'Handle');


            parentComposition=bdroot(slSourceH);
            env.CompositionHandle=get_param(parentComposition,'Handle');


            env.setDataDictionary(env.getCompositionDataDictionary());


            ID=['/autosar-importer/',get_param(env.CompositionHandle,'Name')];
            title=DAStudio.message('autosarstandard:ui:uiImporterTitle');
            env.Gui=autosar.ui.app.base.Gui(env,ID,env.GuiTag,title);


            env.CloseListener=Simulink.listener(env.CompositionHandle,...
            'CloseEvent',@env.CloseForGuiCB);
        end

        function arxmlSelect(env)
            q=env.CurrentQuestion;
            if~strcmp(q.Id,'ImportCompFromArxml')
                return
            end
            [arxmlFiles,folder]=uigetfile({'*.arxml','ARXML Files (*.arxml)'},'MultiSelect','on');
            if~iscell(arxmlFiles)&&~ischar(arxmlFiles)

                return
            end
            o=env.getOption('ImportCompFromArxml_FileSelect');
            o.Value.file=arxmlFiles;
            o.Value.folder=folder;
            env.Gui.sendQuestion(q);
        end

        function modelSelect(env)
            q=env.CurrentQuestion;
            if~strcmp(q.Id,'CreateCompInSimulink')
                return
            end
            [slxFiles,folder]=uigetfile({'*.slx','SLX Files (*.slx)'},'MultiSelect','on');
            if~iscell(slxFiles)&&~ischar(slxFiles)

                return
            end
            o=env.getOption('ImportCompFromArxml_ComponentModels');
            o.Value.file=slxFiles;
            if iscell(slxFiles)

                temp=cell(size(slxFiles));
                [temp{1:numel(slxFiles)}]=deal(folder);
                o.Value.folder=temp;
            else
                o.Value.folder=folder;
            end
            env.Gui.sendQuestion(q);
            env.setComponentModels(fullfile(folder,slxFiles));
        end

        function dataDictionarySelect(env)
            q=env.CurrentQuestion;
            if~strcmp(q.Id,'CreateCompInSimulink')
                return
            end
            [dataDictionaryName,folder]=...
            uigetfile({'*.sldd','Simulink Data Dictionary (*.sldd)'},'MultiSelect','off');
            if~iscell(dataDictionaryName)&&~ischar(dataDictionaryName)

                return
            end
            o=env.getOption('ImportCompFromArxml_DataDictionary');
            o.Value.file=dataDictionaryName;
            o.Value.folder=folder;
            env.Gui.sendQuestion(q);
            env.setDataDictionary(fullfile(folder,dataDictionaryName));
        end

        function start(env)

            env.init();
            env.CurrentQuestion=env.getQuestion('ImportCompFromArxml');
        end

        function predefinedVariantNames=getPredefinedVariants(obj)


            assert(~isempty(obj.ArxmlImporter),'Arxml file needs to be imported to get m3iModel');
            m3iModel=obj.ArxmlImporter.getM3IModel();


            m3iPredefinedVariants=...
            autosar.mm.Model.findChildByTypeName(m3iModel,...
            'Simulink.metamodel.arplatform.variant.PredefinedVariant');

            predefinedVariantNames=cell(1,length(m3iPredefinedVariants));
            for i=1:length(m3iPredefinedVariants)
                predefinedVariantNames{i}=autosar.api.Utils.getQualifiedName(m3iPredefinedVariants{i});
            end
        end


        function compBlockH=getSLSourceH(obj)

            compBlockH=obj.SLSourceH;
        end

        function setArxmlImporter(obj,arxmlImporter)


            obj.ArxmlImporter=arxmlImporter;
        end

        function setCompName(obj,compName)


            obj.CompName=compName;
        end

        function setModelPeriodicRunnablesAs(obj,modelPeriodicRunnablesAs)


            obj.ModelPeriodicRunnablesAs=modelPeriodicRunnablesAs;
        end

        function setDataDictionary(obj,dataDictionary)


            [~,dataDictionaryName,ext]=fileparts(dataDictionary);
            obj.DataDictionary=[dataDictionaryName,ext];
        end

        function setPredefinedVariant(obj,predefinedVariant)


            obj.PredefinedVariant=predefinedVariant;
        end

        function setComponentModels(obj,componentModels)


            obj.ComponentModels=componentModels;
        end

        function setExcludeInternalBehavior(obj,excludeInternalBehavior)


            obj.ExcludeInternalBehavior=excludeInternalBehavior;
        end

        function setCompNames(obj,compNames)


            obj.CompNames=compNames;
        end

        function compNames=getCompNames(obj)


            compNames=obj.CompNames;
        end

        function slddPath=getCompositionDataDictionary(obj)
            slddPath=which(...
            get_param(obj.CompositionHandle,'DataDictionary'));
        end

        function isAdaptiveArch=isParentAdaptiveArch(obj)


            isAdaptiveArch=...
            Simulink.CodeMapping.isAutosarAdaptiveSTF(obj.CompositionHandle);
        end
    end

    methods(Hidden)


        function componentName=getCompName(obj)
            componentName=obj.CompName;
        end

        function modelPeriodicRunnablesAs=getModelPeriodicRunnablesAs(obj)
            modelPeriodicRunnablesAs=obj.ModelPeriodicRunnablesAs;
        end

        function dataDictionary=getDataDictionary(obj)
            dataDictionary=obj.DataDictionary;
        end

        function predefinedVariant=getPredefinedVariant(obj)
            predefinedVariant=obj.PredefinedVariant;
        end

        function importedMdlH=getImportedMdlH(obj)
            importedMdlH=obj.ImportedMdlH;
        end

        function reportWarning(obj,mException)

            stageName=DAStudio.message('autosarstandard:editor:AutosarImportArxmlStage');
            parentMdlName=get_param(obj.CompositionHandle,'Name');
            reportType='warning';
            autosar.utils.DiagnosticViewer.report(mException,reportType,stageName,parentMdlName);
        end

        function ret=doesSelectionMatchBlockCompName(env,compName)




            m3iCompOfBlk=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(...
            env.getSLSourceH());
            assert(~isempty(m3iCompOfBlk),'Expected to find a component block matching the argument component name.');
            ret=strcmp(m3iCompOfBlk.Name,compName);
        end
    end


    methods(Access=protected)
        function init(env)



            env.QuestionMap=containers.Map;
            env.OptionMap=containers.Map;


            autosar.ui.app.question.ImportCompFromArxml(env);
            autosar.ui.app.question.CreateCompInSimulink(env);
        end
    end

    methods(Access=protected)
        function verifyCompNameUniqueInCompositionHierachy(env)



            [~,selectedCompName]=autosar.utils.splitQualifiedName(...
            env.CompName);


            existingCompNames=env.getExistingCompNames();

            parentCompositionName=get_param(env.CompositionHandle,'Name');
            existingCompNames(contains(existingCompNames,parentCompositionName))=[];

            if any(strcmp(existingCompNames,selectedCompName))



                if env.doesSelectionMatchBlockCompName(selectedCompName)
                    return;
                end







                blockWithSameName=[find_system(env.CompositionHandle,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','SubSystem','Name',selectedCompName),...
                find_system(env.CompositionHandle,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','ModelReference','Name',selectedCompName)];
                if~isempty(blockWithSameName)
                    blockWithSameName=getfullname(blockWithSameName);
                else
                    blockWithSameName=selectedCompName;
                end
                errorMsg=message('autosarstandard:editor:ImportARXMLConflictingComp',...
                blockWithSameName);
                exception=MSLException([],errorMsg);
                exception.throw();
            end
        end
    end

    methods(Access=private)
        function existingCompNames=getExistingCompNames(env)
            m3iModel=autosar.api.Utils.m3iModel(env.CompositionHandle);
            m3iExistingComps=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.component.Component.MetaClass,true,true);
            existingCompNames=m3i.mapcell(@(x)x.Name,m3iExistingComps);
        end
    end
end



