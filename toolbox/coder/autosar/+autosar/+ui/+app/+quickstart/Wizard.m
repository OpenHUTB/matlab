



classdef Wizard<autosar.ui.app.base.GuiBase

    properties
ProtectedNames
IsSubComponent
ImportProperties
DefaultMapping
ArxmlImporter
ComponentName
ComponentPkg
ComponentType
        MigratorWizard sl.interface.dict.migrator.MigratorWizard
NeedSTFSelectionDialog
IsModelLinker
InterfaceDictName
    end

    properties(Constant,Access=private)
        GuiTag='Tag_Autosar_Wizard';
    end

    methods
        function env=Wizard(manager,model,compBlkH)









            env.Manager=manager;
            env.IsModelLinker=isa(env.Manager,'autosar.ui.app.link.ModelLinkingWizardManager');

            if nargin<3
                env.CompBlkH=[];
            else
                env.CompBlkH=compBlkH;
            end

            if ischar(model)


                [~,model]=fileparts(model);
            end

            env.ModelHandle=get_param(model,'Handle');
            env.ArxmlImporter=[];

            if env.IsModelLinker

                env.IsAdaptiveWizard=[];
            else

                env.IsAdaptiveWizard=Simulink.CodeMapping.isAutosarAdaptiveSTF(model);
            end


            env.NeedSTFSelectionDialog=true;


            env.ImportProperties=false;
            env.DefaultMapping=true;
            env.IsSubComponent=false;
            interfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(model);
            env.InterfaceDictName='';
            if numel(interfaceDicts)==1
                env.InterfaceDictName=autosar.utils.File.dropPath(interfaceDicts{1});
            end



            if~env.IsModelLinker&&~isempty(env.InterfaceDictName)
                env.MigratorWizard=sl.interface.dict.migrator.MigratorWizard(model,env.InterfaceDictName);
            end


            ID=['/autosar-quickstart/',get_param(env.ModelHandle,'Name')];
            title=DAStudio.message('autosarstandard:ui:uiQuickStartTitle');
            env.Gui=autosar.ui.app.base.Gui(env,ID,env.GuiTag,title);



            if~env.IsModelLinker
                env.CloseListener=Simulink.listener(env.ModelHandle,'CloseEvent',@env.CloseForGuiCB);
            end
        end

        function arxmlSelect(env)

            env=env.setEnvironmentForQuestionMap;

            q=env.CurrentQuestion;
            if~strcmp(q.Id,'Properties')
                return
            end
            [arxmlFiles,folder]=uigetfile({'*.arxml','ARXML Files (*.arxml)'},'MultiSelect','on');
            if~iscell(arxmlFiles)&&~ischar(arxmlFiles)

                return
            end
            o=q.Options{3};
            o.Value.file=arxmlFiles;
            o.Value.folder=folder;
            env.Gui.sendQuestion(q);
        end

        function closeWizard=finish(env)
            closeWizard=true;
            finishQuickStart(env);
        end

        function finishQuickStart(env)
            modelName=get_param(env.ModelHandle,'Name');
            Simulink.output.Stage(...
            message('autosarstandard:ui:uiWizardNoMetaModelOption2').getString(),...
            'ModelName',modelName,'UIMode',true);

            env.start_spin();
            c=onCleanup(@()env.stop_spin());


            activeConfigSet=autosar.utils.getActiveConfigSet(env.ModelHandle);
            set_param(activeConfigSet,'SolverType','Fixed-step');


            if env.IsSubComponent
                autosar.api.create(modelName,'default','ReferencedFromComponentModel',true);
            else

                if~isempty(env.MigratorWizard)
                    env.MigratorWizard.finish();
                end




                if env.IsModelLinker
                    autosar.api.create(modelName);
                elseif env.DefaultMapping
                    autosar.api.create(modelName,'default');
                else
                    autosar.api.create(modelName,'init');
                end


                m3iComponent=autosar.api.Utils.m3iMappedComponent(modelName);



                apiObj=autosar.api.getAUTOSARProperties(modelName);
                compPath=apiObj.find([],"Component","Name",...
                m3iComponent.Name,"PathType","FullyQualified");
                if~isempty(env.ComponentName)
                    apiObj.set(compPath{1},'Name',env.ComponentName);

                    compPath=apiObj.find([],"Component","Name",...
                    m3iComponent.Name,"PathType","FullyQualified");
                end



                if~env.IsAdaptiveWizard&&~isempty(env.ComponentType)
                    apiObj.set(compPath{1},'Kind',env.ComponentType);
                end



                if~isempty(env.ComponentPkg)
                    newCompPackage=env.ComponentPkg;
                    m3iModel=autosar.api.Utils.m3iModel(modelName);
                    m3iRoot=m3iModel.RootPackage.front;

                    domain=m3iRoot.Domain;
                    trans=M3I.Transaction(domain);


                    try
                        oldCompQName=autosar.api.Utils.getQualifiedName(m3iComponent);
                        [oldCompPackage,compName,~]=fileparts(oldCompQName);
                        newCompQName=[newCompPackage,'/',compName];
                        if~strcmp(newCompPackage,oldCompPackage)
                            try

                                autosar.api.Utils.syncComponentQualifiedName(m3iRoot,oldCompQName,newCompQName);
                            catch exObj
                                errordlg(exObj.message,...
                                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                            end
                        end
                    catch e
                        errordlg(e.message,...
                        autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                        trans.cancel();
                        return;
                    end
                    trans.commit();
                end

            end



            if env.ImportProperties&&~isempty(env.ArxmlImporter)
                if env.IsSubComponent
                    env.ArxmlImporter.updateModel(modelName);
                else
                    env.ArxmlImporter.updateAUTOSARProperties(modelName,'LaunchReport','off');
                end
            end



            editors=GLUE2.Util.findAllEditors(modelName);
            if numel(editors)>0
                cp=simulinkcoder.internal.CodePerspective.getInstance;
                cp.turnOnPerspective(editors(1),'nonblocking');
            else
                if~env.IsSubComponent&&~env.IsModelLinker

                    autosar_ui_launch(modelName);
                end
            end
        end

        function start(env)

            env.init();
            if env.NeedSTFSelectionDialog
                env.CurrentQuestion=env.getQuestion('SystemTargetFile');
            else
                env.CurrentQuestion=env.getQuestion('Component');
            end
        end

        function repopulateQuestionsForAdaptiveSTFSelection(env)




            env.QuestionMap=containers.Map();
            env.OptionMap=containers.Map;




            oldQuestionTopics=env.QuestionTopics;
            env.init();

            env.QuestionTopics=oldQuestionTopics;
        end

        function env=setEnvironmentForQuestionMap(env)


            if env.IsModelLinker
                env=env.Manager.getModelLinkingWizard(env.CompBlkH);
            end
        end
    end

    methods(Access=protected)
        function init(env)



            env.QuestionMap=containers.Map;
            env.OptionMap=containers.Map;


            if env.NeedSTFSelectionDialog
                autosar.ui.app.question.SystemTargetFile(env);
            end

            prevQuestion=autosar.ui.app.question.Component(env);

            if~env.IsAdaptiveWizard

                prevQuestion=autosar.ui.app.question.Properties(env);
            end



            if~isempty(env.MigratorWizard)&&~env.MigratorWizard.QFlags.nothingToMigrate
                env.MigratorWizard.QuestionMap=containers.Map;
                env.MigratorWizard.OptionMap=containers.Map;

                if~isempty(prevQuestion)
                    prevQuestion.NextQuestionId='MigratorMainPage';
                end

                env.MigratorWizard.setWizardQuestions('Finish');

                env.QuestionMap=[env.QuestionMap;env.MigratorWizard.QuestionMap];
                env.QuestionTopics=[env.QuestionTopics,env.MigratorWizard.QuestionTopics];
                env.OptionMap=[env.OptionMap;env.MigratorWizard.OptionMap];

                env.MigratorWizard.registerQuestion(prevQuestion);
            end

            finishQuestion=autosar.ui.app.question.Finish(env);

            if~isempty(env.MigratorWizard)&&~env.MigratorWizard.QFlags.nothingToMigrate
                env.MigratorWizard.registerQuestion(finishQuestion);
            end
        end
    end
end


