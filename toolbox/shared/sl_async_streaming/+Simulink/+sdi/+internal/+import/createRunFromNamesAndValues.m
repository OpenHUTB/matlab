function[runID,runIdx,sigIDs]=createRunFromNamesAndValues(runName,varNames,varValues,varargin)


    if~ischar('char')
        error(message('SDI:sdi:ValidateString'));
    end


    res=cellfun(@isempty,varNames);
    for idx=1:numel(res)
        if res(idx)&&idx<=numel(varValues)&&isobject(varValues{idx})&&isprop(varValues{idx},'Name')
            varNames{idx}=varValues{idx}.Name;
        end
    end
    res=cellfun(@isempty,varNames);
    if any(res==true)
        error(message('SDI:sdi:EmptyVarNames'));
    end


    repo=sdi.Repository(1);
    ret=Simulink.sdi.internal.safeTransaction(...
    @locCreateRun,repo,runName,varNames,varValues,varargin{:});
    runID=ret{1};
    sigIDs=ret{2};


    mdlName='';
    sigCount=repo.getSignalCount(runID(1));
    if~sigCount
        repo.removeRun(runID(1));
        repo.decrementRunNumbers(runID(2:end));
        runID(1)=[];
    elseif~isempty(varargin)
        mdlName=varargin{1};
    end


    endRunIdx=repo.getRunCount();
    startRunIdx=endRunIdx-length(runID)+1;
    runIdx=(startRunIdx:endRunIdx)';


    fireNotification=isempty(mdlName);
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.onRunsCreated(runID,fireNotification,'sdi',runName);



    if~isempty(mdlName)&&~isempty(runID)
        repo.setRunModel(runID,mdlName);
    end

end


function ret=locCreateRun(repo,runName,varNames,varValues,varargin)
    runID=repo.createEmptyRun(runName,0);
    [sigIDs,runIDs]=Simulink.sdi.internal.import.addToRunFromNamesAndValues(...
    runID,...
    varNames,...
    varValues,...
    varargin{:});
    ret{1}=runIDs;
    ret{2}=sigIDs;




    if length(runID)==1&&length(varValues)==1
        repo.setRunWksVarChecksum(runID,varValues{1});
    end
end
