function diag=getDiagnositics(mdl,SortedPD,ruleSet)

    diag=[];

    isfixed=strcmp(get_param(mdl,'SolverType'),'Fixed-step');
    isode14x=strcmp(get_param(bdroot,'CompiledSolverName'),'ode14x');

    tout=SortedPD.getData('Tout');
    failureInfo=SortedPD.getData('FailureInfo');


    metaData=SortedPD.getData('MetaData');
    if strcmp(metaData.ExecutionInfo.StopEvent,'DiagnosticError')
        tLeft=getTimeRegionToInvestigate(tout);
        numOfSteps=length(find(tout>tLeft));
        diag=ruleAvgException(SortedPD,tLeft,numOfSteps,isErrorOut,diag,ruleSet);
        diag=ruleAvgZC(SortedPD,tLeft,numOfSteps,diag,ruleSet);
        if~isode14x
            diag=ruleAvgReset(SortedPD,tLeft,numOfSteps,diag,ruleSet);
        end
    end


    diag=ruleDAE(failureInfo,diag,ruleSet);

    if~isode14x

        diag=ruleDenseSolverReset(SortedPD,tout,diag,ruleSet);
    end


    diag=ruleDenseSolverException(SortedPD,tout,diag,ruleSet);


    diag=ruleDenseZC(SortedPD,tout,diag,ruleSet);

    if~isfixed

        diag=ruleHmax(SortedPD,mdl,diag,ruleSet);
    end




    if~isfixed
        diag=ruleDecoupleIntegZC(SortedPD,diag,mdl,ruleSet);

        diag=ruleAdaptiveSolver(SortedPD,diag,mdl,ruleSet);
    end


    diag=ruleCustom(SortedPD,diag,ruleSet);



    if isempty(diag)
        diag{1}=DAGetString('nothing');
    end

end

function diag=ruleAvgException(SortedPD,tLeft,numOfSteps,isErrorOut,diag,ruleSet)

    useThisRule=ruleSet(1).enabled;
    try
        threshold=eval(ruleSet(1).value)/100;
    catch
        return;
    end

    if~useThisRule
        return;
    end

    diagCopy=diag;
    try

        allExceptionMatrix=SortedPD.getTotalFailureMatrix(0);
        if~isempty(allExceptionMatrix)
            allEventTime=unique(allExceptionMatrix(:,1));
            numException=length(find(allEventTime>tLeft));
            if(numException/numOfSteps)>threshold||isErrorOut
                diag{length(diag)+1}=colorRed(DAGetString('denseFailureAtEnd'));
                diag{length(diag)+1}=DAGetString('idFailureStates');
                diag{length(diag)+1}=['  1. ',DAGetString('denseFailureSuggestion1')];
                diag{length(diag)+1}=['  2. ',DAGetString('denseFailureSuggestion2')];
                diag{length(diag)+1}=['  3. ',DAGetString('denseFailureSuggestion3')];
                diag{length(diag)+1}=['  4. ',DAGetString('denseFailureSuggestion4')];
                diag{length(diag)+1}='';
            end
        end
    catch
        diag=diagCopy;
    end

end

function diag=ruleAvgZC(SortedPD,tLeft,numOfSteps,diag,ruleSet)

    useThisRule=ruleSet(2).enabled;
    try
        threshold=eval(ruleSet(2).value)/100;
    catch
        return;
    end

    if~useThisRule
        return;
    end

    diagCopy=diag;
    try

        allZCMatrix=SortedPD.getAllZCEvents();
        if~isempty(allZCMatrix)
            allEventTime=unique(allZCMatrix(:,1));
            numZC=length(find(allEventTime>tLeft));
            if numZC/numOfSteps>threshold
                diag{length(diag)+1}=colorRed(DAGetString('denseZCAtEnd'));
                diag{length(diag)+1}=DAGetString('idZCBlocks');
                diag{length(diag)+1}=['  1. ',DAGetString('denseZCSuggestion1')];
                diag{length(diag)+1}=['  2. ',DAGetString('denseZCSuggestion2')];
                diag{length(diag)+1}=['  3. ',DAGetString('denseZCSuggestion3')];
                diag{length(diag)+1}='';
            end
        end
    catch
        diag=diagCopy;
    end

