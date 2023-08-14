function inRanges=getInputConnectedRanges(obj)



    portObjs=get_param(obj.blockObject.portHandles.Inport,'Object');

    eai=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();

    if isa(portObjs,'cell')
        eaiObjCell=cell(size(portObjs));
        eaiObjCell(:)={eai};

        runObjCell=cell(size(portObjs));
        runObjCell(:)={obj.runObj};

        allResultsCell=cell(size(portObjs));
        allResultsCell(:)={obj.allResults};

        inRanges=cellfun(@getPortConnectedRange,eaiObjCell,portObjs,runObjCell,allResultsCell,'UniformOutput',false);
    else
        numPorts=length(portObjs);
        inRanges=cell(numPorts,1);
        for idx=1:numPorts
            inRanges{idx}=getPortConnectedRange(eai,portObjs(idx),obj.runObj,obj.allResults);
        end
    end

    function range=getPortConnectedRange(eai,portHObject,runObj,allResults)

        range=[];


        blockExists=getSimulinkBlockHandle(portHObject.Parent)~=-1;

        if blockExists

            blkObj=get_param(portHObject.Parent,'Object');


            autoscalerRegistered=eai.getAutoscaler(blkObj);
            srcInfo=autoscalerRegistered.getAllSourceSignal(portHObject,false);

            range=getSourceDerivedRange(eai,srcInfo,runObj,allResults);
        end


        if isempty(range)
            designMin=portHObject.CompiledPortDesignMin;
            designMax=portHObject.CompiledPortDesignMax;

            if~isempty(designMin)&&~isempty(designMax)&&~isnan(designMin)&&~isnan(designMax)
                range=[designMin,designMax];
            else
                range=[-Inf,Inf];
            end
        end

        function range=getSourceDerivedRange(eai,srcInfo,runObj,allResults)


            numSources=length(srcInfo);
            range=[];

            for idx=1:numSources
                [srcResult,~]=findResultFromArrayOrCreate(runObj,...
                {'Object',srcInfo{idx}.blkObj,'ElementName',srcInfo{idx}.pathItem});

                if srcResult.hasDerivedMinMax
                    newRanges=srcResult.DerivedRangeIntervals;
                    numNewRanges=size(newRanges,1);
                    range(end+1:end+numNewRanges,:)=newRanges;
                elseif srcInfo{idx}.blkObj.isa('Simulink.SignalConversion')
                    for portIdx=1:numel(srcInfo{idx}.blkObj.PortHandles.Inport)
                        portObj=get_param(srcInfo{idx}.blkObj.PortHandles.Inport(portIdx),'Object');
                        r=getPortConnectedRange(eai,portObj,runObj,allResults);
                        numNewRanges=size(r,1);
                        range(end+1:end+numNewRanges,:)=r;
                    end
                else
                    range=[];
                    return;
                end
            end



