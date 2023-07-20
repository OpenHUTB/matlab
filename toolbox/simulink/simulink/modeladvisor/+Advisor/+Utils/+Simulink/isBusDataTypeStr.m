


















function isBusDT=isBusDataTypeStr(system,dataTypeStr)

    if nargin>0
        system=convertStringsToChars(system);
    end

    if nargin>1
        dataTypeStr=convertStringsToChars(dataTypeStr);
    end

    isBusDT=false;

    systemRoot=getfullname(bdroot(system));

    if Advisor.Utils.Simulink.isSimulinkBasicType(dataTypeStr)
        return;
    end

    if strncmpi(dataTypeStr,'Bus:',4)
        isBusDT=true;
        return;
    end

    if strncmpi(dataTypeStr,'Inherit:',7)
        return;
    end


    if strncmpi(dataTypeStr,'Enum:',5)
        return;
    end


    try
        res=evalinGlobalScope(systemRoot,dataTypeStr);


        if isa(res,'Simulink.AliasType')&&isBusDataTypeStr(systemRoot,res.BaseType)
            isBusDT=true;
        elseif ischar(res)&&isBusDataTypeStr(systemRoot,res)
            isBusDT=true;
        elseif isa(res,'Simulink.Bus')
            isBusDT=true;
        end


    catch


    end

end
