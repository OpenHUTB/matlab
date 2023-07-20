function runIDs=addToRun(this,repo,runID,varParsers,mdlName,overwrittenRunID,addToparentID,varargin)
    if nargin>3
        if isstring(varParsers)
            varParsers=cellstr(varParsers);
        end
    end
    if nargin>4
        mdlName=convertStringsToChars(mdlName);
    end


    if isempty(repo)
        repo=sdi.Repository(1);
    elseif isscalar(repo)&&isprop(repo,'sigRepository')
        repo=repo.sigRepository;
    else
        validateattributes(repo,{'sdi.Repository'},{'scalar'});
    end
    validateattributes(runID,{'numeric'},{'scalar','integer','nonzero'});


    if nargin<5
        mdlName='';
    end
    if nargin<6
        overwrittenRunID=0;
    end
    if nargin<7
        addToparentID=int32.empty;
    end


    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    runIDs=runID;
    numSignalsBefore=repo.getSignalCount(runID);
    if~isempty(varParsers)
        fw.beginCancellableOperation();
        tmp=onCleanup(@()fw.endCancellableOperation());
        runIDs=Simulink.sdi.internal.safeTransaction(...
        @locAddToRun,this,repo,runID,varParsers,mdlName,overwrittenRunID,addToparentID,varargin{:});
    end
    numSignalsAfter=repo.getSignalCount(runID);


    if numSignalsBefore~=numSignalsAfter||length(runIDs)>1
        fw.onAddedToRun(runIDs);
    end
end

function runIDs=locAddToRun(this,repo,runID,varParsers,mdlName,overwrittenRunID,addToparentID,varargin)





    flattenRuns=~isempty(mdlName);
    if~flattenRuns
        p=inputParser;
        p.KeepUnmatched=true;
        p.addOptional('OneRun',false,@mustBeNumericOrLogical);
        p.parse(varargin{:});
        params=p.Results;
        if params.OneRun

            flattenRuns=true;
        end
    end
    runIDs=addToRunImpl(this,repo,runID,varParsers,flattenRuns,mdlName,overwrittenRunID,addToparentID);
end
