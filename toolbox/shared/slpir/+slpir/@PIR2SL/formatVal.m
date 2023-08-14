
function retval=formatVal(this,val,isUsedInEval)



    if(nargin<3)
        isUsedInEval=false;
    end
    if isempty(val)
        retval='[]';
    elseif ischar(val)
        retval=strrep(val,'''','''''');
        if~isUsedInEval
            retval=sprintf('''%s''',retval);
        end
    elseif isstring(val)
        retval=strrep(val,newline,'\n');
        retval=sprintf("""%s""",retval);
    elseif(~isscalar(val)&&~isvector(val))
        retval=formatMatrixVal(this,val,isUsedInEval);
    elseif(isnumerictype(val)||isa(val,'Simulink.NumericType'))
        retval=val.tostring;
    elseif isa(val,'function_handle')
        retval=getFormatValStr(this,val(1),isUsedInEval);
    elseif~isscalar(val)
        if isfi(val)
            if isreal(val)||all(val(:)~=0)


                retval=mat2str(val,'class');
            else


                retval=['complex(',mat2str(real(val),'class'),', ',mat2str(imag(val),'class'),')'];
            end
            retval=strrep(retval,'''','"');
        else
            if(~isreal(val)&&~iscell(val))
                cval=complex(val(1));
            else
                cval=val(1);
            end






            if(~isreal(val))


                retval=['complex(',class(val),'([',getFormatValStr(this,cval,isUsedInEval)];
            else
                retval=[class(val),'([',getFormatValStr(this,cval,isUsedInEval)];
            end
            for i=2:length(val)
                if(~isreal(val)&&~iscell(val))
                    cval=complex(val(i));
                else
                    cval=val(i);
                end

                retval=[retval,' ',getFormatValStr(this,cval,isUsedInEval)];%#ok<AGROW>
            end
            if(~isreal(val))
                retval=[retval,']))'];
            else
                retval=[retval,'])'];
            end
            retval=strrep(retval,'''','"');

            if ndims(val)>1&&size(val,2)==1&&~isUsedInEval
                retval=[retval,'.'''];
            end
        end
    else

        if isfloat(val)&&isreal(val)
            retval=sprintf('%s(%s)',class(val),getFormatValStr(this,val,isUsedInEval));
        else
            retval=getFormatValStr(this,val,isUsedInEval);
        end
    end
end


function retval=getFormatValStr(this,val,isUsedInEval)
    if~isfi(val)
        if~isreal(val)&&~iscell(val)

            rpart=real(val);
            if isnan(rpart)
                rpartStr=returnNaN(rpart);
            else
                rpartStr=fixed.internal.compactButAccurateNum2Str(rpart);
            end

            ipart=imag(val);
            if isnan(rpart)
                ipartStr=returnNaN(ipart);
            else
                ipartStr=fixed.internal.compactButAccurateNum2Str(ipart);
            end

            retval=['complex(',rpartStr,...
            ', ',ipartStr,')'];
        else

            if isfloat(val)
                if isnan(val)
                    retval=returnNaN(val);
                else
                    lowerPrecision=sprintf('%s(%s)',class(val),num2str(val));







                    if(isequal(val,eval(lowerPrecision)))
                        retval=num2str(val);
                    else
                        retval=coder.internal.compactButAccurateNum2Str(val);
                    end
                end
            else
                className=class(val);
                if isSLEnumType(className)
                    [enumVals,enumStrs]=enumeration(className);
                    enumStr=enumStrs{enumVals==val};
                    retval=[className,'.',enumStr];
                elseif iscell(val)
                    retval=formatCell(this,val,isUsedInEval);
                else
                    retval=num2str(val);
                end
            end
        end
    else
        retval=sprintf('fi(0,%d,%d,%d,"hex","%s")',...
        val.Signed,val.WordLength,val.FractionLength,val.hex);
    end
end

function derivedNaN=returnNaN(val)

    className=class(val);
    if strcmpi(className,'half')
        valCast=val.storedInteger;
        msbBit=bitget(valCast,16);
    elseif strcmpi(className,'single')
        valCast=typecast(val,'uint32');
        msbBit=bitget(valCast,32);
    else
        valCast=typecast(val,'uint64');
        msbBit=bitget(valCast,64);
    end

    if msbBit
        derivedNaN='NaN';
    else
        derivedNaN='-NaN';
    end

end
