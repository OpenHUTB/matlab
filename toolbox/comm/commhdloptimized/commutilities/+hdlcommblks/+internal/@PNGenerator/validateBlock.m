function v=validateBlock(this,hC)





    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...



    if hC.isParentTriggeredSubsystem&&hdlgetparameter('TriggerAsClock')
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:PNGenerator:validateBlock:triggeredasclock'));
    end




    outBitMaskSource=get_param(bfp,'outBitMaskSource');
    resetPort=strcmpi(get_param(bfp,'reset'),'on');
    bitPackedOutputs=strcmpi(get_param(bfp,'bitPackedOutputs'),'on');
    bitPackedOutDType=strcmpi(get_param(bfp,'bitPackedOutDType'),'double');
    outDataType=strcmpi(get_param(bfp,'outDataType'),'double');
    sampPerFrame=this.hdlslResolve('sampPerFrame',bfp);


    input_number=1;

    if strcmpi(outBitMaskSource,'Input port')
        mask_idx=hC.SLInputPorts(input_number).Signal;
        if~issinglebit(mask_idx)
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:PNGenerator:validateBlock:maskport'));
        end
        input_number=input_number+1;
    end


    if resetPort==1
        rst_idx=hC.SLInputPorts(input_number).Signal;
        if~issinglebit(rst_idx)
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:PNGenerator:validateBlock:resettype'));
        end
    end





    if((bitPackedOutputs==1)&&(bitPackedOutDType==1))||...
        ((bitPackedOutputs==0)&&(outDataType==1))

        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:PNGenerator:validateBlock:doubleoutput'));
    end


    if(sampPerFrame>1)
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:PNGenerator:validateBlock:vectoroutput'));
    end


    function boolout=issinglebit(sig)


        sig_idx_sltype=hdlsignalsltype(sig);
        [WL,BP,SIGNED]=hdlwordsize(sig_idx_sltype);
        boolout=all([1,0,0]==[WL,BP,SIGNED]);


