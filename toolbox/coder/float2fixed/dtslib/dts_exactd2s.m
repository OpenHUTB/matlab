%#codegen


function p=dts_exactd2s(x)


    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    coder.internal.prefer_const(x);
    coder.inline('always');
    if coder.internal.isConst(x)
        for ii=1:numel(x)
            if~exactd2s_scalar(x(ii))
                p=false;
                return;
            end
        end
        p=true;
    else
        p=false;
    end
end


function p=exactd2s_scalar(x)


    coder.inline('always');
    coder.internal.prefer_const(x);
    p=isscalar(x)&&isa(x,'double')&&isreal(x)&&...
    (x(1)==0||~isfinite(x(1))||(...
    abs(x(1))>=eps(realmin('single'))&&...
    abs(x(1))<=realmax('single')&&...
    single(x(1))==x(1)));
end
