function v=validateBlock(this,hC)




    v=hdlvalidatestruct;

    checkPortVectorLen=true;


    ipSlType=hdlsignalsltype(hC.PirInputSignals(1));
    opSlType=hdlsignalsltype(hC.PirOutputSignals(1));
    doubleType={'single','double'};

    if any(strcmpi(ipSlType,doubleType))||any(strcmpi(opSlType,doubleType))
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:pskModulator:validateBlock:doubletype'));
    end


    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=this.buildSysObjParams(hC,sysObjHandle);
    else
        blockInfo=this.buildBlockParams(hC);
    end

    M=blockInfo.M;


    if strcmpi(blockInfo.type,'mpsk')
        if~any(M==[2,4,8])
            checkPortVectorLen=false;
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:pskModulator:validateBlock:M248'));
        end
    end

    if(checkPortVectorLen)
        if strcmpi(blockInfo.type,'bpsk')
            RequiredArrayLen=1;
        else
            if blockInfo.IntegerInput
                RequiredArrayLen=1;
            else
                if strcmpi(blockInfo.type,'qpsk')
                    RequiredArrayLen=2;
                else
                    RequiredArrayLen=log2(M);
                end
            end
        end


        msg=dsphdlshared.validation.getMultiSymbolValidationMessage(hC.PirInputSignals(1),...
        RequiredArrayLen);

        v(end+1)=baseValidateVectorPortLength(this,hC.PirInputSignals(1),...
        RequiredArrayLen,msg);
    end

end

