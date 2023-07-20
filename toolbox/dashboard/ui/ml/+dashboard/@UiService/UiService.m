


classdef UiService<handle

    properties(Hidden,Access=private)

        WindowMap=containers.Map()
        LastProjectPath=""
    end

    properties(Dependent)
Windows
    end

    methods(Access=private)
        function this=UiService()
        end

        function onWindowClosed(this,window)
            WindowLists=values(this.WindowMap);
            for i=1:length(this.WindowMap)
                windows=WindowLists{i};
                for j=1:length(windows)
                    aWindow=windows(j);
                    if strcmp(aWindow.WindowID,window.WindowID)
                        windows(j)=[];
                        paths=keys(this.WindowMap);
                        if isempty(windows)
                            remove(this.WindowMap,paths{i});
                        else
                            paths=keys(this.WindowMap);
                            this.WindowMap(paths{i})=windows;
                        end
                        return
                    end
                end
            end
        end
    end

    methods
        function windows=get.Windows(this)
            windows=values(this.WindowMap);
            windows=horzcat(windows{:});
        end

        function clear(this)
            remove(this.WindowMap,keys(this.WindowMap));
        end

        function windows=windowsForProject(this,projectArg)
            projectPath=dashboard.UiService.validateProjectArgument(projectArg);
            if isKey(this.WindowMap,projectPath)
                windows=this.WindowMap(projectPath);
            else
                windows={};
            end
        end

        function window=defaultWindowForProject(this,projectArg)
            projectPath=dashboard.UiService.validateProjectArgument(projectArg);
...
...
...
...
...
...
...
...
...
            val=values(this.WindowMap);
            if numel(val)==1
                window=val{1};
            else
                window=this.createNewWindow(projectPath);
            end
        end

        function window=openWindow(this)
            window=this.defaultWindowForProject(this.LastProjectPath);
            window.open('Project',this.LastProjectPath);
        end

        function window=openDashboard(this,projectArg)
            window=this.defaultWindowForProject(projectArg);
            window.open('Project',this.LastProjectPath);
        end
    end

    methods(Static,Access=private)
        function path=validateProjectArgument(projectArg)
            if isa(projectArg,'matlab.project.Project')
                path=projectArg.RootFolder;
            elseif ischar(projectArg)||isStringScalar(projectArg)
                path=string(projectArg);
            else

                path="";
            end
        end
    end

    methods(Hidden,Access=private)
        function window=createNewWindow(this,projectPath)
            newSession=dashboard.UiWindow.generateWindowSessionId();
            window=dashboard.UiWindow(newSession,@(window)onWindowClosed(this,window));
            this.LastProjectPath=projectPath;
            this.WindowMap(projectPath)=window;
        end
    end

    methods(Static)
        function inst=get()
            mlock;
            persistent Inst;
            if isempty(Inst)
                Inst=dashboard.UiService();
            end
            inst=Inst;
        end

        function shutdown()

            dashboard.internal.closeDashboard();

        end
    end

    methods(Static,Hidden)
        function internalOpenDashboard(sesionID)
            Ins=dashboard.UiService.get();
            w=Ins.getWindowBySessionId(sesionID);
            if~isnumeric(w)
                w.open();
            end
        end

        function project=getProjectPathBySessionID(sessionID)
            Ins=dashboard.UiService.get();
            ProjectPaths=keys(Ins.WindowMap);
            WindowLists=values(Ins.WindowMap);
            for i=1:length(Ins.Windows)
                windows=WindowLists{i};
                for j=1:length(windows)
                    window=windows(j);
                    if strcmp(window.SessionID,sessionID)
                        project=ProjectPaths{i};
                        return
                    end
                end
            end
            project="";
        end

        function window=getWindowBySessionId(sessionID)
            Ins=dashboard.UiService.get();
            WindowLists=values(Ins.WindowMap);
            for i=1:length(Ins.Windows)
                windows=WindowLists{i};
                for j=1:length(windows)
                    aWindow=windows(j);
                    if strcmp(aWindow.SessionID,sessionID)
                        window=aWindow;
                        return;
                    end
                end
            end
            window=nan;
        end
    end

end
