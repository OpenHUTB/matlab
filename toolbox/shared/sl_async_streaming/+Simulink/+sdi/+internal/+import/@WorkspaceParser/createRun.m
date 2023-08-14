function runIDs=createRun(this,repo,varParsers,runName,mdlName,appName,notifyFlag)



    if nargin>2
        if isstring(varParsers)
            varParsers=cellstr(varParsers);
        end
    end
    if nargin>3
        runName=convertStringsToChars(runName);
    end


    if isempty(repo)
        repo=sdi.Repository(1);
    elseif isscalar(repo)&&isprop(repo,'sigRepository')
        repo=repo.sigRepository;
    else
        validateattributes(repo,{'sdi.Repository'},{'scalar'});
    end

    if nargin<4
        runName=repo.getRunNameTemplate();
    else
        validateattributes(runName,{'char'},{});
    end
    if nargin<5
        mdlName='';
    end
    if nargin<6
        appName='';
    end
    if nargin<7
        notifyFlag=true;
    end


    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    runIDs=int32.empty;
    if~isempty(varParsers)
        if isempty(this.ProgressTracker)
            if~isempty(appName)
                message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName',appName));
                tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName)));
            end
            fw.beginCancellableOperation();
            tmp2=onCleanup(@()fw.endCancellableOperation());
        end
        runIDs=Simulink.sdi.internal.safeTransaction(...
        @locCreateRun,this,repo,varParsers,runName,mdlName,appName);
    end


    fw.onRunsCreated(runIDs,notifyFlag,appName,runName);
end


function runIDs=locCreateRun(this,repo,varParsers,runName,mdlName,appName)

    compositeComplex=false;
    if strcmp(appName,'sdi')||strcmp(appName,'signallabeler')||strcmp(appName,'siganalyzer')
        compositeComplex=true;
    end
    runID=repo.createEmptyRun(runName,0,appName,compositeComplex);


    runIDs=addToRunImpl(this,repo,runID,varParsers,false,mdlName);


    sigCount=getSignalCount(repo,runID);
    if sigCount==0
        runIDs(runIDs==runID)=[];
        repo.removeRun(runID);
        repo.decrementRunNumbers(runIDs);
        if isempty(runIDs)
            runIDs=int32.empty;
        end



        if length(runIDs)==1
            repo.setRunName(runIDs,runName);
        end
    end
end

