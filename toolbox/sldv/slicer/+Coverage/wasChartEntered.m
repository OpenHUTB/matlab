function yesno=wasChartEntered(cvd,chartBlkObj,refMdlToMdlBlk)








    if isempty(cvd)
        yesno=true;
        return;
    end
    conditionalSubSysH=[];
    sysO=chartBlkObj;
    try
        while true
            if isa(sysO,'Simulink.BlockDiagram')
                if refMdlToMdlBlk.isKey(sysO.Handle)
                    sysO=get(refMdlToMdlBlk(sysO.Handle),'Object');
                else
                    break;
                end
            elseif(isa(sysO,'Simulink.SubSystem')||isa(sysO,'Simulink.ModelReference'))...
                &&(~isempty(sysO.PortHandle.Enable)...
                ||~isempty(sysO.PortHandle.Trigger)...
                ||~isempty(sysO.PortHandle.Ifaction)...
                ||~isempty(sysO.PortHandle.Reset))
                conditionalSubSysH=sysO.Handle;
                break;
            elseif isa(sysO,'Stateflow.Object')
                break;
            else
                sysO=get(sysO.getParent,'Object');
            end
        end
    catch mex
    end

    initTimes=0;
    if~isempty(conditionalSubSysH)
        if isa(sysO,'Simulink.SubSystem')&&sysO.isSynthesized




            sysO=get_param(sysO.getOriginalBlock,'Object');
            conditionalSubSysH=sysO.Handle;
        end

        if isa(sysO,'Simulink.ModelReference')

            refMdl=get_param(sysO.Handle,'ModelName');
            covIdx=getCovIdx(cvd,get_param(refMdl,'Handle'),'decision');
        else
            covIdx=getCovIdx(cvd,conditionalSubSysH,'decision');
        end
        activeIdx=[];
        streamData=[];
        if~isempty(covIdx)
            streamData=getStreamData(cvd,covIdx);

            if~isempty(streamData)
                if~isFcnCallTrigger(sysO)

                    activeIdx=find(streamData(:,3));
                else



                    activeIdx=1:size(streamData,1);
                end
            end
        else




            if~isempty(sysO.PortHandle.Ifaction)
                ifPortObj=get_param(sysO.PortHandle.Ifaction,'Object');


                srcInfo=ifPortObj.getActualSrc;
                srcPortH=srcInfo(1);
                srcBlkH=get_param(get_param(srcPortH,'parent'),'handle');

                covIdx=getCovIdx(cvd,srcBlkH,'decision');
                streamData=getStreamData(cvd,covIdx);
                portNum=get_param(srcPortH,'portnumber');
                if~isempty(streamData)
                    blockType=get_param(srcBlkH,'BlockType');
                    if strcmpi(blockType,'If')


                        decVal=portNum-1;
                        activeIdx=find(streamData(:,3)==decVal);
                    elseif strcmpi(blockType,'SwitchCase')



                        caseConditions=slResolve(get_param(srcBlkH,'CaseConditions'),srcBlkH);
                        len=cellfun(@(cond)length(cond),caseConditions);








                        indices=[0,cumsum(len)];
                        indices=[indices,indices(end)+1];



                        decVal=indices(portNum):indices(portNum+1)-1;
                        for i=1:length(decVal)
                            activeIdx=[activeIdx;find(streamData(:,3)==decVal(i))];%#ok<AGROW>
                        end
                        activeIdx=sort(activeIdx);
                    end
                end
            end
        end
        if~isempty(activeIdx)&&~isempty(streamData)

            trueStarts=streamData(activeIdx,1);
            if isSubsysReset(conditionalSubSysH)



                initTimes=trueStarts;
            else


                initTimes=trueStarts(1);
            end
        end
    end
    if isempty(cvd.constraintTimeIntervals)
        yesno=any((cvd.startTime<=initTimes)&(cvd.stopTime>=initTimes));
    else
        yesno=false;
        for i=1:size(cvd.constraintTimeIntervals,1)
            tstart=cvd.constraintTimeIntervals(i,1);
            tend=cvd.constraintTimeIntervals(i,2);
            yesno=yesno||any((tstart<=initTimes)&(tend>=initTimes));
        end
    end
end

function yesno=isFcnCallTrigger(sysO)
    yesno=false;
    if isempty(sysO.PortHandle.Trigger)
        return;
    end

    blk=getSysChildren(sysO);
    triggerBlk=blk(arrayfun(@(b)filtBlock(b,'TriggerPort'),blk));
    yesno=strcmp(triggerBlk.TriggerType,'function-call');
end

function yesno=isSubsysReset(subsysH)



    yesno=false;
    sysO=get_param(subsysH,'Object');

    if~isempty(sysO.PortHandle.Reset)
        yesno=true;
        return;
    end
    blk=getSysChildren(sysO);
    enableBlk=blk(arrayfun(@(b)filtBlock(b,'EnablePort'),blk));
    triggerBlk=blk(arrayfun(@(b)filtBlock(b,'TriggerPort'),blk));
    actionBlk=blk(arrayfun(@(b)filtBlock(b,'ActionPort'),blk));

    if~isempty(enableBlk)
        yesno=strcmp(enableBlk.StatesWhenEnabling,'reset');
    end

    if~isempty(triggerBlk)
        yesno=yesno||strcmp(triggerBlk.StatesWhenEnabling,'reset');
    end
    if~isempty(actionBlk)
        yesno=yesno||strcmp(actionBlk.InitializeStates,'reset');
    end

end

function yesno=filtBlock(bObj,blockType)
    yesno=isa(bObj,'Simulink.Block')&&strcmpi(bObj.BlockType,blockType);
end

function blk=getSysChildren(sysO)
    if isa(sysO,'Simulink.ModelReference')
        refMdl=get_param(sysO.Handle,'ModelName');
        bdObj=get_param(refMdl,'Object');
        blk=bdObj.getChildren;
    else
        blk=sysO.getChildren;
    end
end