function tuneModel(cbinfo)




    topModel=cbinfo.model.Name;

    myStage=sldiagviewer.createStage(getString(message('dataflow:Spreadsheet:ProfilingStageName')),'ModelName',topModel);

    if~locCheckInfStopTime(topModel)
        return
    end


    [allMdls,modelBlocks]=multicoredesigner.internal.MappingData.updateDataModelHierarchy(get_param(topModel,'Handle'));


    confError=false;
    for i=1:length(allMdls)
        if~locCheckERTTarget(allMdls{i})
            confError=true;
        end
    end
    if confError
        return
    end


    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    silPilMode=appContext.ProfilingMode;



    tempSettings={{'MulticoreDesignerAction','ProfileCost'},...
    {'SimulationMode','Normal'},...
    {'CodeProfilingInstrumentation','detailed'},...
    {'CodeExecutionProfiling','on'},...
    {'TargetOS','BareBoardExample'},...
    {'ConcurrentTasks','off'},...
    {'GenerateReport','off'},...
    {'ReturnWorkspaceOutputs','on'},...
    {'SILPILSystemUnderTest','topmodel'},...
    {'EnableMultiTasking','on'}};
    if strcmp(silPilMode,'software')
        tempSettings{end+1}={'SimulationMode','Software-in-the-Loop (SIL)'};
    else
        tempSettings{end+1}={'SimulationMode','Processor-in-the-Loop (PIL)'};
    end

    orig=setParamTemp(topModel,tempSettings);
    restoreSettings=onCleanup(@()recoverParam(topModel,orig));

    varName=get_param(topModel,'ReturnWorkspaceOutputsName');
    restoreSettings(end+1)=onCleanup(@()evalin('base',['clear ',varName]));


    for i=1:length(modelBlocks)
        refmodel=allMdls{i};
        tempSettings={{'MulticoreDesignerAction','ProfileCost'},...
        {'TargetOS','BareBoardExample'},...
        {'ConcurrentTasks','off'},...
        {'EnableMultiTasking','on'}};
        orig=setParamTemp(refmodel,tempSettings);
        restoreSettings(end+1)=onCleanup(@()recoverParam(refmodel,orig));


        orig=setParamTemp(modelBlocks{i},{{'SimulationMode','Normal'}});
        restoreSettings(end+1)=onCleanup(@()recoverParam(modelBlocks{i},orig));
    end


    SLM3I.SLCommonDomain.simulationStartPauseContinue(cbinfo);
end

function ret=locCheckInfStopTime(model)
    ret=true;
    stopTimeStr=get_param(model,'StopTime');
    try
        stopTime=evalin('base',stopTimeStr);
    catch
        try
            hws=get_param(model,'modelworkspace');
            stopTime=hws.evalin(stopTimeStr);
        catch
            stopTime=1;
        end
    end
    if isinf(stopTime)
        diag=MSLException([],message('dataflow:MultithreadingAnalysis:InfProfileError'));
        sldiagviewer.reportError(diag);
        ret=false;
    end
end

function ret=locCheckERTTarget(model)
    ret=true;
    if strcmp(get_param(model,'IsERTTarget'),'off')
        diag=MSLException([],message('dataflow:Toolstrip:TargetNotERTError',model));
        sldiagviewer.reportError(diag);
        ret=false;
    end
end


function org=setParamTemp(system,params)
    org=[];
    for i=1:length(params)
        p=params{i};
        org{end+1}={p{1},get_param(system,p{1})};
        set_param(system,p{1},p{2});
    end
end

function recoverParam(system,params)
    for i=1:length(params)
        p=params{i};
        set_param(system,p{1},p{2});
    end
end



