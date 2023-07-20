function v=baseValidateCtlPort(this,hC)





    blockInfo=this.getBlockInfo(hC.SimulinkHandle);
    blockInfo.isInHwFriendly=this.isInHwFriendly(hC);

    result=checkCtlPortOutput(blockInfo);
    if isempty(result)
        v=hdlvalidatestruct;
    else
        v=result;
    end

    ctlport=getCtlPort(hC);
    result=checkCtlPortType(ctlport);
    if~isempty(result)
        v(end+1)=result;
    end

    result=checkForOutputsHeld(blockInfo);
    if~isempty(result)
        for ii=1:length(result)
            v(end+1)=result(ii);%#ok<AGROW>
        end
    end

    hN=hC.Owner;
    sigs=[hN.SLInputSignals;hN.SLOutputSignals];
    result=this.checkRates(sigs);
    if~isempty(result)
        v(end+1)=result;
    end

    result=checkIfDut(hC);
    if~isempty(result)
        v(end+1)=result;
    end

    if~isa(this,'hdldefaults.ResetPort')
        result=checkPortInitialValues(blockInfo);
        if~isempty(result)
            for i=1:length(result)
                v(end+1)=result(i);%#ok<AGROW>
            end
        end
        result=checkNestedInResetRegion(hC);
        if~isempty(result)
            for i=1:length(result)
                v(end+1)=result(i);%#ok<AGROW>
            end
        end
    end
end



function result=checkCtlPortOutput(blockInfo)
    result=[];
    if strcmp(blockInfo.SLOutputPorts,'on')
        result=hdlvalidatestruct(1,message('hdlcoder:validate:outputPort'));
    end
end




function ctlport=getCtlPort(hC)
    ctlport=[];
    hN=hC.Owner;
    inputs=hN.PirInputPorts;
    numInputs=length(inputs);

    for i=numInputs:-1:1
        current=inputs(i);
        if current.isSubsystemEnable()
            ctlport=current;
            break;
        elseif current.isSubsystemTrigger()
            ctlport=current;
            break;
        elseif current.isSubsystemSyncReset()
            ctlport=current;
            break;
        end
    end
end


function result=checkCtlPortType(ctlport)
    result=[];
    if~isempty(ctlport)
        hS=ctlport.Signal;
        if~isempty(hS)
            ctlportType=hS.Type;

            if~ctlportType.isBooleanType&&~ctlportType.isUnsignedType(1)


                if ctlport.isSubsystemEnable
                    msgid='hdlcoder:validate:enablePortType';
                elseif ctlport.isSubsystemTrigger
                    msgid='hdlcoder:validate:triggerPortType';
                elseif ctlport.isSubsystemSyncReset
                    msgid='hdlcoder:validate:resetPortType';
                end
                result=hdlvalidatestruct(1,message(msgid));
            end
        end
    end
end


function result=checkForOutputsHeld(blockInfo)
    result=[];

    outputs=blockInfo.OutputBlocks;
    numOutputs=length(outputs);

    for i=1:numOutputs
        current=outputs(i);
        if~strcmp(current.OutputWhenDisabled,'held')
            msg=hdlvalidatestruct(1,message('hdlcoder:validate:heldOutputWhenDisabled',current.Name));
            if isempty(result)
                result=msg;
            else
                result(end+1)=msg;%#ok<AGROW>
            end
        end
    end
end



function result=checkIfDut(hC)
    result=[];
    subsystem=hC.Owner;
    p=pir;
    dut=p.getTopNetwork;

    if strcmp(subsystem.RefNum,dut.RefNum)
        result=hdlvalidatestruct(1,message('hdlcoder:validate:topDUT'));
    end
end



function result=checkPortInitialValues(blockInfo)
    result=[];
    if blockInfo.isInHwFriendly
        return
    end
    outputs=blockInfo.OutputBlocks;
    numOutputs=length(outputs);

    for i=1:numOutputs
        current=outputs(i);
        initVal=slResolve(current.InitialOutput,blockInfo.BlockHandle);
        if isempty(initVal)||any(initVal)
            msg=hdlvalidatestruct(1,message('hdlcoder:validate:nonZeroInitVal',current.Name));
            if isempty(result)
                result=msg;
            else
                result(end+1)=msg;%#ok<AGROW>
            end
        end
    end
end



function result=checkNestedInResetRegion(hC)
    result=[];
    hN=hC.Owner;
    if hN.isInResettableHierarchy
        fullPath=getfullname(hC.SimulinkHandle);
        result=hdlvalidatestruct(1,...
        message('hdlcoder:validate:CtlPortNestedInResetSS',fullPath));
    end
end
