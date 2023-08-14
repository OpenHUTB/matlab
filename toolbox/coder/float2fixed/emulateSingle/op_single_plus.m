%#codegen

function c=op_single_plus(a,b)
    coder.allowpcode('plain');
    coder.internal.prefer_const(a,b);
    coder.inline('always');

    if isfloat(a)&&isfloat(b)
        c=performEmulatedPlus(a,b);
    else


        c=a+b;
    end
end

function c=performEmulatedPlus(a,b)

    c=coder.nullcopy(a+b);


    if(size(a)==size(b))

        for ii=1:numel(a)
            a_e=e_single(a(ii));
            b_e=e_single(b(ii));
            c_e=e_single_add(a_e,b_e);
            c(ii)=e_single_to_float(c_e);
        end


    elseif(numel(a)==1&&numel(b)>1)

        for ii=int32(1):numel(b)
            a_e=e_single(a);
            b_e=e_single(b(ii));
            c_e=e_single_add(a_e,b_e);
            c(ii)=e_single_to_float(c_e);
        end


    elseif(numel(b)==1&&numel(a)>1)
        for ii=1:numel(a)
            a_e=e_single(a(ii));
            b_e=e_single(b);
            c_e=e_single_add(a_e,b_e);
            c(ii)=e_single_to_float(c_e);
        end


    else
        assert(false,'Addition of Vectors/Matrices of different dimensions is not supported');
    end
end
