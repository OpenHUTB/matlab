










function values=outDataTypeStr2baseType(system,dataTypeStrs)



    if ischar(dataTypeStrs)
        dataTypeStrs={dataTypeStrs};
    end

    systemRoot=bdroot(system);
    dataTypeStrs=normalizeDataTypeString(dataTypeStrs);
    values=dataTypeStrs;

    for n=1:length(dataTypeStrs)

        thisString=dataTypeStrs{n};


        if Advisor.Utils.Simulink.isSimulinkBasicType(thisString)
            continue;
        end


        if strncmpi(thisString,'Bus: ',5)||...
            strncmpi(thisString,'Enum: ',6)||...
            strncmpi(thisString,'Inherit: ',9)
            continue;
        end



        if isvarname(thisString)&&existsInGlobalScope(systemRoot,thisString)



            evalCmd=['enumeration(''',thisString,''');'];
            enumNames=evalinGlobalScope(systemRoot,evalCmd);
            if~isempty(enumNames)
                values{n}=['Enum: ',thisString];
                continue;
            end

            try
                obj=evalinGlobalScope(systemRoot,thisString);
            catch
                continue;
            end


            if isa(obj,'Simulink.AliasType')
                values(n)=...
                Advisor.Utils.Simulink.outDataTypeStr2baseType(...
                system,obj.BaseType);
            elseif isa(obj,'Simulink.NumericType')
                switch obj.DataTypeMode
                case 'Double',values{n}='double';
                case 'Single',values{n}='single';
                case 'Boolean',values{n}='boolean';
                otherwise
                end
            end

        end
    end
end









function dtStringsOut=normalizeDataTypeString(dtStringsIn)
    dtStringsOut=strtrim(dtStringsIn);
    for index=1:numel(dtStringsOut)
        thisString=dtStringsOut{index};
        colonIndex=find(thisString==':');
        if numel(colonIndex)==1
            tagName=strtrim(thisString(1:colonIndex-1));
            typeString=strtrim(thisString(colonIndex+1:end));
            if~isempty(tagName)&&~isempty(typeString)
                dtStringsOut{index}=[tagName,': ',typeString];
            end
        end
    end
end


