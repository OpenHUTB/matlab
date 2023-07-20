classdef MatlabSession


    properties
        sessionDir;
        userDir;
        addonsDir;
        warnState;
        logger;
        resetWorkspaceAndFiguresBeforeLoad=true;
        useAsyncSave=isunix&&...
        matlab.internal.environment.context.isMATLABOnline;
    end

    properties(Access=public)
        workspaceAndFigures;
        path;
    end

    methods(Access=public)

        function this=MatlabSession(sessionDir,userDir,addonsDir)
            import mls.internal.session.*;
            this.sessionDir=sessionDir;
            this.userDir=userDir;
            this.addonsDir=addonsDir;
            this.warnState=warning;
            this.logger=...
            connector.internal.Logger('connector::session_m');

            this.workspaceAndFigures=SessionData('workspaceAndFigures',this,...
            mls.internal.session.data.WorkspaceAndFiguresData());
            this.path=SessionData('properties',this,...
            mls.internal.session.data.PathData(this));
        end

        function loadSession(this,updatePath)
            try
                warning('off','all');
                cleanUpObj=onCleanup(@()warning(this.warnState));

                if(nargin==1)
                    updatePath=true;
                end

                prevPathSettings=this.path.enabled;
                if(updatePath)
                    this.path.enable();
                else
                    this.path.disable();
                end

                if(this.resetWorkspaceAndFiguresBeforeLoad)


                    this.workspaceAndFigures.reset();
                end

                if this.hasLegacyFormat()
                    this.loadLegacyFormat(updatePath);
                else
                    this.workspaceAndFigures.load();
                    this.path.load();
                end

                if(prevPathSettings)
                    this.path.enable();
                else
                    this.path.disable();
                end
            catch ME
                this.logger.info(['LoadSession: ',getReport(ME)]);
            end
        end

        function resetSession(this)
            try
                warning('off','all');
                cleanUpObj=onCleanup(@()warning(this.warnState));

                this.workspaceAndFigures.reset();
                this.path.reset();
            catch ME
                this.logger.info(['ResetSession: ',getReport(ME)]);
            end
        end

        function deleteSession(this)
            try
                warning('off','all');
                cleanUpObj=onCleanup(@()warning(this.warnState));

                if this.hasLegacyFormat()
                    this.removeLegacyFormat();
                end

                this.workspaceAndFigures.clear();
                this.path.clear();
            catch ME
                this.logger.info(['DeleteSession: ',getReport(ME)]);
            end
        end

        function saveSession(this)
            try
                warning('off','all');
                cleanUpObj=onCleanup(@()warning(this.warnState));

                if this.hasLegacyFormat()
                    this.removeLegacyFormat();
                end





                project=matlab.project.currentProject;
                if~isempty(project)
                    for jj=1:numel(project.ProjectPath)
                        rmpath(project.ProjectPath(jj).File)
                    end
                end

                if isunix&&this.useAsyncSave
                    this.workspaceAndFigures.saveasync();
                    this.path.saveasync();
                else
                    this.workspaceAndFigures.save();
                    this.path.save();
                end
            catch ME
                this.logger.info(['SaveSession: ',getReport(ME)]);
            end
        end

    end


    methods(Access=private)

        function result=hasLegacyFormat(this)
            result=false;
            legacyFile=fullfile(this.sessionDir,'matlabState.mat');
            newFile1=fullfile(this.sessionDir,'workspaceAndFigures.mat');
            newFile2=fullfile(this.sessionDir,'properties.mat');

            if exist(legacyFile,'file')&&~exist(newFile1,'file')...
                &&~exist(newFile2,'file')
                result=true;
            end
        end

        function loadLegacyFormat(this,updatePath)
            legacyFile=fullfile(this.sessionDir,'matlabState.mat');
            if exist(legacyFile,'file')
                data=load(legacyFile);

                if isfield(data.state,'workspace')&&...
                    isfield(data.state,'figures')
                    this.workspaceAndFigures.dataInterface.set(data.state);
                end

                if(updatePath)
                    if isfield(data.state,'properties')
                        this.path.dataInterface.set(...
                        data.state.properties...
                        );
                    end
                end
            end
        end

        function removeLegacyFormat(this)
            legacyFile=fullfile(this.sessionDir,'matlabState.mat');
            if exist(legacyFile,'file')
                delete(legacyFile);
            end
        end

    end

end

