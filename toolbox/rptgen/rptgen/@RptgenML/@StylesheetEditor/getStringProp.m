function returnedValue=getStringProp(h,storedValue,propName)




    j=h.JavaHandle;

    if isempty(j)
        returnedValue=storedValue;
    else
        if rptgen.use_java
            returnedValue=javaMethod(['get',propName],j);
            if~isempty(returnedValue)
                returnedValue=char(returnedValue);
            else
                returnedValue='';
            end
        else
            returnedValue=j.(propName);
        end

    end