end

function diag=ruleAvgReset(SortedPD,tLeft,numOfSteps,diag,ruleSet)

    useThisRule=ruleSet(3).enabled;
    try
        threshold=eval(ruleSet(3).value)/100;
    catch
        return;
    end

    if~useThisRule
        return;
    end

    diagCopy=diag;
    try

        allResetMatrix=SortedPD.getTotalResetMatrix(0);
        if~isempty(allResetMatrix)
            ResetTime=allResetMatrix(:,1);
            numReset=length(find(unique(ResetTime)>tLeft));
            if numReset/numOfSteps>threshold
                diag{length(diag)+1}=colorRed(DAGetString('denseResetAtEnd'));
                diag{length(diag)+1}=DAGetString('denseResetSuggestion');
                diag{length(diag)+1}='';
            end
        end
    catch
        diag=diagCopy;
    end

end

function diag=ruleDAE(failureInfo,diag,ruleSet)
    useThisRule=ruleSet(4).enabled;

    if~useThisRule
        return;
    end

    diagCopy=diag;
    try
        stateIdxList=failureInfo.getStateIdxListWithHmin();
        if~isempty(stateIdxList)
            diag{length(diag)+1}=colorRed(DAGetString('DAEHminFound'));
            diag{length(diag)+1}=DAGetString('exploreStatesDAEHmin');
            diag{length(diag)+1}=['  1. ',DAGetString('denseFailureSuggestion2')];
            diag{length(diag)+1}=['  2. ',DAGetString('denseFailureSuggestion3')];
            diag{length(diag)+1}=['  3. ',DAGetString('denseFailureSuggestion4')];
            diag{length(diag)+1}='';
        end
    catch
        diag=diagCopy;
    end

end

function diag=ruleDecoupleIntegZC(SortedPD,diag,mdl,ruleSet)

    diagCopy=diag;

    useThisRule=ruleSet(5).enabled;
    if~useThisRule
        return;
    end

    try




        origDecoupleCD=get_param(mdl,'DecoupledContinuousIntegration');
        compiledHmax=get_param(mdl,'ContMaxStepSize');
        DiscDriContblkList=SortedPD.ResetInfo.getDiscDriContblkList();
        numDiscDriCont=length(DiscDriContblkList);
        discDriContSampleTimes=zeros(1,numDiscDriCont);
        for i=1:numDiscDriCont
            discTs=get_param(DiscDriContblkList(i).block,'CompiledSampleTime');
            discDriContSampleTimes(i)=discTs(1);
        end

        sDiscTs=Inf;
        sampleTimes=get_param(mdl,'SampleTimes');
        for i=1:length(sampleTimes)
            if~isempty(sampleTimes(i).Value)&&isnumeric(sampleTimes(i).Value)
                discTs=sampleTimes(i).Value(1);
                if(discTs>0)&&(discTs<sDiscTs)&&~ismember(discTs,discDriContSampleTimes)
                    sDiscTs=discTs;
                end
            end
        end
        ratio=sDiscTs/compiledHmax;

        if(ratio<1&&strcmp(origDecoupleCD,'off'))


            if sDiscTs~=Inf
                diag{length(diag)+1}=colorGreen(...
                [DAGetString('DecoupleInfoHmax',num2str(compiledHmax)),' ',...
                DAGetString('DecoupleInfoSDiscTs',num2str(sDiscTs)),' ',...
                DAGetString('DecoupleInfoSlow')]);
            else
                diag{length(diag)+1}=colorGreen(...
                [DAGetString('DecoupleInfoHmax',num2str(compiledHmax)),' ',...
                DAGetString('DecoupleInfoNoDiscRate')]);
            end
            diag{length(diag)+1}=DAGetString('suggestTurnOnDecouple');
            diag{length(diag)+1}=DAGetString('DecoupleSuggestOn',mdl);
            diag{length(diag)+1}='';
        end


        origMinimalZC=get_param(mdl,'MinimalZcImpactIntegration');
        zcMatrix=SortedPD.getAllZCEvents();
        if~isempty(zcMatrix)
            numZC=length(unique(zcMatrix(:,1)));
        else
            numZC=0;
        end
        tout=SortedPD.getData('Tout');
        if(numZC/length(tout)>0.01&&strcmp(origMinimalZC,'off'))
            diag{length(diag)+1}=colorGreen(DAGetString('MinimalZcInfoSlow'));
            diag{length(diag)+1}=DAGetString('suggestTurnOnMinimalZc');
            diag{length(diag)+1}=DAGetString('MinimalZcSuggestOn',mdl);
            diag{length(diag)+1}='';
        end

    catch
        diag=diagCopy;
    end

