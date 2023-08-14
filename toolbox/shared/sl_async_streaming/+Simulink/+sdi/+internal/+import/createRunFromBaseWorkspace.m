function[runID,runIdx,sigs]=createRunFromBaseWorkspace(runName,varNames,varargin)


    varValues=locGetWksValues(varNames);
    [runID,runIdx,sigs]=Simulink.sdi.internal.import.createRunFromNamesAndValues(...
    runName,...
    varNames,...
    varValues,...
    varargin{:});
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
