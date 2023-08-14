function[streamout,streamoutName]=getRapidAccelStreamedData(...
    buildData,logSettings,slvrSettings,loggingFilePtr,isMenuSim,sdiRunId,simMetadata,domain,outportList)




    mdl=buildData.mdl;
    streamoutName='';
    streamout=[];
    if nargin<9
        outportList=[];
    end


    bSlioLTF=logSettings.signalLoggingToPersistentStorage==1;

    try



        if isequal(sdiRunId,0)&&sdi.Repository.sessionRequiresRaccelImport()
            Simulink.sdi.internal.importCompletedRapidAccelRuns(mdl,isMenuSim);
        end

        if~bSlioLTF

            streamoutName=locGetVariableName(buildData,domain);


            if~isempty(streamoutName)&&sdi.Repository.hasBeenCreated()


                if logSettings.signalLoggingToPersistentStorage
                    fname=logSettings.signalStorageParameters;
                    leafFmt=buildData.logging.datasetSignalFormat;
                    Simulink.sdi.internal.export.finalizeR2MATfile(...
                    mdl,...
                    domain,...
                    fname,...
                    streamoutName,...
                    leafFmt,...
                    outportList,...
                    loggingFilePtr);
                    streamoutName='';
                    return
                end

                logInt=locGetIntervals(buildData,slvrSettings.slvrOpts.LoggingIntervals);



                if strcmpi(domain,'streamoutblk')
                    domain=buildData.logging.streamoutDomain;
                end

                dlo=locGetOverride(buildData,domain);
                streamout=Simulink.sdi.internal.getStreamedRunDataForModel(...
                mdl,streamoutName,logInt,dlo,domain,'',~isequal(sdiRunId,0),'','',sdiRunId);

                if isequal(buildData.logging.SignalLoggingName,streamoutName)
                    if~numElements(streamout)
                        streamout=[];
                    end
                end
            end
        end
    catch me %#ok<NASGU>cd 
        streamoutName='';
        streamout=[];
    end


    if~isempty(streamoutName)&&nargin>8&&~isempty(outportList)
        streamout=locAddInactiveVariants(streamout,outportList,streamoutName);
    end

















    repo=sdi.Repository(1);
    runID=repo.getCurrentStreamingRunID(mdl);
    if runID&&~isempty(simMetadata)
        md=locConvertLoadedMetaDataIfNeeded(mdl,simMetadata,buildData);
        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        fw.setMetaDataForRun(md,runID);
    end
end


function ret=locGetVariableName(buildData,domain)
    ret='';
    switch lower(domain)
    case 'outport'
        ret=buildData.logging.OutputSaveName;
    case 'streamoutblk'
        ret=buildData.logging.streamoutVarName;
    otherwise
        if buildData.logging.SignalLogging
            ret=buildData.logging.SignalLoggingName;
        end
    end
end


function ret=locGetIntervalAsString(val)
    sz=size(val);
    ret='';
    for idx=1:sz(1)
        if idx~=1
            ret=[ret,';'];%#ok<AGROW>
        end
        str=sprintf('%.16f,',val(idx,:));
        ret=[ret,str(1:end-1)];%#ok<AGROW>
    end
    ret=sprintf('[%s]',ret);
end


function logInt=locGetIntervals(buildData,val)
    if~buildData.returnDstWkspOutput
        logInt=[];
    elseif isempty(val)||isequal(val,[Inf,Inf])||isequal(val,[-Inf,-Inf])
        logInt='[]';
    else
        logInt=locGetIntervalAsString(val);
    end
end


function dlo=locGetOverride(~,~)

    dlo=[];
end


function ds=locAddInactiveVariants(ds,outportList,dsName)
    if isempty(ds)
        ds=Simulink.SimulationData.Dataset();
        ds.Name=dsName;
    end
    for idx=1:numel(outportList)
        curEl=ds.find('BlockPath',outportList{idx}.BlockPath);
        if~getLength(curEl)

            sig=Simulink.SimulationData.Signal;
            sig.Name=outportList{idx}.Name;
            sig.PropagatedName=outportList{idx}.PropagatedName;
            sig.BlockPath=outportList{idx}.BlockPath;
            sig.Values=timeseries.empty();
            ds=addElement(ds,idx,sig);
        end
    end
end


function metaData=locConvertLoadedMetaDataIfNeeded(mdl,md,~)



    metaData=md;
    if isstruct(md)&&~isfield(md,'ModelInfo')&&~isempty(md)
        metaData=struct();
        metaData.ModelInfo.ModelName=mdl;
        metaData.ModelInfo.SimulationMode='rapid-accelerator';

        metaData.ModelInfo.SolverInfo.Solver=md.SolverName;
        if md.IsVariableStepSolver
            metaData.ModelInfo.SolverInfo.Type='Variable-Step ';
            metaData.ModelInfo.SolverInfo.MaxStepSize=md.StepSize;
        else
            metaData.ModelInfo.SolverInfo.Type='Fixed-Step ';
            metaData.ModelInfo.SolverInfo.FixedStepSize=md.StepSize;
        end

        metaData.ModelInfo.StartTime=md.StartTime;
        metaData.ModelInfo.StopTime=md.StopTime;


        metaData.ModelInfo.ModelVersion='';

        metaData.ModelInfo.UserID=getenv('USER');
        if isempty(metaData.ModelInfo.UserID)
            metaData.ModelInfo.UserID=getenv('USERNAME');
        end
        metaData.ModelInfo.MachineName=getenv('HOST');
        if isempty(metaData.ModelInfo.MachineName)
            metaData.ModelInfo.MachineName=getenv('HOSTNAME');
        end
        if isempty(metaData.ModelInfo.MachineName)
            metaData.ModelInfo.MachineName=getenv('COMPUTERNAME');
        end

        metaData.ModelInfo.SimulinkVersion=locGetSimulinkVersion();
        metaData.ModelInfo.Platform=computer;


        metaData.ExecutionInfo=struct();
        if md.ReachedStopTime
            metaData.ExecutionInfo.StopEvent='ReachedStopTime';
            metaData.ExecutionInfo.StopEventDescription=...
            getString(message('Simulink:Simulation:SimMetadataReachedStopTime',num2str(md.StopTime)));
        elseif md.StopRequested
            metaData.ExecutionInfo.StopEvent='ModelStop';
            metaData.ExecutionInfo.StopEventDescription=...
            getString(message('Simulink:Simulation:SimMetadataStopCommand',num2str(md.StopTime)));
        end


        metaData.TimingInfo=struct();
    end
end


function vers=locGetSimulinkVersion()
    persistent verInfo;
    if isempty(verInfo)
        verInfo=ver('Simulink');
    end
    vers=verInfo;
end
