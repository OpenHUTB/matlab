classdef ProjectManager<handle






    properties
        project_store_obj;
    end

    methods
        function this=ProjectManager()
            if usejava('jvm')
                projects=slproject.getCurrentProjects();
                if~isempty(projects)
                    project=projects(1);


                    lsm=slreq.linkmgr.LinkSetManager.getInstance;
                    lsm.onProjectOpen(project.Name);
                end
            end
        end
    end

    methods(Static)

        function projectOpened(projectName)

            if~slreq.data.ReqData.exists()
                return;
            end
            lsm=slreq.linkmgr.LinkSetManager.getInstance;
            lsm.onProjectOpen(char(projectName));
        end

        function projectClosed()
            if~slreq.data.ReqData.exists()
                return;
            end

            lsm=slreq.linkmgr.LinkSetManager.getInstance;
            lsm.onProjectClose();
        end

        function projectSLMXFilesModified()
            if~slreq.data.ReqData.exists()
                return;
            end


            lsm=slreq.linkmgr.LinkSetManager.getInstance;
            lsm.scanProject();
        end

        function tf=isFileInLoadedProject(file)
            fileToProjectMapper=Simulink.ModelManagement.Project.Util.FileToProjectMapper(file);

            tf=ismember(exist(file,'file'),[2,4])&&fileToProjectMapper.InALoadedProject;
        end

        function highlightFileInProject(file)
            if slreq.app.ProjectManager.isFileInLoadedProject(file)
                project=matlab.project.currentProject();
                matlab.internal.project.util.showFilesInProject(project,file);
            end
        end
    end
end

