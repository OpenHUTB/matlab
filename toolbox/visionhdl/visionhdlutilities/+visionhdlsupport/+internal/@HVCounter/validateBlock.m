function v=validateBlock(this,hC)





    v=hdlvalidatestruct;


    [~,any_double,~]=checkForDoublePorts(this,[hC.PirOutputPorts(1),hC.PirOutputPorts(2)]);
    if any_double
        v(end+1)=hdlvalidatestruct(1,...
        message('visionhdl:HVCounter:doubletype'));
    end

