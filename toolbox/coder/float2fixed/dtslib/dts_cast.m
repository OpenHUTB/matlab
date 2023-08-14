%#codegen


function out=dts_cast(value)
    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(value);
    coder.internal.allowHalfInputs;
    out=dts_cast_impl_codegen(value);
end

function out=dts_cast_impl_codegen(value)
    coder.internal.prefer_const(value);
    coder.inline('always');

    if isa(value,'double')
        if coder.internal.isConst(value)
            if isreal(value)&&eml_const(is_whole_number(value))
                if eml_const(dts_exactd2s(value))

                    out=single(value);
                else



                    coder.internal.compileWarning('Coder:FXPCONV:DTS_NonRepresentableIntegerConstant');
                    out=single(value);
                end
            else


                out=single(value);
            end
        else


            out=single(value);
        end
    elseif isa(value,'struct')
        nFields=eml_numfields(value);

        isAlwaysEmpty=coder.const(coder.internal.isConst(isempty(value))&&isempty(value));
        if nFields>0&&~isAlwaysEmpty

            for ii=coder.unroll(0:nFields-1)
                fieldname=eml_getfieldname(value,ii);
                fieldvalue=value(1).(fieldname);

                S.(fieldname)=dts_cast_impl_codegen(fieldvalue);
            end
            out=coder.nullcopy(eml_expand(S,size(value)));
            for ii=coder.unroll(0:nFields-1)
                fieldname=eml_getfieldname(value,ii);
                for jj=1:numel(value)
                    fieldvalue=value(jj).(fieldname);

                    out(jj).(fieldname)=dts_cast_impl_codegen(fieldvalue);
                end
            end
        else
            out=value;
        end
    elseif isa(value,'cell')

        out=value;
        assertCellsSupported();
    else
        out=value;
    end
end

function r=is_whole_number(c)
    coder.inline('always');
    c_f=c(:);
    r=all((c_f-floor(c_f))==0);
end

function assertCellsSupported()
    coder.extrinsic('coder.internal.f2ffeature');
    cellsSupported=false;
    cellsSupported=coder.const(coder.internal.f2ffeature('SingleCCellArraySupport'));
    if~cellsSupported
        coder.internal.assert(false,'Coder:FXPCONV:DTS_SingleC_CellArraysNotSupported');
    end
end


