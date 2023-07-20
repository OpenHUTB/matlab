



















function isEnumDT=isEnumOutDataTypeStr(system,dataTypeStr)

    if nargin>0
        system=convertStringsToChars(system);
    end

    if nargin>1
        dataTypeStr=convertStringsToChars(dataTypeStr);
    end

    isEnumDT=false;

    systemRoot=getfullname(bdroot(system));

    if Advisor.Utils.Simulink.isSimulinkBasicType(dataTypeStr)
        return;
    end

    if strncmpi(dataTypeStr,'Bus:',4)
        return;
    end

    if strncmpi(dataTypeStr,'Inherit:',7)
        return;
    end


    if strncmpi(dataTypeStr,'Enum:',5)
        isEnumDT=true;
        return;
    end

    if isvarname(dataTypeStr)
        enumNames=evalinGlobalScope(systemRoot,['enumeration(''',dataTypeStr,''');']);
        if~isempty(enumNames)
            isEnumDT=true;
            return;
        end
    end


    try
        res=evalinGlobalScope(systemRoot,dataTypeStr);


        if isa(res,'Simulink.AliasType')&&isEnumOutDataTypeStr(systemRoot,res.BaseType)
            isEnumDT=true;
        elseif ischar(res)&&isEnumOutDataTypeStr(systemRoot,res)
            isEnumDT=true;
        elseif isa(res,'meta.class')&&(res.Enumeration||strcmpi(res.SuperclassList.Name,'Simulink.IntEnumType'))
            isEnumDT=true;
        end


    catch


    end

end
