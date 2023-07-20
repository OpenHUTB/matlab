%#codegen
function y=hdleml_tapdelay_enabled_classic(u,enb,N,ic,includeCurrent,oldestFirst)





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
            if(enb==1)
                y=[reg,u];
            else
                y=[bypass,u];
            end
        else
            if(enb==1)
                y=[u,reg];
            else
                y=[reg(1),bypass];
            end
        end
    else
        if(enb==1)
            y=reg;
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