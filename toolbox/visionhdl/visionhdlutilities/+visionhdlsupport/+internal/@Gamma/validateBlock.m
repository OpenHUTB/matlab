function v=validateBlock(this,hC)




    v=hdlvalidatestruct;

    if isa(hC,'hdlcoder.sysobj_comp')

        this.validatePortDatatypes(hC);
    end

    blockInfo=getBlockInfo(this,hC);
    address_width=log2(length(blockInfo.LUT));
    if address_width>16
        v(end+1)=hdlvalidatestruct(1,...
        message('visionhdl:GammaCorrector:HDLAddrUpTo16Bit',address_width));
    end


    [~,any_double,~]=checkForDoublePorts(this,[hC.PirInputPorts(1),hC.PirOutputPorts(1)]);
    if any_double
        v(end+1)=hdlvalidatestruct(1,...
        message('visionhdl:GammaCorrector:DoubleType'));
    end