%#codegen
function y=hdleml_tapdelay(u,N,initval,includeCurrent,oldestFirst)





    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(N,initval,includeCurrent,oldestFirst);


    u=reshape(u,1,numel(u));

    persistent reg;
    if isempty(reg)


        if isfloat(u)||coder.isenum(u)
            reg=eml_const(initval);
        else
            reg=eml_const(cast(initval,'like',u));
        end
    end

    if(includeCurrent)
        if(oldestFirst)
            y=[reg,u];
        else
            y=[u,reg];
        end
    else
        y=reg;
    end

    N=numel(u);
    M=numel(reg)/N;

    if(oldestFirst)

        reg=[reg(N+1:M*N),u];
    else

        reg=[u,reg(1:(M-1)*N)];
    end

