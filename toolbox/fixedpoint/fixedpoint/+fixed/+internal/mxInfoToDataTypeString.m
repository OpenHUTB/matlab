function[DTstring,IsScaledDouble]=mxInfoToDataTypeString(mxInfoID,mxInfos,mxArrays)




    IsScaledDouble=false;
    mxInfo=mxInfos{mxInfoID};
    if isa(mxInfo,'eml.MxFiInfo')
        [DTstring,IsScaledDouble]=makeFiDTstring(mxInfo,mxArrays);
    else
        DTstring=mxInfo.Class;
    end


end

function[DTstring,IsScaledDouble]=makeFiDTstring(mxInfo,mxArrays)
    T=mxArrays{mxInfo.NumericTypeID};
    IsScaledDouble=false;
    if isscaleddouble(T)



        IsScaledDouble=true;
        T.DataType='Fixed';
        DTstring=tostring(T);
    elseif isscaledtype(T)


        DTstring=tostring(T);
    else

        DTstring=T.DataType;
    end
end

