function sigIDs=addToRun(inputNames,varargin)




    narginchk(4,inf);
    repo=sdi.Repository(1);


    runID=varargin{1};
    if isscalar(runID)&&isa(runID,'Simulink.sdi.Run')
        runID=runID.id;
    end
    if~isscalar(runID)||~isnumeric(runID)||~repo.isValidRunID(runID)
        error(message('SDI:sdi:InvalidRunID'));
    end


    validateattributes(varargin{2},{'char','string'},{},2);
    callType=lower(varargin{2});


    switch callType
    case 'base'
        narginchk(4,4);
        validateattributes(varargin{3},{'cell'},{'nonempty'},3);
        sigIDs=locAddToRunFromBaseWorkspace(runID,varargin{3});
    case 'model'
        narginchk(4,4);
        mdl=varargin{3};
        validateattributes(mdl,{'char','string'},{},3);
        sigIDs=locAddToRunFromModel(runID,mdl);
    case 'file'
        narginchk(4,inf);
        fileName=varargin{3};
        validateattributes(fileName,{'char','string'},{},3);
        cmdLine=true;
        runName='';
        importer=Simulink.sdi.internal.import.FileImporter.getDefault();
        [~,sigIDs]=importer.verifyFileAndImport(...
        repo,fileName,runName,cmdLine,runID,varargin{4:end});
    case 'vars'
        narginchk(4,inf);
        varNames=locGetVarNamesFromInputNames(inputNames(3:end));
        varValues=varargin(3:end);
        sigIDs=Simulink.sdi.internal.import.addToRunFromNamesAndValues(...
        runID,varNames,varValues);
    case 'namevalue'
        narginchk(5,5);
        validateattributes(varargin{3},{'cell'},{'nonempty'},3);
        validateattributes(varargin{4},{'cell'},{'nonempty'},4);
        sigIDs=Simulink.sdi.internal.import.addToRunFromNamesAndValues(...
        runID,varargin{3},varargin{4});
    otherwise
        error(message('SDI:sdi:invalidInput'));
    end


    if isempty(sigIDs)
        switch callType
        case 'model'
            msg=message('SDI:sdi:invalidModel');
        otherwise
            msg=message('SDI:sdi:notValidBaseWorkspaceVar');
        end
        Simulink.sdi.internal.warning(msg);
    else

        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        fw.onSignalAdded(runID);
    end
end


function sigIDs=locAddToRunFromBaseWorkspace(runID,varNames)
    varValues=locGetWksValues(varNames);
    sigIDs=Simulink.sdi.internal.import.addToRunFromNamesAndValues(...
    runID,varNames,varValues);
end


function sigIDs=locAddToRunFromModel(runID,mdl)
    interface=Simulink.sdi.internal.Framework.getFramework();
    varNames=interface.getLogVarNamesFromModel(mdl);
    sigIDs=locAddToRunFromBaseWorkspace(runID,varNames);
end


function varValues=locGetWksValues(varNames)
    varCount=numel(varNames);
    varValues=cell(1,varCount);
    for idx=1:varCount
        if~isstruct(varNames{idx})
            varName=varNames{idx};
        elseif isfield(varNames{idx},'VarName')
            varName=varNames{idx}.VarName;
        else
            continue
        end

        try
            varValues{idx}=evalin('base',varName);
        catch me %#ok
            varValues{idx}=[];
        end
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
