function checkValueIsValidScalar(symbolName,value)
    if isa(value,'timeseries')

        tsDims=ndims(value.Data);
        if tsDims==2&&size(value.Data,2)>1

            error(message('sltest:assessments:SymbolValueNotScalar',symbolName));
        elseif tsDims>2

            for i=1:tsDims-1
                if size(value.Data,i)>1
                    error(message('sltest:assessments:SymbolValueNotScalar',symbolName));
                end
            end
        end
        assert(length(value.Data)>=1);
        scalarValue=value.Data(1);
    else

        if~isscalar(value)
            error(message('sltest:assessments:SymbolValueNotScalar',symbolName));
        end
        scalarValue=value;
    end

    if~islogical(scalarValue)&&~isnumeric(scalarValue)
        error(message('sltest:assessments:InvalidSymbolValueType',class(scalarValue),symbolName));
    end
end
