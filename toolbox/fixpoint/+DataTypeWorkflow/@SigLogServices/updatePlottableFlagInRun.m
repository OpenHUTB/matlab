function updatePlottableFlagInRun(modelName,sdiTsRunID)





    sdiEngine=Simulink.sdi.Instance.engine();
    engineRunObj=getRun(sdiEngine,sdiTsRunID);
    totalSig=sdiEngine.getAllSignalIDs(sdiTsRunID,'leaf');

    fptRepository=fxptds.FPTRepository.getInstance;
    currDataset=fptRepository.getDatasetForSource(modelName);
    runName=currDataset.getCurrentRunName();
    fptTopRunObj=currDataset.getRun(runName);

    previousDataStruct=struct('Path','','ElementName','');
    for i=1:numel(totalSig)
        signal=engineRunObj.getSignal(totalSig(i));
        blkSrcFromSignal=signal.BlockSource;




        if~isempty(blkSrcFromSignal)
            blkObject=get_param(blkSrcFromSignal,'Object');
            portIndexValue=signal.portIndex;



            if portIndexValue==0&&fxptds.isSFMaskedSubsystem(blkObject)
                prtIndex=1;
                blockSource=[blkSrcFromSignal,'/',signal.signalLabel];
            else
                prtIndex=1;
                if portIndexValue>0
                    prtIndex=portIndexValue;
                end
                blockSource=blkSrcFromSignal;
            end
            if(prtIndex<0);continue;end

            data=struct('Path',blockSource,'ElementName',num2str(prtIndex));

            if isequal(previousDataStruct,data)

                continue;
            end


            mdlElements=regexp(blockSource,'/','split');
            mdlSource=mdlElements{1};

            if~strcmp(mdlSource,modelName)

                DataTypeWorkflow.SigLogServices.updateRunIDInfoInRun(mdlSource,sdiTsRunID);

                currDataset=fptRepository.getDatasetForSource(mdlSource);
                fptRunObj=currDataset.getRun(runName);
            else
                fptRunObj=fptTopRunObj;
            end

            previousDataStruct=data;

            dataObj=fxptds.SimulinkDataArrayHandler;

            uniqueID=dataObj.getUniqueIdentifier(data);
            if~isempty(uniqueID)
                res=fptRunObj.getResultByID(uniqueID);
                if isempty(res)
                    res=fptRunObj.createAndUpdateResult(dataObj);
                end
                res.updateTimeSeriesInformation(signal);
                res.updateVisibility;
            end
        end
    end
end

