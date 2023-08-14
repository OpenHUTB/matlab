classdef AlertManager<handle





    properties(Access=private)
        Model;
    end


    methods(Access=public)

        function factory=AlertManager(model)
            factory.Model=model;
        end

        function create(factory,id,message)

            filename=get_param(factory.Model,'FileName');
            if(strncmp(filename,matlabroot,numel(matlabroot)))
                return;
            end


            status=UpgradeAdvisor.AlertStatus(factory.Model);
            if(~status.getDisplayStatus())
                return;
            end


            modelHandle=get_param(factory.Model,'Handle');
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            studioHandles=arrayfun(@(s)s.App.blockDiagramHandle,allStudios);
            studioIdx=find(studioHandles==modelHandle,1);
            if isempty(studioIdx)
                return;
            end


            studio=allStudios(studioIdx);
            editor=studio.App.getActiveEditor;
            if isempty(editor)
                editors=studio.App.getAllEditors;
                if isempty(editors)
                    return;
                else
                    editor=editors(1);
                end
            end


            cache=UpgradeAdvisor.AlertCache.getInstance();
            if(cache.getAndSet(factory.Model,id))
                return;
            end


            UpgradeAdvisor.AlertManager.displayAlert(editor,id,message);
        end

    end


    methods(Static,Access=public)

        function createAlert(model,id,message)
            manager=UpgradeAdvisor.AlertManager(model);
            manager.create(id,message);
        end

    end


    methods(Static,Access=private)

        function displayAlert(editor,id,message)
            import matlab.internal.project.util.isFileInProject;

            modelPath=get_param(editor.blockDiagramHandle,'Filename');
            projectMapper=matlab.internal.project.util.FileToProjectMapper(modelPath);




            messageStart=[message,' <a href="matlab:'];
            if projectMapper.InAProject&&...
                (projectMapper.InALoadedProject||...
                (isFileInProject(modelPath,projectMapper.ProjectRoot)&&isempty(slproject.getCurrentProjects)))
                messageStart=...
                [messageStart...
                ,'Simulink.ModelManagement.Project.Upgrade.openProjectUpgrade()'];
                messageKey='SimulinkUpgradeAdvisor:advisor:ProjectUpgradeNotification';
            else
                messageStart=[messageStart,'UpgradeAdvisor.openFromBanner()'];
                messageKey='SimulinkUpgradeAdvisor:advisor:notification';
            end
            messageStart=[messageStart,'">'];
            messageEnd='</a>';

            fullMessage=DAStudio.message(...
            messageKey,...
            messageStart,messageEnd);

            editor.deliverInfoNotification(id,fullMessage)
        end

    end


end