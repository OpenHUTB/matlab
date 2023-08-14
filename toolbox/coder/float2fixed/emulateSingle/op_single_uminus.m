%#codegen

function c=op_single_uminus(a)
    coder.allowpcode('plain');
    coder.internal.prefer_const(a);
    coder.inline('always');

    if isfloat(a)

        c=coder.nullcopy(a);

        for ii=1:numel(a)
            a_e=e_single(a(ii));
            c_e=e_single_uminus(a_e);
            c(ii)=e_single_to_float(c_e);
        end

    else


        c=-a;
    end
end
