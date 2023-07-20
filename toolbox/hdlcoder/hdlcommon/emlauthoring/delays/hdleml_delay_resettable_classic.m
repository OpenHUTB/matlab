%#codegen
function data_out=hdleml_delay_resettable_classic(data_in,rst,ic)




    coder.allowpcode('plain')
    eml_prefer_const(ic);


    persistent switch_delay;
    if isempty(switch_delay)
        switch_delay=eml_const(ic);
    end

    if(rst==1)
        data_out=eml_const(ic);
    else
        data_out=switch_delay;
    end

    switch_delay=data_in;

