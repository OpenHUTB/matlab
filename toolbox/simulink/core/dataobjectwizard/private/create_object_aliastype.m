function mismatch=create_object_aliastype(modelName,dataStruct)




    mismatch='';


    if existsInGlobalScope(modelName,dataStruct.name)
        if isempty(dataStruct.BaseType)&&...
            (evalinGlobalScope(modelName,['isa(',dataStruct.name,',''Simulink.AliasType'')';])||...
            evalinGlobalScope(modelName,['isa(',dataStruct.name,',''Simulink.NumericType'')';]))


            return
        end
        if evalinGlobalScope(modelName,['isa(',dataStruct.name,',''Simulink.AliasType'')';])
            alias_ws=evalinGlobalScope(modelName,dataStruct.name);
            if isa(dataStruct.BaseType,'Simulink.AliasType')
                if~isequal(alias_ws,dataStruct.BaseType)
                    mismatch=dataStruct.name;
                    return
                end
            else
                if~strcmp(alias_ws.BaseType,dataStruct.BaseType)||...
                    ~strcmp(alias_ws.HeaderFile,dataStruct.HeaderFile)
                    mismatch=dataStruct.name;
                    return
                end
            end
        elseif evalinGlobalScope(modelName,['isa(',dataStruct.name,',''Simulink.NumericType'')';])
            numeric_ws=evalinGlobalScope(modelName,dataStruct.name);
            if isa(dataStruct.BaseType,'Simulink.NumericType')
                numeric=dataStruct.BaseType;
            else
                numeric=evalstr(dataStruct);
                numeric.IsAlias=dataStruct.isAlias;
            end
            if~isequal(numeric_ws,numeric)
                mismatch=dataStruct.name;
                return
            end
        end
    end


    if strcmp(dataStruct.type,'AliasType')

        if isa(dataStruct.BaseType,'Simulink.AliasType')
            objType=dataStruct.BaseType;
        elseif isempty(dataStruct.BaseType)
            objType=Simulink.AliasType;
        else
            objType=Simulink.AliasType;
            objType.HeaderFile=dataStruct.HeaderFile;
            objType.BaseType=dataStruct.BaseType;
            objType.Description=dataStruct.Description;
        end
    else

        if isa(dataStruct.BaseType,'Simulink.NumericType')
            objType=dataStruct.BaseType;
        else
            objType=evalstr(dataStruct);
            objType.IsAlias=dataStruct.isAlias;
        end
    end

    assigninGlobalScope(modelName,dataStruct.name,objType);


    function out=evalstr(dataStruct)


        out=eval(dataStruct.BaseType);
