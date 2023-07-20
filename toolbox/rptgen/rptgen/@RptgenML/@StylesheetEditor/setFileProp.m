function valueStored=setFileProp(h,proposedValue,propName)




    j=h.JavaHandle;
    if isempty(j)
        valueStored=proposedValue;
    else

        valueStored='';

        if rptgen.use_java
            if~isempty(proposedValue)
                proposedValue=java.io.File(proposedValue);
            else
                proposedValue=[];
            end
            javaMethod(['set',propName],j,proposedValue);
        else
            setRegistry(j,proposedValue);
        end

    end

