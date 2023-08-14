%#codegen


function c=dts_binary_op(op,a,b)
    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    coder.inline('always');
    coder.internal.prefer_const(a,b,op);

    if isnumeric(a)&&isnumeric(b)
        if isfloat(a)
            if isinteger(b)
                if eml_is_const(a)&&is_whole_number(a)


                    c=op(double(a),b);
                else


                    coder.internal.assert(false,'Coder:FXPCONV:DTS_IntegerOpSingle');
                    c=op(a,b);
                end
            elseif isfi(b)

                c=op(dts_cast(a),b);
            else

                assert(isfloat(b));


                if eml_is_const(a)&&eml_is_const(b)&&...
                    eml_is_const(is_precise(op,a,b))&&~eml_const(is_precise(op,a,b))

                    c=dts_cast(op(double(a),double(b)));
                else
                    c=op(dts_cast(a),dts_cast(b));
                end
            end
        elseif isfloat(b)

            if isinteger(a)
                if eml_is_const(b)&&is_whole_number(b)


                    c=op(a,double(b));
                else


                    coder.internal.assert(false,'Coder:FXPCONV:DTS_IntegerOpSingle');
                    c=op(a,b);
                end
            else

                assert(isfi(a));
                c=op(a,dts_cast(b));
            end
        elseif isinteger(a)&&isinteger(b)
            coder.internal.assert(isa(b,class(a)),'Coder:FXPCONV:DTS_IntegerClassError');
            c=op(a,b);
        else

            c=op(a,b);
        end
    else

        c=op(a,b);
    end
end

function r=is_whole_number(c)
    coder.inline('always');
    c_f=c(:);
    r=all((c_f-floor(c_f))==0);
end

function p=is_precise(op,a,b)
    coder.inline('always');
    coder.internal.prefer_const(a,b);
    d=op(double(a),double(b));
    p=dts_exactd2s(d);
end


