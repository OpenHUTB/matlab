function[actSrc]=getActualSrc(blkH,port)









    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try
        pHArray=get_param(blkH,'PortHandles');
        numIn=numel(pHArray.Inport);
        numEnable=numel(pHArray.Enable);
        numTrigger=numel(pHArray.Trigger);
        if port<numIn;
            pH=pHArray.Inport(port+1);
        elseif port<(numIn+numEnable)
            pH=pHArray.Enable(port+1-numIn);
        elseif port<(numIn+numEnable+numTrigger)
            pH=pHArray.Trigger(port+1-numIn-numEnable);
        else
            error('Unknown block port requested.');
        end

        inObj=get_param(pH,'Object');
        asObj=inObj.getActualSrc;
        numSrcs=size(asObj,1);

        actSrc=zeros(numSrcs,5);
        for srcIdx=1:numSrcs
            srcPortObj=asObj(srcIdx,1);
            portNum=get_param(srcPortObj,'PortNumber')-1;
            srcPortParent=get_param(srcPortObj,'ParentHandle');
            srcOffset=asObj(srcIdx,2);
            srcWidth=asObj(srcIdx,3);
            if size(asObj,2)==3
                srcBusElIdx=-1;
            else
                srcBusElIdx=asObj(srcIdx,4);
            end
            if strcmp(get_param(srcPortParent,'BlockType'),'S-Function')||...
                strcmp(get_param(srcPortParent,'BlockType'),'Merge')
                srcPortGrandParent=get_param(get_param(srcPortParent,'Parent'),'Handle');
                if strcmp(get_param(srcPortGrandParent,'Type'),'block')&&...
                    slci.internal.isStateflowBasedBlock(srcPortGrandParent)
                    chartId=sfprivate('block2chart',srcPortGrandParent);
                    chartObj=idToHandle(sfroot,chartId);
                    fcalls=chartObj.find('-isa','Stateflow.FunctionCall');
                    if~isempty(fcalls)
                        hasFunctionCallEvent=true;
                    else
                        events=chartObj.find('-isa','Stateflow.Event');
                        hasFunctionCallEvent=false;
                        for eIdx=1:numel(events)
                            event=events(eIdx);
                            if strcmp(event.Scope,'Output')&&...
                                strcmp(event.Trigger,'Function call')
                                hasFunctionCallEvent=true;
                                break;
                            end
                        end
                    end


                    if hasFunctionCallEvent&&portNum==0
                        srcWidth=1;
                        srcOffset=0;
                    end
                end
            end

            srcPortParent=slci.internal.getOrigRootIOPort(srcPortParent,'Inport');
            actSrc(srcIdx,1)=srcPortParent;
            actSrc(srcIdx,2)=portNum;
            actSrc(srcIdx,3)=srcOffset;
            actSrc(srcIdx,4)=srcWidth;
            actSrc(srcIdx,5)=srcBusElIdx;
        end
    catch ME
        error(['error computing actual sources for ',get_param(blkH,'Name'),', port ',num2str(port+1)]);
    end


