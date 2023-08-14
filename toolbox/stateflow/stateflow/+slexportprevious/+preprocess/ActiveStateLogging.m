function ActiveStateLogging(obj)




    chartsThatNeedToasting=containers.Map('KeyType','double','ValueType','double');

    if isR2013aOrEarlier(obj.ver)

        obj.appendRule('<Simulink.OptimizationCC<ActiveStateOutputEnumStorageType:remove>>');
    end

    machine=getStateflowMachine(obj);
    if isempty(machine)
        return;
    end

    needsScrubbing=isR2015aOrEarlier(obj.ver);
    if~needsScrubbing
        return;
    end

    targetReleaseDoesNotSupportSelfActivityWithADifferentName=isR2012bOrEarlier(obj.ver);
    targetReleaseDoesNotSupportChildStateActivity=isR2012bOrEarlier(obj.ver);
    targetReleaseDoesNotSupportLeafStateActivity=isR2013bOrEarlier(obj.ver);
    targetReleaseDoesNotSupportActiveStateLocals=isR2015aOrEarlier(obj.ver);


    allChartIds=sf('get',machine.Id,'machine.charts');
    for i=1:length(allChartIds)
        sfObjIds=[allChartIds(i),sf('SubstatesIn',allChartIds(i))];
        monitoredObjectIds=sf('find',sfObjIds,'~.outputData',0);
        for sfObjId=monitoredObjectIds(:)'
            outputState=idToHandle(sfroot,sfObjId);
            if targetReleaseDoesNotSupportChildStateActivity&&strcmpi(outputState.OutputMonitoringMode,'ChildActivity')
                outputState.HasOutputData=0;
                checkForToasting(allChartIds(i));
                obj.reportWarning('Stateflow:misc:ChildActivityInPrevVersion',sf('get',sfObjId,'.name'),sf('get',allChartIds(i),'.name'));
            end
            if targetReleaseDoesNotSupportLeafStateActivity&&strcmp(outputState.OutputMonitoringMode,'LeafStateActivity')
                outputState.OutputMonitoringMode='ChildActivity';
                outputState.HasOutputData=0;
                checkForToasting(allChartIds(i));
                obj.reportWarning('Stateflow:misc:LeafStateActivityInPrevVersion',sf('get',sfObjId,'.name'),sf('get',allChartIds(i),'.name'));
            end
            if targetReleaseDoesNotSupportSelfActivityWithADifferentName&&strcmp(outputState.OutputMonitoringMode,'SelfActivity')
                data=outputState.outputData;
                cachedDataName=data.name;
                data.name=outputState.name;
                if~strcmp(data.name,outputState.name)

                    outputState.hasOutputData=0;
                    checkForToasting(allChartIds(i));
                    obj.reportWarning('Stateflow:misc:SelfActivityInPrevVersionNotAble',sf('get',sfObjId,'.name'),sf('get',allChartIds(i),'.name'));
                else
                    if(~strcmp(data.name,cachedDataName))
                        obj.reportWarning('Stateflow:misc:SelfActivityInPrevVersionRename',sf('get',sfObjId,'.name'));
                    end



                    chartBlockName=sf('get',sf('get',allChartIds(i),'.instance'),'.simulink');
                    portNumber=sprintf('%i',data.Port);
                    portH=Stateflow.SLUtils.findSystem(chartBlockName,'BlockType','Outport','Port',portNumber);
                    if isa(outputState,'Stateflow.AtomicSubchart')
                        set_param(portH,'Name',[' ',data.name,' ']);
                    else
                        set_param(portH,'Name',data.name);
                    end
                end
            end


            if outputState.hasOutputData&&targetReleaseDoesNotSupportActiveStateLocals&&strcmpi(outputState.outputData.Scope,'LOCAL')
                outputData=outputState.outputData;
                outputData.Scope='Output';
                obj.reportWarning('Stateflow:misc:StateActivityLocalConvertedToOutput',sf('get',sfObjId,'.name'),sf('get',allChartIds(i),'.name'));
            end
        end
    end

    if targetReleaseDoesNotSupportChildStateActivity&&targetReleaseDoesNotSupportLeafStateActivity

        obj.appendRule('<state<activeStateOutput:remove>>');
        obj.appendRule('<chart<activeStateOutput:remove>>');
    end


    toastChartsThatNeedToasting;

    function toastChartsThatNeedToasting()
        chartIds=chartsThatNeedToasting.keys;
        for iter=1:length(chartIds)
            chartId=chartIds{iter};
            sf('Toast',chartId);
        end
    end


    function checkForToasting(chartId)
        assert(sf('get',chartId,'.isa')==1);



        chartUddH=idToHandle(sfroot,chartId);
        chartH=get_param(chartUddH.path,'Handle');
        if Stateflow.SLINSF.SubchartMan.isUsedAsComponent(chartH)
            parentId=chartUddH.getParent().id;
            switch sf('get',parentId,'.isa')
            case 1
                chartId=parentId;
            case 9
                chartId=parentId;
            case 4
                chartId=sf('get',parentId,'.chart');
            otherwise
                assert(false);
            end
            chartsThatNeedToasting(chartId)=1;
        end
    end
end
