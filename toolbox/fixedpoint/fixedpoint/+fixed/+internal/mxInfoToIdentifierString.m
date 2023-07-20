function mxInfo_str=mxInfoToIdentifierString(symbol_name,mxInfo,mxInfos,mxArrays)



    size_str=mxInfoSizeString(mxInfo);
    proto=makePrototypeString(mxInfo,mxInfos,mxArrays);
    mxInfo_str=[symbol_name,',',size_str,',',proto];

end

function size_str=mxInfoSizeString(mxInfo)
    size_str='';
    if~isempty(mxInfo.SizeDynamic)
        staticDynamic=~any(mxInfo.SizeDynamic);
    else
        staticDynamic=false;
    end
    for i=1:length(mxInfo.Size)
        if i>1
            size_str=[size_str,'x'];%#ok<AGROW>
        end
        if mxInfo.Size(i)==-1
            dimSize='?';
        else
            dimSize=num2str(mxInfo.Size(i));
        end
        if i<=numel(mxInfo.SizeDynamic)&&mxInfo.SizeDynamic(i)
            dimSize=[':',dimSize];%#ok<AGROW>
        end
        size_str=[size_str,dimSize];%#ok<AGROW>
    end
    if staticDynamic
        size_str=[size_str,'*'];
    end

end


function proto=makePrototypeString(mxInfo,mxInfos,mxArrays)

    if isa(mxInfo,'eml.MxFiInfo')
        proto=makeFiPrototype(mxInfo,mxArrays);
    elseif isa(mxInfo,'eml.MxNumericInfo')
        proto=makeNumericPrototype(mxInfo);
    elseif isa(mxInfo,'eml.MxFimathInfo')
        proto=makeFimathPrototype(mxInfo,mxArrays);
    elseif isa(mxInfo,'eml.NumericTypeInfo')
        proto=makeNumericTypePrototype(mxInfo,mxArrays);
    elseif isa(mxInfo,'eml.MxStructInfo')
        proto=makeStructPrototype(mxInfo,mxInfos,mxArrays);
    elseif isa(mxInfo,'eml.MxClassInfo')
        proto=makeClassPrototype(mxInfo,mxInfos,mxArrays);
    elseif isa(mxInfo,'eml.MxInfo')
        proto=makeMxInfoPrototype(mxInfo);
    else
        proto='';
    end

end

function proto=makeFiPrototype(mxInfo,mxArrays)
    value=getPrototypeValue(mxInfo);
    T=mxArrays{mxInfo.NumericTypeID};
    if isscaleddouble(T)
        T.DataType='Fixed';
        Tstr=tostring(T);
        Tstr=strrep(Tstr,')',',''DataType'',''ScaledDouble'')');
    else
        Tstr=tostring(T);
    end
    proto=strrep(Tstr,'numerictype(',['fi(',value,',']);
    if mxInfo.FiMathLocal

        F=mxArrays{mxInfo.FiMathID};
        Fstr=fimathToStringRow(F);

        Fstr=strrep(Fstr,'fimath(','');
        proto=strrep(proto,')',[',',Fstr]);
    end
end

function proto=makeFimathPrototype(mxInfo,mxArrays)
    F=mxArrays{mxInfo.FiMathID};
    proto=fimathToStringRow(F);
end

function proto=makeNumericTypePrototype(mxInfo,mxArrays)
    T=mxArrays{mxInfo.NumericTypeID};
    proto=fimathToStringRow(T);
end

function proto=makeNumericPrototype(mxInfo)
    value=getPrototypeValue(mxInfo);

    proto=[mxInfo.Class,'(',value,')'];
end

function proto=makeStructPrototype(mxInfo,mxInfos,mxArrays)
    proto='struct(';
    for n=1:length(mxInfo.StructFields)
        next_symbol_name=mxInfo.StructFields(n).FieldName;
        next_mxInfo=mxInfos{mxInfo.StructFields(n).MxInfoID};
        next_field_prototype=fixed.internal.mxInfoToIdentifierString(...
        next_symbol_name,next_mxInfo,mxInfos,mxArrays);
        proto=[proto,',',next_field_prototype];%#ok<AGROW>
    end
    proto=[proto,')'];
end

function proto=makeClassPrototype(mxInfo,mxInfos,mxArrays)
    proto=[mxInfo.Class,'('];
    for n=1:length(mxInfo.ClassProperties)
        if isa(mxInfo.ClassProperties(n),'eml.MxFieldInfo')
            next_symbol_name=mxInfo.ClassProperties(n).FieldName;
        elseif isa(mxInfo.ClassProperties(n),'eml.MxPropertyInfo')
            next_symbol_name=mxInfo.ClassProperties(n).PropertyName;
        else

            next_symbol_name='';
        end
        next_mxInfo=mxInfos{mxInfo.ClassProperties(n).MxInfoID};
        next_field_prototype=fixed.internal.mxInfoToIdentifierString(...
        next_symbol_name,next_mxInfo,mxInfos,mxArrays);
        proto=[proto,',',next_field_prototype];%#ok<AGROW>
    end
    proto=[proto,')'];
end

function proto=makeMxInfoPrototype(mxInfo)
    switch mxInfo.Class
    case 'logical'
        proto=[mxInfo.Class,'([])'];
    otherwise
        proto=[mxInfo.Class,'(0)'];
    end
end

function value=getPrototypeValue(mxInfo)
    if mxInfo.Complex
        value='1i';
    else
        value='[]';
    end
end

function Fstr=fimathToStringRow(F)
    Fstr=tostring(F);

    Fstr=strrep(Fstr,char([46,46,46,10]),'');

    Fstr=strrep(Fstr,' ','');
end