end


function diag=ruleAdaptiveSolver(SortedPD,diag,mdl,~)


    diagCopy=diag;

    isAdatpiveSolverUiOn=(slfeature('AdaptiveSolverUI')>0);
    isVarStepAuto=strcmp(get_param(mdl,'solver'),'VariableStepAuto');

    if((~isAdatpiveSolverUiOn)||(~isVarStepAuto))
        return;
    end

    isAdaptiveSolverOn=strcmp(get_param(mdl,'EnableSolverSwitchingAtRunTime'),'on');
    isAdaptiveSolverAutoOn=strcmp(get_param(mdl,'EnableSolverSwitchingAuto'),'on');

    if(isAdaptiveSolverOn&&isAdaptiveSolverAutoOn)
        return;
    end

    try
        tout=SortedPD.getData('Tout');
        step=diff(tout);
        N=length(step);
        stepMax=-1;
        solverChange=false;

        for i=1:N
            currStep=step(i);
            if(currStep>stepMax)
                stepMax=currStep;
            else
                if(currStep<0.1*stepMax)
                    solverChange=true;
                    break;
                end
            end
        end

        if(solverChange)
            diag{length(diag)+1}=colorGreen(DAGetString('AdaptiveSolverStepSizeDrop'));
            diag{length(diag)+1}=DAGetString('AdaptiveSolverSuggestOn');
            diag{length(diag)+1}=DAGetString('AdaptiveSolverCommandOn',mdl);
        end

    catch
        diag=diagCopy;
    end

end


function diag=ruleDenseSolverReset(SortedPD,tout,diag,ruleSet)

    useThisRule=ruleSet(6).enabled;
    try
        threshold=eval(ruleSet(6).value)/100;
    catch
        return;
    end

    if~useThisRule
        return;
    end

    diagCopy=diag;
    try
        numReset=SortedPD.getTotalResetNum(0);
        zcMatrix=SortedPD.getAllZCEvents();
        if~isempty(zcMatrix)
            numZC=length(unique(zcMatrix(:,1)));
        else
            numZC=0;
        end



        if numReset/length(tout)>threshold&&numReset/numZC>1.5
            diag{length(diag)+1}=colorRed(DAGetString('denseReset'));
            diag{length(diag)+1}=DAGetString('denseResetSuggestion');
            diag{length(diag)+1}='';
        end
    catch
        diag=diagCopy;
    end

end

