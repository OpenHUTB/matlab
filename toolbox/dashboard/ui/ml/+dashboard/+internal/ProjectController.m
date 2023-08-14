classdef ProjectController



    methods(Static)

        function success=newProjectFromPath(path)
            success=false;
        end

        function success=openProject(path)
            try
                g=alm.internal.GlobalProjectFactory.get();
                f=g.createMATLABProjectFactory();
                f.loadProject(path,false);
                success=true;
            catch
                success=false;
            end
        end

        function success=closeProject()
            try
                close(currentProject);
                success=true;
            catch
                success=false;
            end
        end

        function projectInfo=getCurrentProject()
            projectInfo=struct('Path','','Name','');
            try %#ok<TRYNC>
                p=currentProject;
                projectInfo.Path=char(p.RootFolder);
                projectInfo.Name=char(p.Name);
            end
        end

        function projects=getRecentProjects()
            recentProjects=slhistory.getMRUList(slhistoryListType.Projects);
            projects=struct('Path',{},'Name',{});
            for idx=1:numel(recentProjects)
                [pth,file]=fileparts(recentProjects{idx});
                projects(idx).Path=pth;
                projects(idx).Name=file;
            end
        end

        function setProjectPath(sessionId,projectPath)
            s=dashboard.UiService.get();
            w=s.getWindowBySessionId(sessionId);
            w.setProjectPath(projectPath);
        end
    end

end
