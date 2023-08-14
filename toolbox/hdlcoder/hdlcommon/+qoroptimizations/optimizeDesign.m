



function optimizeDesign(model,varargin)

    if~isempty(model)
        model=convertStringsToChars(model);
    end
    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    guidanceFile=fullfile('.','cpGuidance.mat');
    lastGuidanceFile=[guidanceFile(1:end-4),'_last.mat'];
    cpAnnotationFile=fullfile('.','cpAnnotation.mat');
    logFile='log.mat';
    archDirParent='..';
    currFolder='curr';
    projFolder='hdl_prj';
    codeFolder='hdlsrc';
    summaryFile='summary.html';
    toolVersion=ver('HDLCoder');
    sanityCheckMessage='';



    minimumConstraint=1e-4;

    assert(nargin==2);
    if(~ischar(model))

        error(message('hdlcoder:optimization:InvalidFirstArgument',message('hdlcoder:optimization:InvalidModelName').getString));
    end
    arg1=varargin{1};


    modelchip=hdlget_param(model,'HDLSubsystem');
    if(isequal(modelchip,model))
        chip='';
    else
        if(modelchip(length(model)+1)~='/')

            error(message('hdlcoder:optimization:UseForwardSlashInPath'));
        end
        chip=modelchip(length(model)+2:end);
    end

    if(isa(arg1,'hdlcoder.OptimizationConfig'))
        optimConfig=arg1.duplicate();
        doSynthesis=strcmpi(optimConfig.TimingStrategy,'Synthesis');
        sanityCheckMessage=sanityCheckForOptimize(model,chip,optimConfig,projFolder,doSynthesis);
        regen=false;
    elseif(ischar(arg1))
        bestGuidanceFilePath=arg1;
        regen=true;
    else

        error(message('hdlcoder:optimization:InvalidSecondArgument',message('hdlcoder:optimization:GuidanceOrConfig').getString));
    end

    explFolder=fullfile(getcodegenbasedir(model,modelchip,hdlget_param(model,'TargetDirectory'),hdlget_param(model,'TargetSubdirectory')),'hdlexpl');

    oldFolder=pwd;
    oldPathVal=path;

    try
        prepareWorkingFolders(explFolder,currFolder);
        log=assemblelog();

        if(regen)
            [bestGuidanceFileFolder,guidanceFile,ext]=fileparts(bestGuidanceFilePath);


            if(isempty(bestGuidanceFileFolder)||(bestGuidanceFileFolder(1)~='/'&&length(bestGuidanceFileFolder)>1...
                &&bestGuidanceFileFolder(2)~=':'))
                bestGuidanceFileFolder=fullfile(oldFolder,bestGuidanceFileFolder);
            end
            if(~isempty(ext))
                guidanceFile=[guidanceFile,ext];
            end
            finalCodeGen(model,chip,-1,codeFolder,cpAnnotationFile,guidanceFile,bestGuidanceFileFolder,true);
        else
            resumptionPoint=optimConfig.ResumptionPoint;

            if(isempty(resumptionPoint))
                if(optimConfig.ExplorationMode==hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency)


                    constraint=max(floor(1/optimConfig.TargetFrequency*1000*100)/100,minimumConstraint);
                else
                    constraint=minimumConstraint;
                end

                iterCtrl.cplatency=inf;
                iterCtrl.constraint=constraint;
                iterCtrl.last_cplatency=inf;
                iterCtrl.maxFailedLatency=0;
                iterCtrl.minAchievedLatency=inf;
                iterCtrl.optimalLatency=0;
                iterCtrl.guidedCPEmpty=false;
                iterCtrl.bestArchFolder='this';
                iterCtrl.iter=0;
            else

                printfToScreen(1,message('hdlcoder:optimization:ResumptionNote',strrep(resumptionPoint,'\','\\')).getString);
                [iterCtrl,log,optimConfig]=qoroptimizations.restoreSnapshot(resumptionPoint,archDirParent,logFile,model,chip);
                doSynthesis=strcmpi(optimConfig.TimingStrategy,'Synthesis');
            end
            actFirstIterNum=iterCtrl.iter;

            while(true)
                t=tic;




                if(~regen&&(iterCtrl.iter==1||iterCtrl.iter==2))
                    gp=pir;
                    if(~gp.isDelayBalancable)
                        hC=gp.getBalanceFailureCulprit;
                        msg=gp.getBalanceFailureReason;
                        if isempty(hC)
                            error(message('hdlcoder:optimization:DBFailOriginalDesign',message('hdlcoder:engine:pathbalancing',msg).getString()));
                        else
                            error(message('hdlcoder:optimization:DBFailOriginalDesign',message('hdlcoder:engine:pathbalancing1',msg,hC).getString()));
                        end
                    end
                end
                if(iterCtrl.iter>0)
                    gp=pir;
                    assert(gp.getBalanceFailureId==0);
                end



                if(iterCtrl.iter~=actFirstIterNum)

                    archFolder=qoroptimizations.makeLogDir(sprintf('Iter%d-',iterCtrl.iter),'',archDirParent);
                    if(strcmp(iterCtrl.bestArchFolder,'this'))
                        iterCtrl.bestArchFolder=archFolder;
                    end
                    hDriver=hdlmodeldriver(model);
                    if(isequal(hDriver.OrigStartNodeName,hDriver.getStartNodeName))
                        topNode=model;
                    else
                        topNode=hDriver.getStartNodeName;
                    end
                    log(end+1)=assemblelog(iterCtrl,cpSet,pir(topNode),elapsedTime,commandLog);
                    tempData.log=log;tempData.optimConfig=optimConfig;tempData.toolVersion=toolVersion;tempData.sanityCheckMessage=sanityCheckMessage;
                    qoroptimizations.saveFile(logFile,tempData,model);





                    printfToScreen(1,sprintf('%s\n',message('hdlcoder:optimization:IterationLog',...
                    sprintf('%.2f',log(end).iterCtrl.cplatency),...
                    sprintf('%.2f',log(end).iterCtrl.constraint),...
                    sprintf('%.2f',sum([log.elapsedTime]))).getString)...
                    );
                    qoroptimizations.archiveSnapshot(optimConfig.Archive,archFolder,logFile,guidanceFile,lastGuidanceFile,cpAnnotationFile);
                    if(strcmp(iterCtrl.bestArchFolder,'this'))
                        iterCtrl.bestArchFolder=archFolder;
                    end
                end


                printfToScreen(1,message('hdlcoder:optimization:IterationLog1',sprintf('%d',iterCtrl.iter)).getString);
                [commandLog,status,iterCtrl,cpSet,log]=iterProcess(iterCtrl,model,chip,optimConfig.IterationLimit,optimConfig.ExplorationMode,optimConfig.Archive,doSynthesis,guidanceFile,lastGuidanceFile,cpAnnotationFile,oldFolder,projFolder,explFolder,currFolder,codeFolder,log);

                elapsedTime=toc(t);

                if(status)
                    break;
                end

                iterCtrl.iter=iterCtrl.iter+1;
            end



            bestGuidanceFileFolder=log(end).iterCtrl.bestArchFolder;
            assert(~strcmp(bestGuidanceFileFolder,'this'));




            finalCodeGen(model,chip,-1,codeFolder,cpAnnotationFile,guidanceFile,bestGuidanceFileFolder,false);

            tempGuidance=load(guidanceFile);
            hdrv=hdlmodeldriver(model);
            gmModel=hdrv.BackEnd.OutModelFile;

            offendingBlocksMessage='';
            if~doSynthesis
                offendingBlocksMessage=checkCriticalPathEstimationOffendingBlocks(explFolder,currFolder,codeFolder,model);
            end
            if~isempty(offendingBlocksMessage)
                warning(message('hdlcoder:optimization:OptimizationInaccurateNote',offendingBlocksMessage));
            end


            qoroptimizations.printSummaryHtml(model,gmModel,log,tempGuidance.diagnostics,sanityCheckMessage,commandLog,summaryFile,doSynthesis,offendingBlocksMessage);

            printfToScreen(1,'%s <a href="matlab:web(''%s'');">%s</a>\n',message('hdlcoder:optimization:SummaryReport').getString,which(fullfile('.',summaryFile)),summaryFile);




            summaryLogStr=message('hdlcoder:optimization:SummaryLog',...
            sprintf('%.2f',log(end).iterCtrl.minAchievedLatency),sprintf('%.2f',sum([log.elapsedTime]))).getString;
            for i=1:length(log)
                elapsed=[log.elapsedTime];







                summaryLogStr=sprintf('%s%s\n',...
                summaryLogStr,...
                message('hdlcoder:optimization:SummaryLog1',sprintf('%d',i-1),...
                sprintf('%.2f',log(i).iterCtrl.cplatency),...
                sprintf('%.2f',log(i).iterCtrl.constraint),...
                sprintf('%.2f',sum(elapsed(1:i)))).getString...
                );
            end
            printfToScreen(1,summaryLogStr);

        end

        srcDir=fullfile('.','*');
        dstDir=qoroptimizations.makeLogDir('Final-','',archDirParent);
        s=copyfile(srcDir,dstDir);
        if(~s)
            error(message('hdlcoder:optimization:CannotCopyFinalResults',dstDir));
        end
        dstDirFullPath=fullfile(pwd,dstDir);

        printfToScreen(1,'%s <a href="matlab:cd(''%s'');">%s</a>\n',message('hdlcoder:optimization:FinalResultsNote').getString,dstDirFullPath,dstDirFullPath);
        hdrv=hdlmodeldriver(model);
        covalModel=hdrv.CoverifyModelName;
        if~isempty(covalModel)

            printfToScreen(1,'%s <a href="matlab:open_system(''%s'');">%s</a>\n',message('hdlcoder:optimization:ValidationModel').getString,covalModel,covalModel);
        end

    catch me
        restoreFolders(oldFolder,oldPathVal);
        rethrow(me);
    end
    restoreFolders(oldFolder,oldPathVal);
end

function[logStr,status,iterCtrl,set,log]=...
    iterProcess(...
    iterCtrl,model,chip,...
    iterLimit,explorationMode,archMode,doSynthesis,guidanceFile,lastGuidanceFile,cpAnnotationFile,...
    oldFolder,projFolder,explFolder,currFolder,codeFolder,...
    log)%#ok<INUSL>



    status=true;
    constraintUpdated=false;
    set=struct('cp',{},'ctxName',{});
    logStr='';

    if(exist(fullfile('.',guidanceFile),'file')==2)
        guidance=qoroptimizations.loadFile(guidanceFile);
        iterCtrl.optimalLatency=max(iterCtrl.optimalLatency,guidance.guidance.optimalLatency);
        iterCtrl.maxFailedLatency=max(iterCtrl.maxFailedLatency,iterCtrl.optimalLatency);
    end

    if(explorationMode==hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency&&iterCtrl.cplatency<=iterCtrl.constraint)

        logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterSuccess',sprintf('%.2f',iterCtrl.constraint),sprintf('%.2f',iterCtrl.cplatency)).getString);
        return;
    end

    if(iterCtrl.minAchievedLatency<iterCtrl.maxFailedLatency)
        logStr=printLog(logStr,2,archMode,'Exiting because minAchievedLatency (%.2f ns) is less than maxFailedLatency (%.2f ns) or optimalLatency (%.2f ns) so that the algorithm will not safely converge.\n',iterCtrl.minAchievedLatency,iterCtrl.maxFailedLatency,iterCtrl.optimalLatency);

        logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterBestAchieved').getString);
        return;
    end

    if(iterCtrl.minAchievedLatency-iterCtrl.maxFailedLatency<0.1)
        logStr=printLog(logStr,2,archMode,'Exiting because minAchievedLatency (%.2f ns) is equal to maxFailedLatency (%.2f ns) or optimalLatency (%.2f ns).\n',iterCtrl.minAchievedLatency,iterCtrl.maxFailedLatency,iterCtrl.optimalLatency);
        logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterBestAchieved').getString);
        return;
    end

    if(iterCtrl.iter>=iterLimit)

        logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterLimitReached',sprintf('%d',iterLimit)).getString);
        return;
    end


    if(iterCtrl.guidedCPEmpty)
        return;
    end


    if(iterCtrl.constraint<iterCtrl.optimalLatency)
        if(explorationMode==hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency)
            logStr=printLog(logStr,2,archMode,'Exiting because constraint (%.2f ns) moves out of bound.\n',iterCtrl.constraint);
            logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterBestAchieved').getString);
            return;
        else
            logStr=printLog(logStr,2,archMode,'Updating constraint, because optimalLatency (%.2f ns) becomes less than constraint (%.2f ns).\n',iterCtrl.constraint,iterCtrl.optimalLatency);
            iterCtrl.maxFailedLatency=max(iterCtrl.constraint,iterCtrl.maxFailedLatency);
            [logStr,constraintUpdated,iterCtrl.constraint]=updateConstraint(logStr,archMode,iterCtrl.minAchievedLatency,iterCtrl.maxFailedLatency,iterCtrl.optimalLatency,iterCtrl.constraint);
            if(~constraintUpdated)
                logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterBestAchieved').getString);
                return;
            end
        end
    end

    if((iterCtrl.cplatency<=iterCtrl.constraint)&&~constraintUpdated)
        assert(explorationMode~=hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency)
        logStr=printLog(logStr,2,archMode,'Update constraint, because the current constraint (%.2f ns) has been met (%.2f ns).  Update constraint with optimal latency (%.2f ns), as the latter is smaller.\n',iterCtrl.constraint,iterCtrl.cplatency,iterCtrl.optimalLatency);
        [logStr,constraintUpdated,iterCtrl.constraint]=updateConstraint(logStr,archMode,iterCtrl.minAchievedLatency,iterCtrl.maxFailedLatency,iterCtrl.optimalLatency,iterCtrl.constraint);
        if(~constraintUpdated)
            return;
        end
    end

    if((iterCtrl.cplatency>iterCtrl.last_cplatency)&&~constraintUpdated)
        if(explorationMode==hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency)

            logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterFailure',sprintf('%.2f',iterCtrl.constraint)).getString);
            return;
        else
            logStr=printLog(logStr,2,archMode,'Update constraint, because cplatency increased from %.2f ns to %.2f ns.\n',iterCtrl.last_cplatency,iterCtrl.cplatency);
            iterCtrl.maxFailedLatency=max(iterCtrl.constraint,iterCtrl.maxFailedLatency);
            [logStr,constraintUpdated,iterCtrl.constraint]=updateConstraint(logStr,archMode,iterCtrl.minAchievedLatency,iterCtrl.maxFailedLatency,iterCtrl.optimalLatency,iterCtrl.constraint);
            if(~constraintUpdated)
                logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterBestAchieved').getString);
                return;
            end
        end
    end


    if(~constraintUpdated&&exist(fullfile('.',lastGuidanceFile),'file')==2)
        lastGuidance=qoroptimizations.loadFile(lastGuidanceFile);
        if((isempty(guidance.guidance.guidanceSet)&&isempty(lastGuidance.guidance.guidanceSet))...
            ||isequal(guidance.guidance.guidanceSet,lastGuidance.guidance.guidanceSet))
            if(explorationMode==hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency)
                logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterFailure',sprintf('%.2f',iterCtrl.constraint)).getString);
                return;
            else
                logStr=printLog(logStr,2,archMode,'Update constraint, because no new guidance can be applied.\n');
                iterCtrl.maxFailedLatency=max(iterCtrl.constraint,iterCtrl.maxFailedLatency);
                [logStr,constraintUpdated,iterCtrl.constraint]=updateConstraint(logStr,archMode,iterCtrl.minAchievedLatency,iterCtrl.maxFailedLatency,iterCtrl.optimalLatency,iterCtrl.constraint);
                if(~constraintUpdated)
                    logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitAfterBestAchieved').getString);
                    return;
                end
            end
        end
    end

    if doSynthesis
        try
            [~,cp_ir]=evalc('qoroptimizations.runthroughba(model, chip, iterCtrl.constraint, projFolder, codeFolder, guidanceFile, cpAnnotationFile)');
        catch me
            logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitForRunThruBAError',strrep(getReport(me),'\','\\')).getString);
            rethrow(me);
        end

        iterCtrl.last_cplatency=iterCtrl.cplatency;
        iterCtrl.cplatency=qoroptimizations.extractCPLatency(cp_ir);

        try
            [set,~]=qoroptimizations.backAnnotate(cp_ir,cpAnnotationFile);
        catch me
            logStr=printLog(logStr,1,archMode,message('hdlcoder:optimization:ExitForBAError',strrep(getReport(me),'/','//')).getString);
            rethrow(me);
        end
    else

        cmd=qoroptimizations.makehdlcmd(model,chip,codeFolder,iterCtrl.constraint,'',guidanceFile,cpAnnotationFile,'on','off','off','on');
        eval(cmd);


        load(fullfile(oldFolder,explFolder,currFolder,codeFolder,model,'hdlcodegenstatus.mat'),'CriticalPathDelay');
        iterCtrl.last_cplatency=iterCtrl.cplatency;
        iterCtrl.cplatency=CriticalPathDelay;


        load('cpAnnotation.mat','criticalPathSet')
        set=criticalPathSet;
    end

    if(iterCtrl.cplatency<iterCtrl.minAchievedLatency)
        iterCtrl.minAchievedLatency=iterCtrl.cplatency;
        iterCtrl.bestArchFolder='this';
    end


    if(iterCtrl.maxFailedLatency>=iterCtrl.cplatency)
        iterCtrl.maxFailedLatency=iterCtrl.optimalLatency;
    end

    if(isempty([set.cp]))
        iterCtrl.guidedCPEmpty=true;
    else
        iterCtrl.guidedCPEmpty=false;
        iterCtrl.optimalLatency=max(iterCtrl.optimalLatency,qoroptimizations.getOptimalLatency(set));
        iterCtrl.maxFailedLatency=max(iterCtrl.maxFailedLatency,iterCtrl.optimalLatency);
        if(iterCtrl.maxFailedLatency>iterCtrl.constraint&&explorationMode~=hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency)
            logStr=printLog(logStr,2,archMode,'Constraint (%.2f ns) is updated with optimal latency (%.2f ns), as the latter is greater.\n',iterCtrl.constraint,iterCtrl.maxFailedLatency);
            iterCtrl.constraint=iterCtrl.maxFailedLatency;
        end
    end

    status=false;
end

function logItem=assemblelog(iterCtrl,cuts,p,elapsedTime,commandLog)
    if(nargin==0)
        logItem=struct('iterCtrl',{},...
        'cuts',{},...
        'portExtraLatency',{},...
        'flipflops',{},...
        'elapsedTime',{},...
        'commandLog',{}...
        );
        return;
    end

    hN=p.getTopNetwork;
    outs=hN.NumberOfPirOutputPorts;
    lat=zeros(outs,1);
    for ii=1:outs
        lat(ii)=p.getDutExtraLatency(ii-1);
    end
    logItem.iterCtrl=iterCtrl;
    logItem.cuts=cuts;
    logItem.portExtraLatency=lat;
    logItem.flipflops=countRegister(p);
    logItem.elapsedTime=elapsedTime;
    logItem.commandLog=commandLog;
end

function regCount=countRegister(p)
    regCount=-1;
    ch=hdlcoder.characterization.create;
    ch.doit(p);
    networks=p.Networks;
    hdrv=hdlmodeldriver(p.modelName);
    rcreport=strcmpi(hdrv.getCLI.resourcereport,'on');

    for i=1:length(networks)
        if(networks(i).SimulinkHandle~=-1)
            if(rcreport)
                b=ch.getBillOfMaterials(networks(i));
                regCount=b.getTotalFlipflops;
            end
        end
    end
end

function[logStr,updated,constraint]=updateConstraint(logStr,archMode,minAchievedLatency,maxFailedLatency,optimalLatency,oldConstraint)
    upperBound=minAchievedLatency;
    lowerBound=max(maxFailedLatency,optimalLatency);
    constraint=(upperBound+lowerBound)/2;
    updated=(constraint~=oldConstraint);
    if(~updated)
        logStr=printLog(logStr,2,archMode,'constraint (%.2f ns) does not change anymore.\n',constraint);
    end
end

function restoreFolders(oldFolder,oldPathVal)
    cd(oldFolder);
    path(oldPathVal);
end

function prepareWorkingFolders(explFolder,currFolder)





    explFolder=strrep(explFolder,'/',filesep);
    explFolder=strrep(explFolder,'\',filesep);
    currFolder=strrep(currFolder,'/',filesep);
    currFolder=strrep(currFolder,'\',filesep);
    if(exist(fullfile('.',explFolder),'dir')~=7)
        s=mkdir('.',explFolder);
        if(~s)
            error(message('hdlcoder:optimization:CannotCreateDir',explFolder));
        end
    end

    currFolder=fullfile(explFolder,currFolder);
    if(exist(fullfile('.',currFolder),'dir')==7)
        s=rmdir(currFolder,'s');
        if(~s)
            warning(message('hdlcoder:optimization:CannotCreateDir',currFolder));
        else
            s=mkdir('.',currFolder);
            if(~s)
                error(message('hdlcoder:optimization:CannotCreateDir',currFolder));
            end
        end
    else
        s=mkdir('.',currFolder);
        if(~s)
            error(message('hdlcoder:optimization:CannotCreateDir',currFolder));
        end
    end

    addpath(pwd);
    cd(currFolder);
end

function finalCodeGen(model,chip,latencyConstraint,codeFolder,annotationFile,guidanceFile,guidanceFileFolder,regen)


    items=dir('.');
    for i=3:length(items)
        if(items(i).isdir)
            s=rmdir(items(i).name,'s');
        else
            delete(items(i).name);
        end
    end


    filesToCopy={guidanceFile,annotationFile};
    for i=1:length(filesToCopy)
        srcFile=fullfile(guidanceFileFolder,filesToCopy{i});
        if(exist(srcFile,'file')==2)
            s=copyfile(srcFile,'.');
            if(~s)
                error(message('hdlcoder:optimization:CannotCopyFile',srcFile));
            end
        end
    end

    if(~regen)
        userAnnotationFile=annotationFile;
    else
        userAnnotationFile='';
    end

    cmd=qoroptimizations.makehdlcmd(model,chip,codeFolder,latencyConstraint,guidanceFile,guidanceFile,userAnnotationFile,'off',hdlget_param(model,'GenerateModel'),hdlget_param(model,'GenerateHDLCode'),hdlget_param(model,'CriticalPathEstimation'));
    evalc(cmd);

    hDriver=hdlmodeldriver(model);
    callMakehdlTB=hDriver.getParameter('GenerateHDLTestBench')||hDriver.getParameter('GenerateCoSimBlock')||~strcmpi(hDriver.getParameter('GenerateCoSimModel'),'None');
    if(callMakehdlTB)
        cmd=qoroptimizations.makehdltbcmd(model,chip,codeFolder);
        evalc(cmd);
    end
end

function resultMsg=sanityCheckForOptimize(model,chip,optimConfig,projFolder,doSynthesis)
    resultMsg='';
    resultMsg=optimConfig.sanitycheck(resultMsg);
    hdlparams=hdlsaveparams([model,'/',chip]);
    dpOnObjs='';
    cpOnObjs='';
    ssOnObjs='';
    for i=1:length(hdlparams)
        if(strcmpi(hdlparams(i).parameter,'DistributedPipelining')&&...
            strcmpi(hdlparams(i).value,'on'))
            dpOnObjs=sprintf('%s\n%s',dpOnObjs,hdlparams(i).object);
        end
        if(strcmpi(hdlparams(i).parameter,'ConstrainedOutputPipeline')&&...
            hdlparams(i).value>0)
            cpOnObjs=sprintf('%s\n%s',cpOnObjs,hdlparams(i).object);
        end
        if(((strcmpi(hdlparams(i).parameter,'SharingFactor')&&hdlparams(i).value>0)||...
            (strcmpi(hdlparams(i).parameter,'StreamingFactor')&&hdlparams(i).value>0))&&...
            hdlget_param(model,'MaxOversampling')==1)
            ssOnObjs=sprintf('%s\n%s',ssOnObjs,hdlparams(i).object);
        end
        if(strcmpi(hdlparams(i).parameter,'ClockInputs')&&(~strcmpi(hdlparams(i).value,'Single')))
            error(message('hdlcoder:optimization:MultipleClocks'));
        end
        if(strcmpi(hdlparams(i).parameter,'Architecture')&&(strcmpi(hdlparams(i).value,'BlackBox')))
            error(message('hdlcoder:optimization:BlackBox',hdlparams(i).object));
        end
    end



    mdlref=find_system([model,'/',chip],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference');
    if(~isempty(mdlref))
        mdlrefpaths=mdlref{1};
        for i=2:length(mdlref)
            mdlrefpaths=sprintf('%s\n%s',mdlrefpath,mdlref{i});
        end
        error(message('hdlcoder:optimization:ModelReference',mdlrefpaths));
    end

    if(~isempty(dpOnObjs))
        dpOnObjs=dpOnObjs(2:end);

        resultMsg=sprintf('%s\n%s\n%s\n',resultMsg,message('hdlcoder:optimization:WarningForDP').getString,char(dpOnObjs));
    end
    if(~isempty(cpOnObjs))
        cpOnObjs=cpOnObjs(2:end);

        resultMsg=sprintf('%s\n%s\n%s\n',resultMsg,message('hdlcoder:optimization:WarningForCP').getString,char(cpOnObjs));
    end
    if(~isempty(ssOnObjs))
        ssOnObjs=ssOnObjs(2:end);

        resultMsg=sprintf('%s\n%s\n%s\n',resultMsg,message('hdlcoder:optimization:WarningForSS').getString,char(ssOnObjs));
    end
    if(~isempty(resultMsg))


        warning(message('hdlcoder:optimization:WarningAboutNonOptimal',resultMsg));
    end

    if doSynthesis
        qoroptimizations.setupDI(model,projFolder);
    end
end

function logStr=printLog(logStr,level,archMode,varargin)

    if(level<=1||archMode==hdlcoder.OptimizationConfig.Archive.Verbose)
        msg=sprintf(varargin{:});
        logStr=sprintf('%s%s',logStr,msg);
        printfToScreen(1,'%s',msg);
    end
end

function printfToScreen(fid,varargin)
    fprintf(fid,varargin{:});
end

function offendingBlocksMessage=checkCriticalPathEstimationOffendingBlocks(explFolder,currFolder,codeFolder,model)
    offendingBlocksMessage='';
    p=pir;
    if p.getContainsCriticalPathOffendingBlocks
        filename=fullfile(explFolder,currFolder,codeFolder,model,'highlightCriticalPathEstimationOffendingBlocks');
        offendingBlocksMessage=sprintf('%s <a href="matlab:run(''%s'')">%s.m</a>',message('hdlcoder:hdldisp:GeneratingBlocksWithNoCharacterizationHighlightScript').getString,filename,filename);
    end
end