function diag=ruleDenseSolverException(SortedPD,tout,diag,ruleSet)
    import solverprofiler.util.*

    useThisRule=ruleSet(7).enabled;
    try
        threshold=eval(ruleSet(7).value);
    catch
        return;
    end

    if~useThisRule
        return;
    end

    diagCopy=diag;

    try

        exceptionMatrix=SortedPD.getTotalFailureMatrix(0);
        if~isempty(exceptionMatrix)
            exceptionTime=unique(exceptionMatrix(:,1));


            failDensityInfo=getEventDensityVec(tout,exceptionTime);
            sampleTime=failDensityInfo(:,1);
            failDensityVec=failDensityInfo(:,2);

            inds=find(failDensityVec>threshold);
            if~isempty(inds)

                dt=diff(sampleTime(inds));

                cuts=find(dt>1);

                failInds=sort([inds(1);inds(cuts);inds(cuts+1);inds(end)]);
                failureSpans=zeros(length(failInds)/2,2);
                for i=1:length(failInds)/2
                    failureSpans(i,1)=max(sampleTime(1),sampleTime(failInds(2*i-1))-0.5);
                    failureSpans(i,2)=min(sampleTime(end),sampleTime(failInds(2*i))+0.5);
                end
            else
                failureSpans=[];
            end
        else
            failureSpans=[];
        end


        if~isempty(failureSpans)
            diag{length(diag)+1}=colorYellow(DAGetString('denseFailure'));
            for i=1:length(failureSpans(:,1))
                tl=utilFormatToString(failureSpans(i,1));
                tr=utilFormatToString(failureSpans(i,2));
                diag{length(diag)+1}=DAGetString('FromTo',tl,tr);
            end
            diag{length(diag)+1}=['  1. ',DAGetString('denseFailureSuggestion5')];
            diag{length(diag)+1}=['  2. ',DAGetString('denseFailureSuggestion2')];
            diag{length(diag)+1}=['  3. ',DAGetString('denseFailureSuggestion3')];
            diag{length(diag)+1}=['  4. ',DAGetString('denseFailureSuggestion4')];
            diag{length(diag)+1}='';
        end

    catch
        diag=diagCopy;
    end

end

function diag=ruleDenseZC(SortedPD,tout,diag,ruleSet)
    import solverprofiler.util.*

    useThisRule=ruleSet(8).enabled;
    try
        threshold=eval(ruleSet(8).value);
    catch
        return;
    end

    if~useThisRule
        return;
    end

    diagCopy=diag;
    try
        zcMatrix=SortedPD.getAllZCEvents();
        if~isempty(zcMatrix)
            zcTime=unique(zcMatrix(:,1));

            zcDensityInfo=getEventDensityVec(tout,zcTime);
            sampleTime=zcDensityInfo(:,1);
            zcDensityVec=zcDensityInfo(:,2);


            inds=find(zcDensityVec>threshold);
            if~isempty(inds)

                dt=diff(sampleTime(inds));

                cuts=find(dt>1);

                zcInds=sort([inds(1);inds(cuts);inds(cuts+1);inds(end)]);

                zcSpans=zeros(length(zcInds)/2,2);
                for i=1:length(zcInds)/2
                    zcSpans(i,1)=max(sampleTime(1),sampleTime(zcInds(2*i-1))-0.5);
                    zcSpans(i,2)=min(sampleTime(end),sampleTime(zcInds(2*i))+0.5);
                end
            else
                zcSpans=[];
            end
        else
            zcSpans=[];
        end


        if~isempty(zcSpans)
            diag{length(diag)+1}=colorYellow(DAGetString('denseZC'));
            for i=1:length(zcSpans(:,1))
                tl=utilFormatToString(zcSpans(i,1));
                tr=utilFormatToString(zcSpans(i,2));
                diag{length(diag)+1}=...
                DAGetString('FromTo',tl,tr);
            end
            diag{length(diag)+1}=['  1. ',DAGetString('denseZCSuggestion4')];
            diag{length(diag)+1}=['  2. ',DAGetString('denseZCSuggestion2')];
            diag{length(diag)+1}=['  3. ',DAGetString('denseZCSuggestion3')];
            diag{length(diag)+1}='';
        end

    catch
        diag=diagCopy;
    end

end

