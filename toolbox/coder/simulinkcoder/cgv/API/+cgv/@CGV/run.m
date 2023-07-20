






















function passed=run(this)


    if length(this)>1
        DAStudio.error('RTW:cgv:ManyCgvObjs');
    end

    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunCanBeCalledOnce');
    end
    this.RunHasBeenCalled=1;

    loadStatus=[];

    setupDir(this,this.OutputDir);
    setupDir(this,this.WorkDir);

    vars2keep=evalin('base','who');


    nInputDataNames=0;
    for i=1:length(this.InputData)
        if~isempty(this.InputData(i).pathAndName)
            nInputDataNames=nInputDataNames+1;
        end
    end

    if(nInputDataNames==0)
        DAStudio.warning('RTW:cgv:NoAddInputDataCall');


        this.NoInputData=true;
        initInputData(this,1);
        this.InputData(1).label='1';
        this.InputData(1).pathAndName='none';
    end


    model=this.ModelName;
    try

        savedir=pwd;
        cd(this.WorkDir);

        if exist(fullfile(pwd,'slprj'),'dir')
            rmdir('slprj','s')
        end

        copyToWorkDir(this);

        loadStatus=verifyLoaded(this.ModelName);
        checkDirty(this,true);


        this=setupModel(this);




        this.ReturnWorkspaceOutputs=strcmp(get_param(this.ModelName,'ReturnWorkspaceOutputs'),'on');
        if~this.ReturnWorkspaceOutputs&&isempty(this.SimParams)
            signalLogging=get_param(this.ModelName,'SignalLogging');
            saveOutput=get_param(this.ModelName,'SaveOutput');



            if strcmp(signalLogging,'on')&&strcmp(saveOutput,'on')

                this.SimParams.SaveOutput='on';


            elseif strcmp(signalLogging,'on')
                this.OutputDataName=get_param(this.ModelName,'SignalLoggingName');


            elseif strcmp(saveOutput,'on')
                this.OutputDataName=get_param(this.ModelName,'OutputSaveName');


            else
                DAStudio.error('RTW:cgv:NeedLogMode');
            end
        end

        if~isempty(this.HeaderReportFcn)
            this.HeaderReportFcn(this);
        end





        for inputIndex=1:length(this.InputData)
            this.MetaData(inputIndex).ErrorDetails=[];

            if isempty(this.InputData(inputIndex).pathAndName)
                continue;
            end
            this.MetaData(inputIndex).status='pending';


            disp(DAStudio.message('RTW:cgv:TestingModel',...
            this.ExecEnv.Obj.ComponentType,this.ExecEnv.Obj.Connectivity,...
            this.InputData(inputIndex).pathAndName));
            this=runTest(this,inputIndex);

            disp(DAStudio.message('RTW:cgv:EndTestingModel',this.MetaData(inputIndex).status));

            if~isempty(this.PostExecFcn)
                this.PostExecFcn(this,inputIndex);
            end
            if~isempty(this.PostReportFcn)
                this.PostReportFcn(this,inputIndex);
            end
            if strcmp(this.MetaData(inputIndex).status,'error')
                err=this.MetaData(inputIndex).ErrorDetails;
                disp(DAStudio.message('RTW:cgv:CGVExecutionError'));
                report_error(err);
            end
        end

    catch ME
        disp(ME.getReport);
    end


    if(~isempty(this.UserAddedConfigSet)||~isempty(this.ConfigSetName))
        restoreUserConfigset(this);
    end
    vars_curr=evalin('base','who');





    todelete=setdiff(vars_curr,vars2keep);
    if~isempty(todelete)
        cl='clear ';
        for d=1:length(todelete)
            cl=[cl,todelete{d},' '];%#ok<AGROW>
        end
        evalin('base',cl);
    end
    cd(savedir);
    if isempty(loadStatus)

    elseif strcmp(loadStatus,'notloaded')
        close_system(model,0);
    end
    if~isempty(this.TrailerReportFcn)
        this.TrailerReportFcn(this);
    end

    passed=true;
    for i=1:length(this.MetaData)
        status=this.getStatus();

        assert(~strcmp(status,'none'));
        if strcmp(status,'error')
            passed=false;
        end
    end




    function report_error(err)
        if~isa(err,'MException')
            disp(['*** error: ',err.message]);
        else
            disp(err.getReport);
        end

    end


















    function i_fixForCoverage(this)%#ok<DEFNU>
        cov=get_param(this.ModelName,'RecordCoverage');
        if~strcmp(this.RecordCoverage,'model')
            if~strcmp(this.RecordCoverage,cov)
                set_param(this.ModelName,'RecordCoverage',this.RecordCoverage);
                this.RestoreCoverageSettings{end+1}={'RecordCoverage',cov};
                cov=this.RecordCoverage;
            end
        end
        if strcmp(cov,'on')

            html=get_param(this.ModelName,'CovHTMLReporting');
            if strcmp(html,'on')
                set_param(this.ModelName,'CovHTMLReporting','off');
                this.RestoreCoverageSettings{end+1}={'CovHTMLReporting','on'};
            end
        end
        if~isempty(this.RestoreCoverageSettings)
            set_param(this.ModelName,'dirty','off');
        end
    end

    function i_captureCoverage(this)%#ok<DEFNU>

        if strcmp(get_param(this.ModelName,'RecordCoverage'),'on')&&...
            strcmp(get_param(this.ModelName,'CovSaveCumulativeToWorkspaceVar'),'on')
            covVar=get_param(this.ModelName,'CovCumulativeVarName');
            try
                cvdo=evalin('base',covVar);
                cvsave([this.ModelName,'_cov'],cvdo);
                cvhtmlSettings=cvi.CvhtmlSettings;
                cvhtmlSettings.covHTMLOptions=cvi.ReportUtils.getAllOptions(this.ModelName);
                cvhtmlSettings.covHTMLOptions.dontShowReport=1;
                cvhtmlSettings.covHTMLOptions.covCumulativeReport=1;
                cvhtml([this.ModelName,'_cov'],cvdo,cvhtmlSettings);
            catch ME

            end
        end
        if~isempty(this.RestoreCoverageSettings)
            for j=1:length(this.RestoreCoverageSettings)
                fixup=this.RestoreCoverageSettings{j};
                set_param(this.ModelName,fixup{1},fixup{2});
            end
            set_param(this.ModelName,'dirty','off');
        end
    end

end


