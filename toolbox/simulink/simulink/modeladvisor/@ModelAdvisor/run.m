function CommandLine=run(system,varargin)


































    if ModelAdvisor.isRunning
        CommandLine=[];
        MSLDiagnostic('ModelAdvisor:engine:MARunningInBackground').reportAsWarning;
        return;
    end

    checkInternalUsageForLicense();

    coder.internal.folders.MarkerFile.checkSlprjDirectory(pwd,false);




    if nargin>0
        system=convertStringsToChars(system);
    end

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(nargin==1)
        DAStudio.error('ModelAdvisor:engine:CmdAPICheckIDListMissing');
    end


    [system,rmvOK]=parseSystemlist(system);
    numModels=numel(system);


    if isFirstParamCheckIDList(varargin)
        checkIDList=varargin{1};
        varargin=varargin(2:end);
        checkIDSpecified=true;
    else
        checkIDSpecified=false;
    end

    inputParamParser=parseInputParameters(varargin);
    nameValPair=inputParamParser.Results;

    if strcmpi(nameValPair.tempDir,'on')
        tmpFlag=true;
    else
        tmpFlag=false;
    end

    if~isempty(nameValPair.Configuration)


        if checkIDSpecified
            DAStudio.error('ModelAdvisor:engine:CmdAPIInputArgumentsError');
        end

        confFlag=true;
        configUsed=nameValPair.Configuration;
        [~,~,ext]=fileparts(configUsed);
        if strcmpi(ext,'.json')
            configIsJSON=true;
        else
            configIsJSON=false;
        end
    else
        confFlag=false;
        configIsJSON=false;
        configUsed='None';
    end

    DisplayResultsFlag=nameValPair.DisplayResults;

    if strcmpi(nameValPair.force,'on')
        rmvFlag=false;
    else
        rmvFlag=true&&rmvOK;
    end

    if strcmpi(nameValPair.showexclusions,'off')
        showExclusionsFlag=false;
    else
        showExclusionsFlag=true;
    end

    if~isempty(nameValPair.treatAsMdlRef)
        tMRefvalue=nameValPair.treatAsMdlRef;
        if ischar(tMRefvalue)&&strcmpi(tMRefvalue,'on')
            treatAsMdlRefFlag=true(1,length(system));
        elseif ischar(tMRefvalue)&&strcmpi(tMRefvalue,'off')
            treatAsMdlRefFlag=false(1,length(system));
        elseif iscell(tMRefvalue)
            if length(tMRefvalue)~=length(system)
                DAStudio.error('ModelAdvisor:engine:CmdAPILengthOfTreatAsMdlRefFlagIncorrect');
            end
            treatAsMdlRefFlag=cellfun(@(x)strcmpi(x,'on'),tMRefvalue);
        end
    else
        treatAsMdlRefFlag=false(1,length(system));
    end

    if strcmpi(nameValPair.parallelMode,'on')&&numModels>1
        parallelFlag=true;
    else
        parallelFlag=false;
    end

    if strcmpi(nameValPair.extensiveAnalysis,'off')&&confFlag
        extensiveAnalysisFlag=false;
    elseif strcmpi(nameValPair.extensiveAnalysis,'off')&&~confFlag

        disp(DAStudio.message('ModelAdvisor:engine:MACLIExtensiveWithoutConfig'));

        extensiveAnalysisFlag=true;
    else
        extensiveAnalysisFlag=true;
    end

    logParamsForDDUX(nameValPair,treatAsMdlRefFlag);


    if rmvFlag
        DAStudio.warning('ModelAdvisor:engine:CmdAPIWarningDialogMsg1');
    end

    taskIdx=[];

    if confFlag
        [taskIdx,checkIDList]=extractTaskIDAndCheckIDListFromConfig(configUsed,configIsJSON);
    end

    checkIDList=validateCheckIDList(checkIDList);
    numChecks=numel(checkIDList);


    CommandLine={};
    timeStr=num2str(rem(now,1));

    if~strcmpi(DisplayResultsFlag,'None')
        fprintf('         %s\n',DAStudio.message('ModelAdvisor:engine:CmdAPIRunning'));
    end


    if~parallelFlag
        for ii=1:numModels
            try
                CommandLine{ii}=runMACheckIDListMultMdls(checkIDList,system{ii},numChecks,...
                configUsed,tmpFlag,taskIdx,timeStr,DisplayResultsFlag,showExclusionsFlag,...
                treatAsMdlRefFlag(ii),extensiveAnalysisFlag,nameValPair,numModels);%#ok<AGROW>
            catch err
                warning(err.message);
            end
        end
    else



        am=Advisor.Manager.getInstance;
        am.updateCacheIfNeeded;

        parfor ii=1:numModels
            try
                CommandLine{ii}=runMACheckIDListMultMdls(checkIDList,system{ii},numChecks,...
                configUsed,tmpFlag,taskIdx,timeStr,DisplayResultsFlag,showExclusionsFlag,...
                treatAsMdlRefFlag(ii),extensiveAnalysisFlag,nameValPair,numModels);
            catch err
                warning(err.message);
            end
        end
    end



    if isempty(CommandLine)
        return;
    end

    numModelsPassed=0;
    numModelsFailed=0;
    numModelsNotRun=0;
    numModelsWarn=0;

    for ii=1:numModels
        if~isempty(CommandLine{ii})&&~(CommandLine{ii}.numFail==0&&CommandLine{ii}.numPass==0&&CommandLine{ii}.numWarn==0)

            if CommandLine{ii}.numWarn==0&&CommandLine{ii}.numFail==0
                numModelsPassed=numModelsPassed+1;
            elseif CommandLine{ii}.numFail~=0
                numModelsFailed=numModelsFailed+1;
            else
                numModelsWarn=numModelsWarn+1;
            end

            if strcmpi(DisplayResultsFlag,'Details')
                CommandLine{ii}.displaySummary('NoSummaryLink');
            end
        else

            numModelsNotRun=numModelsNotRun+1;
        end
    end

    if~strcmpi(DisplayResultsFlag,'None')
        fprintf('\n         %s%s\n',[DAStudio.message('ModelAdvisor:engine:CmdAPISysPassed'),': '],DAStudio.message('ModelAdvisor:engine:CmdAPIOf',num2str(numModelsPassed),num2str(numModels)));
        fprintf('\n         %s%s\n',[DAStudio.message('ModelAdvisor:engine:CmdAPISysWarnings'),': '],DAStudio.message('ModelAdvisor:engine:CmdAPIOf',num2str(numModelsWarn),num2str(numModels)))
        fprintf('\n         %s%s\n',[DAStudio.message('ModelAdvisor:engine:CmdAPISysFailed'),': '],DAStudio.message('ModelAdvisor:engine:CmdAPIOf',num2str(numModelsFailed),num2str(numModels)))
        if numModelsNotRun~=0
            fprintf('\n         %s%s\n',[DAStudio.message('ModelAdvisor:engine:CmdAPISysNotRun'),': '],DAStudio.message('ModelAdvisor:engine:CmdAPIOf',num2str(numModelsNotRun),num2str(numModels)))
        end
        modeladvisorprivate('cacheHTMLdata','set',CommandLine,timeStr);
        if feature('hotlinks')

            timeStrs='';
            for iii=1:numel(CommandLine)
                timeStrs=[timeStrs,timeStr,' '];
            end
            fprintf('         %s\n',['<a href="matlab: modeladvisorprivate cacheHTMLdata summaryReport ',timeStrs,' ">',DAStudio.message('ModelAdvisor:engine:CmdAPISummaryReport'),'</a>']);
        else
            fprintf('         %s\n',DAStudio.message('ModelAdvisor:engine:CmdAPINoHotLinks'));
        end
    end

