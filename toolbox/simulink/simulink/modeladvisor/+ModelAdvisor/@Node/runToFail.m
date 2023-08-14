function runToFail(this,varargin)










    if nargin>1
        continueFromNode=varargin{1};
        continueMode=true;
    else
        continueMode=false;
    end








    this.MAObj.R2FMode=true;
    this.MAObj.R2FStart=this;
    this.MAObj.R2FStop={};
    try

        needClearStartTime=false;
        if this.MAObj.StartTime==0
            this.MAObj.StartTime=now;
            needClearStartTime=true;
        end


        allChildren=getAllChildren(this);
        continueNodeReached=false;
        for i=1:length(allChildren)
            if continueMode&&~continueNodeReached
                if strcmp(continueFromNode.ID,allChildren{i}.ID)
                    continueNodeReached=true;
                else
                    continue
                end
            end
            if isa(allChildren{i},'ModelAdvisor.Task')&&allChildren{i}.Selected
                if isa(this.MAObj.MAExplorer,'DAStudio.Explorer')
                    imme=DAStudio.imExplorer(this.MAObj.MAExplorer);
                    imme.selectTreeViewNode(allChildren{i});
                end
                allChildren{i}.runTaskAdvisor;
                if~isempty(this.MAObj.R2FStop)

                    break
                end
            end
        end
        this.MAObj.R2FMode=false;
        if this.MAObj.HasCompiled||this.MAObj.HasCompiledForCodegen
            modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this.MAObj);
        end
        if this.MAObj.HasCGIRed
            modeladvisorprivate('modeladvisorutil2','TermCGIRModelCompile',this.MAObj);
        end
    catch E

        if needClearStartTime
            this.MAObj.StartTime=0;
        end

        this.MAObj.R2FMode=false;
        if this.MAObj.HasCompiled||this.MAObj.HasCompiledForCodegen
            modeladvisorprivate('modeladvisorutil2','TerminateModelCompile',this.MAObj);
        end
        if this.MAObj.HasCGIRed
            modeladvisorprivate('modeladvisorutil2','TermCGIRModelCompile',this.MAObj);
        end
        rethrow(E);
    end


    if needClearStartTime
        this.MAObj.StartTime=0;
    end


    if isa(this,'ModelAdvisor.Group')
        WorkDir=this.MAObj.getWorkDir;
        reportName=modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',this,WorkDir);
        if exist(reportName,'file')
            delete(reportName);
            this.viewReport('');
        end
    end


    if(isa(this,'ModelAdvisor.Group')&&this.LaunchReport)||(isjava(this.MAObj.BrowserWindow)&&this.MAObj.BrowserWindow.isShowing)
        this.viewReport('');
    end


