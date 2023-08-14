function addDataFromDerivedRange(data,selectedRunName)











    if data.isSFRecord


        sfData=idToHandle(sfroot,str2double(data.tag));

        chartId=sf('DataChartParent',sfData.Id);
        chartHandle=sf('Private','chart2block',chartId);
        chartSys=get_param(chartHandle,'Object');
        blkPath=chartSys.getFullName;

        rangeData=createSFDataStruct(blkPath,sfData);
    elseif~isempty(data.emlId)
        portURL=Simulink.URL.parseURL(data.tag);
        blkURL=portURL.getParent;
        blkObj=get_param(blkURL,'Object');
        blkPath=blkObj.getFullName;
        rangeData.Path=blkPath;
    else

        portURL=Simulink.URL.parseURL(data.tag);
        blkURL=portURL.getParent;
        blkObj=get_param(blkURL,'Object');
        blkPath=blkObj.getFullName;




        if isa(blkObj,'Simulink.SubSystem')&&slprivate('is_stateflow_based_block',blkObj.Handle)


            sfData=blkObj.find('-isa','Stateflow.Data','Scope','Output','Port',portURL.getIndex,'-depth',2);
            if~isempty(sfData)
                blkPath=blkObj.getFullName;
                rangeData=createSFDataStruct(blkPath,sfData);
            else

                return;
            end
        else

            signalName=portURL.getIndex;

            asExtension=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
            blkAutoscaler=asExtension.getAutoscaler(blkObj);
            pathItem=blkAutoscaler.getPortMapping(blkObj,[],signalName);


            rangeData.Path=blkPath;
            if isempty(pathItem)
                rangeData.ElementName='1';
            else
                rangeData.ElementName=pathItem{1};
            end
        end
    end

    if(data.isIssueRange)






    else

        if(data.isEmptyRange)

            rangeData.DerivedMin=[];
            rangeData.DerivedMax=[];
            rangeData.DerivedRangeIntervals=[];




        else
            rangeData.DerivedMin=data.derivedMin;
            rangeData.DerivedMax=data.derivedMax;
            rangeData.DerivedRangeIntervals=data.derivedRangeIntervals;
        end
    end

    bd=bdroot(blkPath);

    if nargin<2
        FPTRunName=get_param(data.model,'FPTRunName');
    else
        FPTRunName=selectedRunName;
    end





    if isequal(bd,data.model)
        appdata=SimulinkFixedPoint.getApplicationData(bd);

        curRefDataset=appdata.dataset;
    else
        if isempty(data.instanceHandle)



            return;
        else

            instanceMdl=get_param(bdroot(data.instanceHandle),'Name');
            appdata=SimulinkFixedPoint.getApplicationDataAsSubMdl(instanceMdl,data.instanceHandle);
            curRefDataset=appdata.subDatasetMap(data.instanceHandle);
            appdata.dataset.setLastUpdatedRun(FPTRunName);
        end
    end

    runObj=curRefDataset.getRun(FPTRunName);
    curRefDataset.setLastUpdatedRun(FPTRunName);
    if isempty(data.emlId)&&isInternalResult(data)
        ascalerData=runObj.getMetaData;
        if isempty(ascalerData)
            runObj.setMetaData(fxptds.AutoscalerMetaData);
            ascalerData=runObj.getMetaData;
        end
        ascalerData.addInternalDerivedRangeData(data.tag,rangeData);
    else
        if~isempty(data.emlId)

            rangeData.uniqueID=data.emlId;
            if(isa(data.emlId,'fxptds.MATLABVariableIdentifier'))

                runObj.createAndUpdateResultWithID(rangeData);
            else



                if(slsvTestingHook('FxptuiExpr')==1)
                    if(rangeData.uniqueID.Reason==fxptds.InstrumentationReason.REASON_ADD||...
                        rangeData.uniqueID.Reason==fxptds.InstrumentationReason.REASON_SUBTRACT||...
                        rangeData.uniqueID.Reason==fxptds.InstrumentationReason.REASON_MULTIPLY||...
                        rangeData.uniqueID.Reason==fxptds.InstrumentationReason.REASON_DIVIDE)
                        runObj.createAndUpdateResultWithID(rangeData);
                    end
                elseif(slsvTestingHook('FxptuiExpr')>1)
                    runObj.createAndUpdateResultWithID(rangeData);
                end
            end
        else
            runObj.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(rangeData));
        end
    end

    function ret=isInternalResult(data)
        if data.isSFRecord
            ret=false;
        else
            portURL=Simulink.URL.parseURL(data.tag);
            portIdx=portURL.getIndex;
            ret=portIdx>=1000000;
        end

        function rangeData=createSFDataStruct(blkPath,sfData)
            rangeData.Path=blkPath;
            rangeData.dataName=sfData.Name;
            rangeData.dataID=sfData.Id;
            rangeData.isStateflow=true;

            dataChartName=strrep(blkPath,'/','_');
            dataSignalName=[dataChartName,'_',sfData.Name,'_',num2str(sfData.Id)];
            rangeData.ElementName=dataSignalName;




