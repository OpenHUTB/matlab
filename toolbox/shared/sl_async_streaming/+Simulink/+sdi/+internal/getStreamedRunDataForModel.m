function[ds,updatedDLO]=getStreamedRunDataForModel(mdl,varargin)

















    targetName='';
    if numel(varargin)>7
        targetName=varargin{8};
    end

    locPartialFlush(mdl,targetName);

    ret=locGetDataset(mdl,targetName,varargin{:});
    ds=ret.ds;
    updatedDLO=ret.updatedDLO;
end


function locPartialFlush(mdl,targetName)
    Simulink.HMI.partialFlushWorkerQueueForRunCreation(mdl,targetName);
end


function locFullFlush()
    repo=sdi.Repository(1);
    Simulink.HMI.synchronouslyFlushWorkerQueue(repo);
end


function ret=locGetDataset(mdl,targetName,varargin)

    ret.updatedDLO=[];


    repo=sdi.Repository(1);

    runID=0;

    if numel(varargin)>8
        runID=varargin{9};
    end

    if~runID
        runID=Simulink.HMI.getCurrentCachedRunID(repo,mdl,targetName);
    end

    if~runID
        locFullFlush();
        runID=repo.getCurrentStreamingRunID(mdl,targetName);
    end



    bExportCopy=false;
    if length(varargin)>5
        bExportCopy=varargin{6};
        varargin(6)=[];
    end


    if runID
















        bHasAugmentedDS=...
        length(varargin)>5&&...
        ~isempty(varargin{6})&&...
        numElements(varargin{6});
        if~bExportCopy&&~bHasAugmentedDS&&~isdeployed()
            [ret.ds,ret.updatedDLO]=locCreateRepoBackedDataset(mdl,targetName,runID,varargin{:});
        else

            varargin{3}=[];


            locFullFlush();



            cachedRunID=runID;
            runID=repo.getCurrentStreamingRunID(mdl,targetName);
            if~runID
                runID=cachedRunID;
            end


            if runID
                exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
                [ret.ds,ret.updatedDLO]=exporter.exportRun(repo,runID,false,true,varargin{:});
            else
                ret.ds=[];
            end
        end

    elseif length(varargin)>5
        ret.ds=varargin{6};
    else
        ret.ds=[];
    end



    if~runID&&length(varargin)>4&&~isempty(varargin{5})
        ret.ds=locAddInactiveVariants(ret.ds,varargin{5},varargin{1});
    end
end


function ds=locAddInactiveVariants(ds,vars,dsName)
    if isempty(ds)
        ds=Simulink.SimulationData.Dataset();
        ds.Name=dsName;
    end

    numVars=numel(vars);
    for idx=1:numVars
        sig=Simulink.SimulationData.Signal;
        sig.Name=vars(idx).SigName;
        sig.PropagatedName=vars(idx).PropName;
        sig.BlockPath=vars(idx).BlockPath;
        sig.Values=timeseries.empty();
        ds=addElement(ds,vars(idx).Index,sig);
    end
end


function[ds,updatedDLO]=locCreateRepoBackedDataset(mdl,targetName,runID,varargin)

    if length(varargin)>=2
        logIntervals=varargin{2};
    else
        logIntervals=[];
    end


    dlo=[];

    if length(varargin)>=4
        domain=varargin{4};
    else
        domain='';
    end
    bIsSigLog=isempty(domain);


    ds=Simulink.sdi.internal.createRepositoryBackedDataset(...
    runID,domain,logIntervals,dlo);


    if bIsSigLog
        updatedDLO=ds.getStorage(false).validateOverride();
    else
        updatedDLO=[];
    end


    if length(varargin)>4&&~isempty(varargin{5})
        ds=locAddInactiveVariants(ds,varargin{5},varargin{1});
    end


    if~isempty(varargin)
        ds.Name=varargin{1};
    end





    if bIsSigLog&&locOverrideTurnedOffAllLogging(varargin{3})








        locFullFlush();
        repo=sdi.Repository(1);
        runID=repo.getCurrentStreamingRunID(mdl,targetName);
        if runID
            if~numElements(ds)
                ds=[];
            end
        else
            ds=[];
        end
    end
end


function ret=locOverrideTurnedOffAllLogging(mi)
    ret=false;



    if isempty(mi)||~strcmpi(mi.LoggingMode,'OverrideSignals')
        return
    end


    numSignals=length(mi.Signals);
    for idx=1:numSignals
        if mi.Signals(idx).LoggingInfo.DataLogging
            return
        end
    end


    ret=true;
end
