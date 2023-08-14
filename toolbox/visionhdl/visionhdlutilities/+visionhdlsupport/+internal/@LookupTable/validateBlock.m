function v=validateBlock(this,hC)




    v=hdlvalidatestruct;
    blockInfo=getBlockInfo(this,hC);


    address_width=log2(length(blockInfo.LUT));
    if address_width>16
        v(end+1)=hdlvalidatestruct(1,...
        message('visionhdl:LookupTable:AddressWordLength'));
    end


    [~,any_double,~]=checkForDoublePorts(this,hC.PirOutputPorts(1));
    if any_double

        v(end+1)=hdlvalidatestruct(1,...
        message('visionhdl:LookupTable:DoubleType'));
    end





