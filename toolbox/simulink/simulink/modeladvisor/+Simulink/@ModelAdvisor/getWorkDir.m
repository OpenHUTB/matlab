function WorkDir=getWorkDir(this,varargin)





    if nargin>1
        CheckOnly=strcmp(varargin{1},'CheckOnly');
    else
        CheckOnly=false;
    end

    if~CheckOnly
        rootBDir=Simulink.fileGenControl('get','CacheFolder');

        am=Advisor.Manager.getInstance;
        needCreateSlprjFolder=true;
        appObj=am.getApplication('ID',this.ApplicationID,'token','MWAdvi3orAPICa11');
        if isa(appObj,'Advisor.Application')
            appWorkingDir=appObj.WorkingDir;
            if~isempty(appWorkingDir)
                rootBDir=appWorkingDir;
                needCreateSlprjFolder=false;
            end
        end

        if needCreateSlprjFolder



            rtw_checkdir;


            modeladvisorprivate('modeladvisorutil2','checkSlprjFolder',rootBDir);

            try
                markerFile=fullfile(rootBDir,Simulink.filegen.CodeGenFolderStructure.ModelSpecific.MarkerFile);
                coder.internal.folders.MarkerFile.create(markerFile);
            catch E
                if strcmp(E.identifier,'RTW:utility:mkdirError')||...
                    strncmp(E.identifier,'MATLAB:FileIO:',14)

                    DAStudio.error('ModelAdvisor:engine:CreateSlprjError',[rootBDir,filesep,'slprj']);
                else
                    rethrow(E);
                end
            end
        end
    end

    if~CheckOnly
        WorkDir=ModelAdvisor.getWorkDir(this.System,this.CustomTARootID,false);
        databaseFile=fullfile(WorkDir,'ModelAdvisorData');
        if isa(this.Database,'ModelAdvisor.Repository')&&isvalid(this.Database)
            if~strcmp(databaseFile,this.Database.FileLocation)&&~this.parallel
                this.Database.connect(databaseFile);
            end
        else
            if~this.parallel
                this.Database=ModelAdvisor.Repository(this,databaseFile);
            else
                if~isempty(this.Database)&&~isa(this.Database,'ModelAdvisor.Repository')&&exist(this.Database,'file')

                    this.Database=ModelAdvisor.Repository(this,this.Database);
                else
                    this.Database=ModelAdvisor.Repository(this,databaseFile);
                end
            end
        end
    else
        WorkDir=ModelAdvisor.getWorkDir(this.System,this.CustomTARootID,true);
        return
    end


