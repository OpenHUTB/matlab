%#codegen
function y=hdleml_tapdelay_resettable_classic(u,rst,N,ic,includeCurrent,oldestFirst)





    coder.allowpcode('plain')
    eml_prefer_const(N,ic,includeCurrent,oldestFirst);

    persistent reg;
    if isempty(reg)


        reg=eml_const(ic);
    end

    if(includeCurrent)
        if(oldestFirst)
            if(rst==1)
                y=[ic,u];
            else
                y=[reg,u];
            end
        else
            if(rst==1)
                y=[u,ic];
            else
                y=[u,reg];
            end
        end
    else
        if(rst==1)
            y=ic;
        else
            y=reg;
        end
    end

    if(oldestFirst)
        reg=[reg(2:N),u];
    else
        reg=[u,reg(1:(N-1))];
    end
