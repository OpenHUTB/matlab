function valueStored=setStringProp(h,proposedValue,propName)




    j=h.JavaHandle;

    if isempty(j)
        valueStored=proposedValue;
    else
        if rptgen.use_java
            javaMethod(['set',propName],j,proposedValue);
        else
            j.(propName)=proposedValue;
        end
        valueStored='';
    end
