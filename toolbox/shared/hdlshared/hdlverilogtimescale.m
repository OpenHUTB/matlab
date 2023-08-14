function timescale=hdlverilogtimescale()





    if hdlgetparameter('use_verilog_timescale')
        timescale='`timescale 1 ns / 1 ns\n\n';
    else
        timescale='';
    end