end

function CommandLine=runMACheckIDListMultMdls(checkIDList,system,numChecks,configUsed,tmpFlag,...
    taskIdx,timeStr,DisplayResultsFlag,showExclusionsFlag,treatAsMdlRefFlag,extensiveAnalysisFlag,...
    nameValPair,numModels)
    try
        CommandLine=ModelAdvisor.SystemResult;
        CommandLine.system=system;
        CommandLine.uniqueCode=timeStr;

        numPass=0;
        numWarn=0;
        numFail=0;
        numNotRun=0;

        customReport='';

        idx=strfind(system,'/');
        if~isempty(idx)
            model=system(1:idx(1)-1);
        else
            model=system;
        end

        if strcmpi(DisplayResultsFlag,'Summary')
            fprintf('%s',repmat(sprintf('\b'),1,1))
            fprintf('%s','...');

            disp(' ');
        end

        if strcmpi(DisplayResultsFlag,'Details')
            disp(['         ',DAStudio.message('ModelAdvisor:engine:CmdAPIRunningSystemOn'),' ',system]);
        end

        AlreadyInPath=0;
        if ispc
            AlreadyInPath=isempty(strfind(lower(path),lower(pwd)));
        else
            AlreadyInPath=isempty(strfind(path,pwd));
        end
        if tmpFlag
            cwd=pwd;
            if AlreadyInPath==1
                addpath(cwd)
            end
            tmpdir=tempname;
            mkdir(tmpdir);
            cd(tmpdir);
        end
        isopen=bdIsLoaded(model);
        if(~isopen)
            load_system(model);
        end

        reportObj=getReportObj(nameValPair);

        if numModels>1&&~isempty(reportObj)
            reportObj.ReportName=[reportObj.ReportName,'_',model];
        end


        p=ModelAdvisor.Preferences();
        p.CommandLineRun=true;

        if~strcmpi(configUsed,'none')
            maObj=Simulink.ModelAdvisor.getModelAdvisor(system,'new','','configuration',configUsed);
        else
            maObj=Simulink.ModelAdvisor.getModelAdvisor(system,'new','','configuration','');
        end
        maObj.CmdLine=true;
        maObj.runInBackground=false;
        maObj.ShowExclusions=showExclusionsFlag;
        maObj.treatAsMdlref=treatAsMdlRefFlag;
        workDir=maObj.getWorkDir;


        if tmpFlag
            maObj.AtticData.WorkDir=workDir;
            maObj.AtticData.DiagnoseRightFrame=[workDir,filesep,'report.html'];
        end

        for inx=1:numChecks
            checkCommandLine(inx)=ModelAdvisor.CheckResult(system);%#ok<AGROW>
        end

        tmpcheckIDList={};

        jnx=1;
        for inx=1:numChecks
            if iscell(checkIDList{inx})&&length(checkIDList{inx})>2&&strcmpi(checkIDList{inx}{2},'inputparam')

                inputParams=checkIDList{inx};
                checkCommandLine(inx).checkID=inputParams{1};
                cnt=1;

                if~strcmpi(configUsed,'none')
                    checkObj{inx}=maObj.TaskAdvisorCellArray{taskIdx(inx)}.Check;%#ok<AGROW>
                else
                    checkObj{inx}=maObj.getCheckObj(inputParams{1});%#ok<AGROW>
                end

                if~isempty(checkObj{inx})
                    checkCommandLine(inx).index=checkObj{inx}.index;
                    tmpcheckIDList{jnx}=inputParams{1};%#ok<AGROW>
                    jnx=jnx+1;
                    for knx=1:2:length(inputParams{3})
                        paramIdx=[];
                        for idx=1:length(maObj.getCheckObj(inputParams{1}).InputParameters)
                            if(strcmpi(maObj.getCheckObj(inputParams{1}).InputParameters{idx}.name,inputParams{3}{knx}))
                                paramIdx=idx;
                                break;
                            end
                        end
                        if~isempty(paramIdx)
                            checkCommandLine(inx).paramName{cnt}=inputParams{3}{knx};
                            checkCommandLine(inx).paramValue{cnt}=inputParams{3}{knx+1};
                            maObj.getCheckObj(inputParams{1}).InputParameters{paramIdx}.Value=inputParams{3}{knx+1};
                            cnt=cnt+1;
                        end
                    end
                else
                    CommandLine.setReport('Invalid Check ID');
                    fprintf('         %s\n',DAStudio.message('ModelAdvisor:engine:CmdAPINotValidCheckID',inputParams{1}));
                    checkCommandLine(inx).status='Invalid Check ID';
                end
            else

                if iscell(checkIDList{inx})
                    checkIDList{inx}=checkIDList{inx}{1};
                end

                checkCommandLine(inx).checkID=checkIDList{inx};

                if~strcmpi(configUsed,'none')
                    checkObj{inx}=maObj.TaskAdvisorCellArray{taskIdx(inx)}.Check;%#ok<AGROW>
                else
                    checkObj{inx}=maObj.getCheckObj(checkIDList{inx});%#ok<AGROW>
                end

                if~isempty(checkObj{inx})
                    checkCommandLine(inx).index=checkObj{inx}.index;
                    tmpcheckIDList{jnx}=checkIDList{inx};%#ok<AGROW>
                    jnx=jnx+1;
                else
                    CommandLine.setReport('Invalid Check ID');
                    if~isempty(checkIDList{inx})
                        fprintf('         %s\n',DAStudio.message('ModelAdvisor:engine:CmdAPINotValidCheckID',checkIDList{inx}));
                    else
                        fprintf('         %s\n',DAStudio.message('ModelAdvisor:engine:CmdAPINotValidCheckID',''' '''));
                    end
                    checkCommandLine(inx).status='Invalid Check ID';
                end
            end
        end
        checkIDList=tmpcheckIDList;

        if isempty(checkIDList)


            CommandLine.CheckResultObjs=checkCommandLine;
            CommandLine.numNotRun=0;
            CommandLine.numWarn=numWarn;
            CommandLine.numPass=numPass;
            CommandLine.numFail=length(checkCommandLine);

            if(~isopen)
                close_system(model);
            end

            if tmpFlag
                cleanDir(cwd,AlreadyInPath,tmpdir);
            end



            return;

        end

        if~strcmpi(configUsed,'none')
            oldVal=maObj.TaskAdvisorRoot.ExtensiveAnalysis;

            maObj.TaskAdvisorRoot.ExtensiveAnalysis=extensiveAnalysisFlag;
            ExtensiveCheckIds=containsExtensiveChecks(maObj.TaskAdvisorRoot);

            if~isempty(ExtensiveCheckIds)
                if~extensiveAnalysisFlag

                    disp(DAStudio.message('ModelAdvisor:engine:MACLIExtensiveChecksNotRun',strjoin(ExtensiveCheckIds,', ')));
                else


                    disp(DAStudio.message('ModelAdvisor:engine:MACLIExtensiveCheckingMessage'));
                end
            end



            if(~isempty(reportObj)&&~isa(reportObj,'ModelAdvisor.AdvisorReportHTML'))
                maObj.TaskAdvisorRoot.OverwriteHTML=false;
            end

            maObj.TaskAdvisorRoot.runTaskAdvisor;

            maObj.TaskAdvisorRoot.ExtensiveAnalysis=oldVal;
            if~isempty(reportObj)
                reportObj.ModelName=system;
                customReport=reportObj.generateReportForNode(maObj.TaskAdvisorRoot);
            end

        else
            if~isempty(reportObj)
                maObj.runCheck(checkIDList,isa(reportObj,'ModelAdvisor.AdvisorReportHTML'));
                reportObj.ModelName=system;
                customReport=reportObj.generateReportForChecks(checkIDList);
            else
                maObj.runCheck(checkIDList);
            end

        end

        for jnx=1:numChecks
            if isempty(checkObj{jnx})

                checkCommandLine(jnx).status='Invalid Check ID';

                if~strcmpi(configUsed,'none')






                    if maObj.TaskAdvisorCellArray{taskIdx(jnx)}.Selected
                        numFail=numFail+1;
                    else
                        numNotRun=numNotRun+1;
                    end
                else




                    numFail=numFail+1;
                end

            elseif(~strcmpi(configUsed,'none')&&(maObj.TaskAdvisorCellArray{taskIdx(jnx)}.state==ModelAdvisor.CheckStatus.NotRun))...
                ||(~(checkObj{jnx}.enable)&&~(checkObj{jnx}.selected))
                numNotRun=numNotRun+1;
                checkCommandLine(jnx).status='Not Run';
            else
                switch checkObj{jnx}.status
                case ModelAdvisor.CheckStatus.Warning
                    checkCommandLine(jnx).status='Warning';
                    numWarn=numWarn+1;
                case ModelAdvisor.CheckStatus.Failed
                    checkCommandLine(jnx).status='Fail';
                    numFail=numFail+1;
                case ModelAdvisor.CheckStatus.Passed
                    checkCommandLine(jnx).status='Pass';
                    numPass=numPass+1;
                case ModelAdvisor.CheckStatus.NotRun
                    checkCommandLine(jnx).status='Not Run';
                    numNotRun=numNotRun+1;
                otherwise
                    checkCommandLine(jnx).status='Fail';
                    numFail=numFail+1;
                end
                checkCommandLine(jnx).html=checkObj{jnx}.ResultInHTML;
            end
            if~strcmpi(configUsed,'none')
                checkCommandLine(jnx).checkName=maObj.TaskAdvisorCellArray{taskIdx(jnx)}.DisplayName;
            else
                if~isempty(checkObj{jnx})
                    checkCommandLine(jnx).checkName=checkObj{jnx}.Title;
                end
            end
        end
        report='';
        report=[report,'         ============================================================\n'];
        report=[report,'         ',DAStudio.message('ModelAdvisor:engine:CmdAPIMARun'),' ',datestr(now),'\n'];
        report=[report,'         ',DAStudio.message('ModelAdvisor:engine:CmdAPIConfiguration'),' ',regexprep(configUsed,'\\','\\\\'),'\n'];
        report=[report,'         ',DAStudio.message('ModelAdvisor:engine:CmdAPISystem'),': ',system,'\n'];
        report=[report,'         ',DAStudio.message('ModelAdvisor:engine:CmdAPIMASystemVersion'),' ',num2str(get_param(bdroot(system),'Version')),'\n'];
        report=[report,'         ',DAStudio.message('ModelAdvisor:engine:CmdAPICreatedBy'),' ',get_param(model,'creator'),'\n'];
        report=[report,'         ============================================================\n'];

        for jnx=1:numChecks
            if strcmp(checkCommandLine(jnx).status,'Not Run')||strcmp(checkCommandLine(jnx).status,'Invalid Check ID')
                tmpStr=checkCommandLine(jnx).status;
            else
                tmpStr=['<a href="matlab: modeladvisorprivate cacheHTMLdata ',num2str(jnx),' ','''',system,'''',' ',timeStr,'">',checkCommandLine(jnx).status,'</a>'];
            end
            report=[report,'         (',num2str(jnx),') '...
            ,tmpStr,...
            ': ',regexprep(checkCommandLine(jnx).checkName,'\\','\\\\')...
            ,' [',DAStudio.message('ModelAdvisor:engine:CmdAPICheckID'),' ',regexprep(checkCommandLine(jnx).checkID,'\\','\\\\'),']\n'];%#ok<AGROW>
            report=[report,'         ------------------------------------------------------------\n'];%#ok<AGROW>
        end
        report=[report,'         ',DAStudio.message('ModelAdvisor:engine:CmdAPISummary'),'    ',DAStudio.message('ModelAdvisor:engine:CmdAPIPass'),'    ',DAStudio.message('ModelAdvisor:engine:CmdAPIWarning'),'    ',DAStudio.message('ModelAdvisor:engine:CmdAPIFail'),'    ',DAStudio.message('ModelAdvisor:engine:CmdAPINotRun'),'\n'];

        statusNumbers='                                                  ';
        statusNumbers(14:13+length(num2str(numPass)))=num2str(numPass);
        statusNumbers(23:22+length(num2str(numWarn)))=num2str(numWarn);
        statusNumbers(34:33+length(num2str(numFail)))=num2str(numFail);
        statusNumbers(44:43+length(num2str(numNotRun)))=num2str(numNotRun);
        report=[report,'         ',statusNumbers,'\n'];
        report=[report,'         ============================================================\n'];
        CommandLine.setReport(report);
        CommandLine.numPass=numPass;
        CommandLine.numWarn=numWarn;
        CommandLine.numFail=numFail;
        CommandLine.numNotRun=numNotRun;
        CommandLine.CheckResultObjs=checkCommandLine;

        if~maObj.IsLibrary
            if strcmp(system,bdroot(system))
                CommandLine.Type='Model';
            else
                CommandLine.Type='Subsystem';
            end
        end

        maObj.CmdLine=false;

        if(~isopen)
            close_system(model);
        else

            modeladvisorprivate('modeladvisorutil2','SaveTaskAdvisorInfo',maObj);
            if isfield(maObj.AtticData,'saveMAGeninfoData')&&~isempty(maObj.AtticData.saveMAGeninfoData)
                if exist(maObj.Database.FileLocation,'file')
                    maObj.Database.saveMAGeninfoData(maObj.AtticData.saveMAGeninfoData{:});
                end
            end
        end
        CommandLine.setData(workDir);
        if tmpFlag
            cleanDir(cwd,AlreadyInPath,tmpdir);
        end
    catch err
        CommandLine.setReport(err.message);
        fprintf('         %s\n',[DAStudio.message('ModelAdvisor:engine:CmdAPIWarning'),': ',err.message]);
        disp('  ');
        if~isempty(find_system('type','block_diagram','name',model))&&(~isopen)
            close_system(model,0);
        end
        if tmpFlag
            cleanDir(cwd,AlreadyInPath,tmpdir);
        end
    end


    p=ModelAdvisor.Preferences();
    p.CommandLineRun=false;


    if~isempty(customReport)
        CommandLine.setReportFileName(customReport);
    end

end

function cleanDir(cwd,AlreadyInPath,tmpdir)
    mxList=dir(['*.',mexext]);
    if~isempty(mxList)
        clearStr='clear ';
        for mx=1:length(mxList)
            clearStr=[clearStr,' ',mxList(mx).name];%#ok<AGROW>
        end
        clearStr=[clearStr,';'];
        eval(clearStr);
    end
    cd(cwd);
    slprivate('removeDir',tmpdir);
    if AlreadyInPath==1
        rmpath(cwd);
    end
end

function[taskIdx,checklist]=extractCheckIdList(configArray,idx,checklist,taskIdx)
    for ii=1:length(configArray{idx}.ChildrenObj)
        childObj=configArray(configArray{idx}.ChildrenObj{ii}+1);
        if strcmp(childObj{1}.type,'Group')
            [taskIdx,checklist]=extractCheckIdList(configArray,configArray{idx}.ChildrenObj{ii}+1,checklist,taskIdx);
        else
            checklist=[checklist,childObj{1}.MAC];%#ok<AGROW>
            taskIdx=[taskIdx,childObj{1}.Index];%#ok<AGROW>
        end
    end
end

function[taskIdx,checklist]=extractCheckIdListJSON(configArray,checklist,taskIdx)
    if~iscell(configArray)
        configArray=num2cell(configArray);
    end
    for ii=1:length(configArray)
        if~isempty(configArray{ii}.checkid)
            checklist=[checklist,configArray{ii}.checkid];%#ok<AGROW>
            taskIdx=[taskIdx,ii-1];%#ok<AGROW>
        end
    end
end


function exists=getWorkDir(system)
    exists=false;
    pathArray={};
    idx=strfind(system,'/');
    if~isempty(idx)
        parentSystem=system(1:idx(1)-1);
    else
        parentSystem=system;
    end

    pathArray{1}=escapeAllSpecialCharacters(parentSystem);
    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootBDir=fileGenCfg.CacheFolder;
    WorkDir=fullfile(rootBDir,'slprj','modeladvisor',pathArray{1});
    if exist(WorkDir,'dir')
        exists=true;
    end
end





function output=escapeAllSpecialCharacters(input)
    output='';

    AtoZand0to9=['_',char(48:57),char(65:90),char(97:122)];
    for i=1:length(input)
        if ismember(input(i),AtoZand0to9)
            output=[output,input(i)];%#ok<AGROW>
        else
            output=[output,'_',sprintf('%x',double(input(i)))];%#ok<AGROW>
        end
    end
end

function extensiveChecks=containsExtensiveChecks(taskRoot)

    extensiveChecks={};
    if isa(taskRoot,'ModelAdvisor.Task')
        if~isempty(taskRoot.Check)&&any(strcmp(taskRoot.Check.CallbackContext,{'SLDV','CGIR'}))
            extensiveChecks=[extensiveChecks,taskRoot.Check.ID];
        end
    else
        for i=1:length(taskRoot.ChildrenObj)
            if~(isa(taskRoot.ChildrenObj{i},'ModelAdvisor.Procedure')&&~isa(taskRoot,'ModelAdvisor.Procedure'))
                extensiveChecks=[extensiveChecks,containsExtensiveChecks(taskRoot.ChildrenObj{i})];%#ok<AGROW>
            end
        end
    end
end

function ipParser=parseInputParameters(ipValues)
    generateCustomReport=any(strcmp(ipValues,'ReportName'))||...
    any(strcmp(ipValues,'ReportFormat'))||...
    any(strcmp(ipValues,'ReportPath'));
    ipParser=inputParser;
    if generateCustomReport
        addParameter(ipParser,'ReportFormat','html',@(x)ischar((validatestring(x,{'pdf','html','docx'}))))
        addParameter(ipParser,'ReportPath','',@(x)ischar(x))
        addParameter(ipParser,'ReportName','',@(x)ischar(x))
    end
    addParameter(ipParser,'tempDir','off',@(x)ischar((validatestring(x,{'on','off'}))))
    addParameter(ipParser,'Configuration',[],@validateConfigruationArgs)
    addParameter(ipParser,'DisplayResults','Summary',@(x)ischar((validatestring(x,{'None','Summary','Details'}))))
    addParameter(ipParser,'force','off',@(x)ischar((validatestring(x,{'on','off'}))))
    addParameter(ipParser,'showexclusions','on',@(x)ischar((validatestring(x,{'on','off'}))))
    addParameter(ipParser,'treatAsMdlRef',[],@validatetreatAsMdlRefArgs);
    addParameter(ipParser,'parallelMode','off',@(x)ischar((validatestring(x,{'on','off'}))))
    addParameter(ipParser,'extensiveAnalysis','on',@(x)ischar((validatestring(x,{'on','off'}))))

    try
        parse(ipParser,ipValues{:});
    catch ME
        if strcmp(ME.identifier,'MATLAB:InputParser:ParamMissingValue')
            throwMissingParamValueError(ME.message);
        elseif strcmp(ME.identifier,'MATLAB:unrecognizedStringChoice')
            throwInvalidParamValueError(ME.message);
        else
            throw(ME);
        end
    end
end


function throwMissingParamValueError(err)
    if any(contains(err,'''tempDir'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPITempdirParamMissing');
    elseif any(contains(err,'''Configuration'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIConfigurationParamMissing');
    elseif any(contains(err,'''DisplayResults'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIDisplayResultsParamMissing');
    elseif any(contains(err,'''force'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIForceParamMissing');
    elseif any(contains(err,'''showexclusions'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIShowExclusionParamMissing');
    elseif any(contains(err,'''treatAsMdlRef'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPITreatAsMdlRefParamMissing');
    elseif any(contains(err,'''parallelMode'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIParallelModeParamMissing');
    elseif any(contains(err,'''extensiveAnalysis'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIExtensiveAnalysisParamMissing');
    else
        DAStudio.error('ModelAdvisor:engine:CmdAPIInputArgumentsError');
    end
end

function throwInvalidParamValueError(err)
    if any(contains(err,'''tempDir'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPITempdirParamInValid');
    elseif any(contains(err,'''DisplayResults'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIDisplayResultsParamInValid');
    elseif any(contains(err,'''force'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIForceParamInValid');
    elseif any(contains(err,'''showexclusions'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIShowExclusionsParamInValid');
    elseif any(contains(err,'''treatAsMdlRef'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPITreatAsMdlRefParamInValid');
    elseif any(contains(err,'''parallelMode'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIParallelModeParamInValid');
    elseif any(contains(err,'''extensiveAnalysis'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIExtensiveAnalysisParamInValid');
    elseif any(contains(err,'''ReportFormat'''))
        DAStudio.error('ModelAdvisor:engine:CmdAPIReportFormatParamInValid');
    end
end

function flag=validateConfigruationArgs(str)
    [~,~,ext]=fileparts(str);
    try

        flag=ischar(validatestring(ext,{'.mat','.json',''}));
    catch ME
        DAStudio.error('ModelAdvisor:engine:CmdAPIConfigurationParamMAT');
    end
end

function flag=validatetreatAsMdlRefArgs(str)
    if iscell(str)
        for strCount=1:numel(str)
            flag=ischar(validatestring(str{strCount},{'on','off'}));
        end
    elseif ischar(str)
        flag=ischar(validatestring(str,{'on','off'}));
    else
        DAStudio.error('ModelAdvisor:engine:CmdAPITreatAsMdlRefParamInValidCharVec');
    end
end

function[system,rmvOK]=parseSystemlist(system)
    rmvOK=false;

    if ischar(system)||(iscell(system)&&length(system)==1)

        if ischar(system)
            system={system};
        end

        if getWorkDir(system{1})
            rmvOK=true;
        end

    elseif iscell(system)

        [x,a,~]=unique(system);

        if~(length(x)==length(system))
            disp(['        ',DAStudio.message('ModelAdvisor:engine:CmdAPIDuplicateSystems')]);
            system=system(sort(a));
        end

        numModels=length(system);

        for i=1:numModels
            if getWorkDir(system{i})
                rmvOK=true;
                break;
            end
        end

    else
        DAStudio.error('ModelAdvisor:engine:CmdAPISystemChar');
    end

end

function checkInternalUsageForLicense()
    caller=dbstack;
    internalUsage=false;
    for i=1:length(caller)
        if(~isempty(strfind(caller(i).file,'checkCompatibility'))&&...
            (strcmp(caller(i).name,'checkCompatibility')||strcmp(caller(i).name,'Configuration.checkCompatibility')))...
            ||(~isempty(strfind(caller(i).file,'Analyzer'))&&...
            (strcmp(caller(i).name,'Analyzer.execStowawayDoubleCheck')))
            internalUsage=true;
            break;
        end
    end

    if~internalUsage
        if(Advisor.Utils.license('test','SL_Verification_Validation')==1)
            Advisor.Utils.license('checkout','SL_Verification_Validation');
        else
            DAStudio.error('ModelAdvisor:engine:CmdAPILicenseFailed');
        end
    end
end

function flag=isFirstParamCheckIDList(inputParams)




    flag=true;







    nameValues={'tempDir','Configuration','DisplayResults','force',...
    'showexclusions','treatAsMdlRef','parallelMode',...
    'extensiveAnalysis'};






    for count=1:numel(inputParams)

        paramName=inputParams{1};

        if iscell(paramName)
            flag=true;
            return
        end

        if contains(paramName,nameValues,'IgnoreCase',true)
            flag=false;
            return
        end
    end
end


function[taskIdx,checkIDList]=extractTaskIDAndCheckIDListFromConfig(configUsed,configIsJSON)
    if configIsJSON
        tconfigArray=jsondecode(fileread(configUsed));
        if isfield(tconfigArray,'Tree')
            tconfigArray=tconfigArray.Tree;
        end
        [taskIdx,checkIDList]=extractCheckIdListJSON(tconfigArray,{},[]);
    else
        tmpVar=load(configUsed);
        if~isfield(tmpVar,'configuration')
            DAStudio.error('ModelAdvisor:engine:CmdAPIConfigurationParamInValid',configUsed);
        end

        if modeladvisorprivate('modeladvisorutil2','FeatureControl','CompressedMACEFormat')&&...
            ~isfield(tmpVar.configuration,'ReducedTree')

            [tmpVar.configuration.ConfigUIRoot,tmpVar.configuration.ConfigUICellArray]=modeladvisorprivate('modeladvisorutil2','TrimUnusedTrees',tmpVar.configuration.ConfigUIRoot,tmpVar.configuration.ConfigUICellArray);

        end
        tconfigArray=[{tmpVar.configuration.ConfigUIRoot},tmpVar.configuration.ConfigUICellArray];
        [taskIdx,checkIDList]=extractCheckIdList(tconfigArray,1,{},[]);
    end
end

function checkIDList=validateCheckIDList(checkIDList)

    if(~iscell(checkIDList))
        checkIDList={checkIDList};
    end

    numChecks=length(checkIDList);

    for i=1:numChecks
        if iscell(checkIDList{i})&&length(checkIDList{i})>1&&~strcmpi(checkIDList{i}{2},'inputparam')
            DAStudio.error('ModelAdvisor:engine:CmdAPICheckIDListInValid');
        end
    end

end


function reportObj=getReportObj(nameValPair)
    if isfield(nameValPair,'ReportFormat')&&...
        slfeature('GenerateAdvisorReport')
        if strcmpi(nameValPair.ReportFormat,'docx')
            reportObj=ModelAdvisor.AdvisorReportDOCX;
        elseif strcmpi(nameValPair.ReportFormat,'pdf')
            reportObj=ModelAdvisor.AdvisorReportPDF;
        else
            reportObj=ModelAdvisor.AdvisorReportHTML;
        end
        reportObj.ReportName=nameValPair.ReportName;
        reportObj.ReportPath=nameValPair.ReportPath;
    else
        reportObj=[];
    end
end

function logParamsForDDUX(dduxNameValPair,treatAsMdlRefFlag)


    if(isempty(dduxNameValPair.Configuration))
        dduxNameValPair.Configuration='';
    else
        dduxNameValPair.Configuration='custom';
    end

    if(any(treatAsMdlRefFlag))
        dduxNameValPair.treatAsMdlRef='used';
    else
        dduxNameValPair.treatAsMdlRef='unused';
    end

    if(isfield(dduxNameValPair,'ReportPath'))
        dduxNameValPair=rmfield(dduxNameValPair,'ReportPath');
    end
    if(isfield(dduxNameValPair,'ReportName'))
        dduxNameValPair=rmfield(dduxNameValPair,'ReportName');
    end

    dduxNameValPair=namedargs2cell(dduxNameValPair);

    Simulink.DDUX.logData('CLI_MARUN','marun',convertCharsToStrings(dduxNameValPair));

end
