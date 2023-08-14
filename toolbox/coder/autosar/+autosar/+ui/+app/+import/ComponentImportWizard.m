




classdef ComponentImportWizard<autosar.ui.app.import.CompImportWizardBase

    properties(Access=private)

        InitializationRunnable=''
    end

    properties(Hidden,Constant)

        GuiTag='Tag_Autosar_Component_Importer';
    end

    methods
        function env=ComponentImportWizard(manager,compBlk)








            env@autosar.ui.app.import.CompImportWizardBase(manager,compBlk);
        end

        function closeWizard=finish(env)

            import autosar.composition.studio.AUTOSARComponentToModelLinker;

            closeWizard=true;


            env.start_spin();
            c=onCleanup(@()env.stop_spin());

            try

                env.verifyCompNameUniqueInCompositionHierachy();
            catch mException
                sldiagviewer.reportError(mException);
                closeWizard=false;
                return;
            end


            try
                importedMdlH=env.createComponentAsModel();
            catch mException
                sldiagviewer.reportError(mException);
                closeWizard=false;
                return;
            end


            importedMdlName=get_param(importedMdlH,'Name');
            isUIMode=true;
            compToModelLinker=AUTOSARComponentToModelLinker(env.SLSourceH,importedMdlName,isUIMode);
            compToModelLinker.linkComponentToModel();
        end


        function runnableNames=getInitRunnableNamesForSelectedComponent(obj)


            componentName=obj.CompName;
            m3iComp=obj.getM3IComponent(componentName);

            m3iRunnables=autosar.mm.Model.findChildByTypeName(m3iComp,...
            'Simulink.metamodel.arplatform.behavior.Runnable');

            runnableNames={};
            initRunnableFinder=autosar.mm.mm2sl.InitRunnableFinder();
            for i=1:length(m3iRunnables)
                curRunnableName=m3iRunnables{i}.Name;
                try
                    initRunnableFinder.find(curRunnableName,m3iComp);
                catch


                    continue;
                end
                runnableNames{end+1}=curRunnableName;%#ok<AGROW>
            end
        end

        function setInitializationRunnable(obj,initRunnable)


            obj.InitializationRunnable=initRunnable;
        end
    end

    methods(Hidden)


        function initRunnable=getInitializationRunnable(obj)
            initRunnable=obj.InitializationRunnable;
        end
    end

    methods(Access=private)
        function m3iComp=getM3IComponent(obj,componentName)



            assert(~isempty(obj.ArxmlImporter),'Arxml file needs to be imported to get m3iComp');
            m3iModel=obj.ArxmlImporter.getM3IModel();
            m3iComp=autosar.mm.Model.findChildByName(m3iModel,componentName);
            assert((~isempty(m3iComp)&&...
            isa(m3iComp,'Simulink.metamodel.arplatform.component.AtomicComponent')||...
            isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')),...
            'Cannot find m3iComp');
        end

        function modelH=createComponentAsModel(env)


            importerObj=env.ArxmlImporter;
            if env.isParentAdaptiveArch()
                createArgs={};
            else
                createArgs={'ModelPeriodicRunnablesAs',env.ModelPeriodicRunnablesAs,...
                'InitializationRunnable',env.InitializationRunnable,...
                'PredefinedVariant',env.PredefinedVariant};
            end

            createArgs=[createArgs...
            ,{'DataDictionary',env.DataDictionary,...
            'OpenModel',false,...
            'UseBusElementPorts',false,...
            'NameConflictAction','makenameunique'}];
            modelH=importerObj.createComponentAsModel(env.CompName,...
            createArgs{:});

            apiObj=autosar.api.getAUTOSARProperties(modelH);
            apiObj.set('XmlOptions','XmlOptionsSource','Inherit');
            if~env.isParentAdaptiveArch()


                [canRefactor,msgId,msg]=...
                autosar.simulink.bep.RefactorModelInterface.canRefactorModelInterface(modelH);
                if canRefactor
                    backupModel=false;
                    modelName=get_param(modelH,'Name');
                    autosar.simulink.bep.RefactorModelInterface.convertToBEPs(modelName,backupModel);
                else

                    parentMsgId='autosarstandard:editor:ImportArxmlBEPConversionFail';
                    parentException=MSLException([],message(parentMsgId));
                    cause=MSLException([],msgId,msg);
                    parentException=parentException.addCause(cause);
                    env.reportWarning(parentException);
                end
            end

            save_system(modelH);
        end
    end
end



