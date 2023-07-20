function v=validateBlock(this,hC)






    v=hdlvalidatestruct;



    [~,any_double,~]=checkForDoublePorts(this,[hC.PirInputPorts(1),hC.PirOutputPorts(1)]);
    if any_double
        v(end+1)=hdlvalidatestruct(1,...
        message('dsphdl:FarrowRateConverter:doubletype'));
    end


