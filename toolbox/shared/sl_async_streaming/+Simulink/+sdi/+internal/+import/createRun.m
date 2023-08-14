function[runID,runIdx,sigIDs]=createRun(inputNames,varargin)





    repo=sdi.Repository(1);
    numArgs=numel(varargin);
    priorRunCnt=repo.getRunCount();


    runName=' ';
    if~isempty(varargin)
        runName=varargin{1};
    end
    validateattributes(runName,{'char','string'},{},1);


    if numArgs<2
        runID=repo.createEmptyRun(runName,0);
        runIdx=repo.getRunCount();
        sigIDs=int32.empty();
        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        fw.onRunsCreated(runID,true,'sdi',runName);
        return
    end


    validateattributes(varargin{2},{'char','string'},{},2);
    callType=lower(varargin{2});


    switch callType
    case 'base'
        narginchk(4,4);
        validateattributes(varargin{3},{'cell'},{'nonempty'},3);
        [runID,runIdx,sigIDs]=Simulink.sdi.internal.import.createRunFromBaseWorkspace(...
        runName,varargin{3});
    case 'model'
        narginchk(4,4);
        mdl=varargin{3};
        validateattributes(mdl,{'char','string'},{},3);
        [runID,runIdx,sigIDs]=Simulink.sdi.internal.import.createRunFromModel(mdl);
    case 'file'
        narginchk(4,inf);
        fileName=varargin{3};
        validateattributes(fileName,{'char','string'},{},3);
        cmdLine=true;
        runID=0;
        importer=Simulink.sdi.internal.import.FileImporter.getDefault();
        [runID,sigIDs]=importer.verifyFileAndImport(...
        repo,fileName,runName,cmdLine,runID,varargin{4:end});
        numRuns=numel(runID);
        totalRuns=repo.getRunCount();
        runIdx=(totalRuns-numRuns+1:totalRuns);
    case 'vars'
        narginchk(4,inf);
        varNames=locGetVarNamesFromInputNames(inputNames(3:end));
        varValues=varargin(3:end);
        [runID,runIdx,sigIDs]=Simulink.sdi.internal.import.createRunFromNamesAndValues(...
        runName,varNames,varValues);
    case 'namevalue'
        narginchk(5,5);
        validateattributes(varargin{3},{'cell'},{'nonempty'},3);
        validateattributes(varargin{4},{'cell'},{'nonempty'},4);
        [runID,runIdx,sigIDs]=Simulink.sdi.internal.import.createRunFromNamesAndValues(...
        runName,varargin{3},varargin{4});
    otherwise
        error(message('SDI:sdi:invalidInput'));
    end


    newRunCount=repo.getRunCount();
    if isempty(runID)&&priorRunCnt==newRunCount
        switch callType
        case 'model'
            msg=message('SDI:sdi:invalidModel');
        otherwise
            msg=message('SDI:sdi:notValidBaseWorkspaceVar');
        end
        Simulink.sdi.internal.warning(msg);
    end
end


function varNames=locGetVarNamesFromInputNames(varNames)


    numVar=numel(varNames);
    for idx=1:numVar
        if isempty(varNames{idx})
            if numVar>1
                varNames{idx}=sprintf('<%d>',idx);
            else
                varNames{idx}=' ';
            end
        end
    end
end
