function v=validateBlock(this,hC)





    v=baseValidateCtlPort(this,hC);

    blockInfo=this.getBlockInfo(hC.SimulinkHandle);
    result=checkInputPortLatch(blockInfo);
    if~isempty(result)
        for i=1:length(result)
            v(end+1)=result(i);%#ok<AGROW>
        end
    end

    hNIC=hC.Owner.instances;
    result=checkNICRates(this,hNIC);
    if~isempty(result)
        for i=1:length(result)
            v(end+1)=result(i);%#ok<AGROW>
        end
    end

    result=checkTriggerAsClock(hC);
    if~isempty(result)
        for i=1:length(result)
            v(end+1)=result(i);%#ok<AGROW>
        end
    end




    if hC.Owner.hasFloatingPointSignals(true)
        if targetcodegen.targetCodeGenerationUtils.isAlteraMode()
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedForAltera'));
        elseif targetcodegen.targetCodeGenerationUtils.isXilinxMode()
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedForXilinx'));
        end
    end

    result=checkForNestedModelRefs(hC);
    if~isempty(result)
        for i=1:length(result)
            v(end+1)=result(i);%#ok<AGROW>
        end
    end
end


function result=checkInputPortLatch(blockInfo)
    result=hdlvalidatestruct;

    inputs=blockInfo.InputBlocks;
    numInputs=length(inputs);

    for i=1:numInputs
        current=inputs(i);
        if(~strcmp(current.LatchByDelayingOutsideSignal,'off'))
            result(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:latchedInputPort',current.Name));%#ok<AGROW>
        end
    end

    if length(result)==1&&result(1).Status==0
        result=[];
    end
end


function result=checkNICRates(this,hNIC)
    result=hdlvalidatestruct;
    numInstances=length(hNIC);

    for i=1:numInstances
        current=hNIC(i);
        sigs=[current.SLInputSignals;current.SLOutputSignals];
        rateResult=this.checkRates(sigs);
        if~isempty(rateResult)
            for j=1:length(rateResult)
                result(end+1)=rateResult(j);%#ok<AGROW>
            end
        end
    end
    if length(result)==1&&result(1).Status==0
        result=[];
    end
end


function result=checkTriggerAsClock(hC)
    result=[];
    tac=hdlgetparameter('TriggerAsClock');
    if tac==1
        clockedge=hdlgetparameter('ClockEdge');
        slbh=hC.SimulinkHandle;
        triggerKind=get_param(slbh,'TriggerType');

        if clockedge==1&&strcmpi(triggerKind,'rising')
            msg=message('hdlcoder:validate:TriggerAsClockEdge',...
            get_param(slbh,'Name'),triggerKind,get_param(slbh,'Parent'));
            result=hdlvalidatestruct(2,msg);
        elseif clockedge==0&&strcmpi(triggerKind,'falling')
            msg=message('hdlcoder:validate:TriggerAsClockEdge',...
            get_param(slbh,'Name'),triggerKind,get_param(slbh,'Parent'));
            result=hdlvalidatestruct(2,msg);
        elseif~strcmpi(triggerKind,'rising')&&~strcmpi(triggerKind,'falling')
            msg=message('hdlcoder:validate:TriggerAsClockEdgeUnsupported');
            result=hdlvalidatestruct(1,msg);
        end
    end
end

function result=checkForNestedModelRefs(hC)
    result=hdlvalidatestruct;



    mrBlocks=find_system(hC.Owner.SimulinkHandle,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','BlockType','ModelReference');
    for ii=1:numel(mrBlocks)
        mrBlock=mrBlocks(ii);
        mrBlkObj=get_param(mrBlock,'Object');
        mrFullName=mrBlkObj.getFullName;
        hdlArch=hdlget_param(mrFullName,'Architecture');
        if strcmp(hdlArch,'ModelReference')
            result(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:NestedModelRef',mrFullName));%#ok<AGROW>
        end
    end

    if length(result)==1&&result(1).Status==0
        result=[];
    end
end
