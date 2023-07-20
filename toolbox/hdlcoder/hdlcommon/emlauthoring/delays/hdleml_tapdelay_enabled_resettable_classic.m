%#codegen
function y=hdleml_tapdelay_enabled_resettable_classic(u,enb,rst,N,ic,includeCurrent,oldestFirst)





    coder.allowpcode('plain')
    eml_prefer_const(N,ic,includeCurrent,oldestFirst);

    persistent bypass
    if isempty(bypass)
        bypass=eml_const(ic);
    end

    persistent reg;
    if isempty(reg)


        reg=eml_const(ic);
    end

    if(includeCurrent)
        if(oldestFirst)
            if(rst==1)
                delay_out=[ic,u];
            else
                delay_out=[reg,u];
            end
        else
            if(rst==1)
                delay_out=[u,ic];
            else
                delay_out=[u,reg];
            end
        end
    else
        if(rst==1)
            delay_out=ic;
        else
            delay_out=reg;
        end
    end

    if(includeCurrent)
        if(oldestFirst)
            if(enb==1)
                y=delay_out;
            else
                y=[bypass,u];
            end
        else
            if(enb==1)
                y=delay_out;
            else
                y=[u,bypass];
            end
        end
    else
        if(enb==1)
            y=delay_out;
        else
            y=bypass;
        end
    end

    bypass=reg;

    if(oldestFirst)
        reg=[reg(2:N),u];
    else
        reg=[u,reg(1:(N-1))];
    end