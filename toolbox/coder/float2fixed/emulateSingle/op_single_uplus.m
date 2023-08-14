%#codegen

function c=op_single_uplus(a)
    coder.allowpcode('plain');
    coder.internal.prefer_const(a);
    coder.inline('always');

    if isfloat(a)

        c=coder.nullcopy(a);

        for ii=1:numel(a)
            c(ii)=a(ii);
        end

    else


        c=+a;
    end
end
