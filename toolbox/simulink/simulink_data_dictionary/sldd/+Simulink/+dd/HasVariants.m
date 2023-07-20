function has=HasVariants(ddConn,scope,name)

    has=false;

    try
        if ddConn.entryExists([scope,'.',name],false)
            dd=Simulink.data.dictionary.open(ddConn.filespec);
            scope=dd.getSection(scope);
            try
                allVariants=scope.getEntry(name);
            catch
                allVariants={};
            end
        else
            allVariants={};
        end

        has=false;
        count=length(allVariants);
        for idx=1:count
            entry=allVariants(idx).getValue();
            if isa(entry,'Simulink.dd.DataVariant')
                has=true;
                break;
            end
        end

    catch
    end
end
