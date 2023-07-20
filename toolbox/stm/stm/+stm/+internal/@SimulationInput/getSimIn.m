function simIn=getSimIn(varargin)

    modelName='';
    harnessOwner='';
    harnessName='';
    useParallel=false;
    mainModel='';
    tcID=-1;
    tcr='';
    p=inputParser;
    p.addParameter('ModelName',modelName);
    p.addParameter('HarnessOwner',harnessOwner);
    p.addParameter('HarnessName',harnessName);
    p.addParameter('TestCaseID',tcID);
    p.addParameter('TestResultsObj',tcr);
    p.addParameter('UseParallel',useParallel);
    p.addParameter('MainModel',mainModel);
    p.parse(varargin{:});
    modelName=p.Results.ModelName;
    harnessOwner=p.Results.HarnessOwner;
    harnessName=p.Results.HarnessName;
    useParallel=p.Results.UseParallel;
    mainModel=p.Results.MainModel;
    tcID=p.Results.TestCaseID;
    tcr=p.Results.TestResultsObj;

    if~isempty(harnessOwner)&&~isempty(harnessName)
        keepHarnessOpen=~useParallel;
        usingTestManager=true;
        simIn=sltest.harness.SimulationInput(harnessOwner,harnessName,keepHarnessOpen,usingTestManager,mainModel);
    else
        simIn=Simulink.SimulationInput(modelName);
    end
    if tcID>0&&~isempty(tcr)
        simIn.PreSimFcn=@(simIn)simInSchedule(tcID,tcr);
    end
end

function simInSchedule(tcID,tcr)
    path=getHierarchyPath(tcr);
    workerIdx=int32(1);
    stm.internal.parsimScheduler('Schedule',...
    {{tcr.getID,path,tcID,-1,tcr.ResultUUID}},workerIdx);
end

function path=getHierarchyPath(resultObject)
    ids=stm.internal.SimulationInput.getIdsFromResultObject(resultObject);
    path="@"+string(ids).join('@')+"@";
    path=path.char;
end