function diag=ruleHmax(SortedPD,mdl,diag,ruleSet)
    import solverprofiler.util.*
    useThisRule=ruleSet(9).enabled;
    try
        threshold=eval(ruleSet(9).value);
    catch
        return;
    end

    if~useThisRule
        return;
    end


    diagCopy=diag;
    try

        hmax=utilGetScalarValue(get_param(mdl,'MaxStep'));
        if isnumeric(hmax)&&hmax>=SortedPD.getTStop()
            return;
        end
        hmaxRatio=SortedPD.getHmaxRatio();
        if(hmaxRatio>threshold)
            diag{length(diag)+1}=colorGreen(...
            [DAGetString('hmaxRatio',sprintf('%2.2f',hmaxRatio)),' ',...
            DAGetString('speedImprove')]);
            diag{length(diag)+1}=DAGetString('hmaxRatioSuggestion');
            diag{length(diag)+1}='';
        end
    catch
        diag=diagCopy;
    end



    diagCopy=diag;
    try

        [~,stateIdxList]=SortedPD.getInaccurateStateTableContent();
        if~isempty(stateIdxList)
            diag{length(diag)+1}=colorGreen(DAGetString('detectInaccurateStates'));
            diag{length(diag)+1}=DAGetString('inaccurateStatesSuggestion');
            diag{length(diag)+1}='';
        end
    catch
        diag=diagCopy;
    end

end

function diag=ruleCustom(SortedPD,diag,ruleSet)

    useThisRule=ruleSet(10).enabled;
    if~useThisRule
        return;
    end

    diagCopy=diag;
    oldPath=path;
    try
        fullPath=ruleSet(10).value;
        if isempty(fullPath)
            return;
        end
        os=computer;
        if strfind(os,'WIN')%#ok<STRIFCND>
            inds=strfind(fullPath,'\');
        else
            inds=strfind(fullPath,'/');
        end
        if~isempty(inds)
            folder=fullPath(1:inds(end));
            addpath(folder);
            fcnName=fullPath(inds(end)+1:end);
        else
            fcnName=fullPath;
        end

        pd=SortedPD.getSimplifiedPD();
        fcn=str2func(fcnName(1:end-2));
        customDiag=fcn(pd);

        path(oldPath);
        for i=1:length(customDiag)
            diag{length(diag)+1}=customDiag{i};
        end
    catch ME
        msgbox([DAGetString('customRuleFail'),'. ',ME.message],DAGetString('customRuleFail'));
        diag=diagCopy;

        path(oldPath);
        return;
    end

end

function tLeft=getTimeRegionToInvestigate(tout)
    tSpan=tout(end)-tout(1);
    tLeft=tout(end)-0.2*tSpan;

    if length(tout)>300&&tout(end-299)>tLeft
        tLeft=tout(end-299);
    end
end

function info=getEventDensityVec(t,et)




    et=unique(et);
    interval=(t(end)-t(1))/1000;
    sampleTimePoints=t(1):interval:t(end);
    vec=zeros(length(sampleTimePoints),1);

    for i=1:length(vec)
        tl=max(sampleTimePoints(i)-0.5,0);
        tr=min(sampleTimePoints(i)+0.5,sampleTimePoints(end));


        if tr-tl>=min((t(end)-t(1))/100,1)
            inds=find(et>tl&et<tr);
            vec(i)=round(length(inds)/(tr-tl));
        else
            vec(i)=0;
        end
    end

    info=[sampleTimePoints',vec];
end


function value=DAGetString(key,varargin)
    if nargin==3
        value=DAStudio.message(['Simulink:solverProfiler:',key],varargin{1},varargin{2});
    elseif nargin==2
        value=DAStudio.message(['Simulink:solverProfiler:',key],varargin{1});
    else
        value=DAStudio.message(['Simulink:solverProfiler:',key]);
    end
end

function text=colorRed(text)
    text=['<Font color="Red">',text,'</FONT>'];
end

function text=colorYellow(text)
    text=['<Font color="Orange">',text,'</FONT>'];
end

function text=colorGreen(text)
    text=['<Font color="Green">',text,'</FONT>'];
end

