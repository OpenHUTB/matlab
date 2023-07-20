




classdef ModelLinkingWizardBase<autosar.ui.app.base.GuiBase

    properties
        QuickStartWizard;
    end



    properties
        QFlags;
        ValMsgs;
        ModelToLink;
        IsModelLinker=true;
    end

    methods
        function env=ModelLinkingWizardBase(manager,linkInfo)






            env.QuickStartWizard=autosar.ui.app.quickstart.Wizard(manager,linkInfo.modelToLink,linkInfo.compBlkH);

            env.Manager=manager;
            env.CompBlkH=linkInfo.compBlkH;
            env.QFlags=linkInfo.qFlags;
            env.ValMsgs=linkInfo.valMsgs;
            env.ModelToLink=linkInfo.modelToLink;
            env.ModelHandle=linkInfo.unlinkedModelH;


            parentComposition=bdroot(env.CompBlkH);
            env.CompositionHandle=get_param(parentComposition,'Handle');


            env.IsAdaptiveWizard=Simulink.CodeMapping.isAutosarAdaptiveSTF(env.CompositionHandle);
            env.QuickStartWizard.IsAdaptiveWizard=env.IsAdaptiveWizard;


            ID=['/autosar-model-linker/',get_param(env.CompositionHandle,'Name')];
            title=DAStudio.message('autosarstandard:ui:uiModelLinkerTitle');
            env.Gui=autosar.ui.app.base.Gui(env,ID,env.GuiTag,title);


            env.CloseListener=Simulink.listener(env.ModelHandle,...
            'CloseEvent',@env.CloseForGuiCB);


            env.ArchCloseListener=Simulink.listener(env.CompositionHandle,...
            'CloseEvent',@env.CloseForGuiCB);
        end

        function delete(env)



            if~env.IsWizardFinished
                env.cleanupOnPrematureClose;
            end
        end

        function start(env)
            env.init();
        end



        function finishQuickStart(env)

            env.QuickStartWizard.finishQuickStart();
        end


        function compBlockH=getCompBlkH(obj)

            compBlockH=obj.CompBlkH;
        end

        function arxmlSelect(env)
            env.QuickStartWizard.arxmlSelect;
        end
    end

    methods(Hidden)


        function importedMdlH=getImportedMdlH(obj)
            importedMdlH=obj.ImportedMdlH;
        end

        function reportWarning(obj,mException)

            stageName=DAStudio.message('autosarstandard:editor:AutosarImportArxmlStage');
            parentMdlName=get_param(obj.CompositionHandle,'Name');
            reportType='warning';
            autosar.utils.DiagnosticViewer.report(mException,reportType,stageName,parentMdlName);
        end
    end

    methods(Access=protected)


        function init(env)
            setWizardQuestions(env);
        end

        function setWizardQuestions(env)

            env.QuestionMap=containers.Map;
            env.OptionMap=containers.Map;
            env.QuickStartWizard.QuestionMap=containers.Map;
            env.QuickStartWizard.OptionMap=containers.Map;


            qObjs=struct;


            if env.QFlags.linking

                qObjs.ValidateModelQ=autosar.ui.app.question.ValidateModel(env);
                if strcmp(env.ValMsgs.failures.dictionaryMigrationCheckFail,'FailWithConflicts')
                    qObjs.MigratorConflictsQ=sl.interface.dict.migrator.question.MigratorConflicts(env);
                end
            end


            if env.QFlags.quickStart





                activeConfigSet=autosar.utils.getActiveConfigSet(env.ModelHandle);
                if env.IsAdaptiveWizard
                    set_param(activeConfigSet,'SystemTargetFile','autosar_adaptive.tlc');
                else
                    set_param(activeConfigSet,'SystemTargetFile','autosar.tlc');
                end

                env.QuickStartWizard.ModelHandle=env.ModelHandle;




                if isempty(env.ValMsgs.warnings.ioWarn)


                    qObjs.ComponentQ=autosar.ui.app.question.Component(env.QuickStartWizard);
                end


                if~env.QuickStartWizard.IsAdaptiveWizard


                    qObjs.PropertiesQ=autosar.ui.app.question.Properties(env.QuickStartWizard);
                end
            end



            env.QuestionMap=[env.QuestionMap;env.QuickStartWizard.QuestionMap];
            env.QuestionTopics=[env.QuestionTopics,env.QuickStartWizard.QuestionTopics];
            env.OptionMap=[env.OptionMap;env.QuickStartWizard.OptionMap];



            qObjs=struct2cell(qObjs);
            env.CurrentQuestion=qObjs{1};
        end

        function cleanupOnPrematureClose(env)


            saveModelChanges=false;
            if~env.ModelClosedOutsideWizard
                close_system(env.ModelToLink,saveModelChanges);
            end
        end
    end
end



