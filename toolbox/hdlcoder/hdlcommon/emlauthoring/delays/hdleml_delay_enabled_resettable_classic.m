%#codegen
function y=hdleml_delay_enabled_resettable_classic(u,rst,enb,ic)





    coder.allowpcode('plain')
    eml_prefer_const(ic);

    persistent bypass
    if isempty(bypass)
        bypass=bypass_register_init(ic,size(ic));
    end

    persistent reg;
    if isempty(reg)


        reg=eml_const(ic);
    end

    if(rst==1)
        delay_out=eml_const(ic);
    else
        delay_out=reg;
    end

    if(enb==1)
        y=delay_out;
    else
        y=bypass;
    end

    bypass=delay_out;

    reg=u;


