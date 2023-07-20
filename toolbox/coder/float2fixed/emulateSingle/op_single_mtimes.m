%#codegen

function c=op_single_mtimes(a,b)
    coder.allowpcode('plain');
    coder.internal.prefer_const(a,b);
    coder.inline('always');

    if isfloat(a)&&isfloat(b)
        c=performEmulatedMtimes(a,b);
    else


        c=a*b;
    end
end

function c=performEmulatedMtimes(a,b)

    c=coder.nullcopy(a+b);


    if(size(a)==size(b))

        for ii=1:numel(a)
            a_e=e_single(a(ii));
            b_e=e_single(b(ii));
            c_e=e_single_mtimes(a_e,b_e);
            c(ii)=e_single_to_float(c_e);
        end


    elseif(numel(a)==1&&numel(b)>1)

        for ii=1:numel(b)
            a_e=e_single(a);
            b_e=e_single(b(ii));
            c_e=e_single_mtimes(a_e,b_e);
            c(ii)=e_single_to_float(c_e);
        end


    elseif(numel(b)==1&&numel(a)>1)
        for ii=1:numel(a)
            a_e=e_single(a(ii));
            b_e=e_single(b);
            c_e=e_single_mtimes(a_e,b_e);
            c(ii)=e_single_to_float(c_e);
        end


    else

        assert(false,'mtimes of Vectors/Matrices of different dimensions is not supported');
    end

end
