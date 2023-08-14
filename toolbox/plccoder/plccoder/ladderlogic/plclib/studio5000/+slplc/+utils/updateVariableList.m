function updateVariableList(pouBlock)



    pouType=slplc.utils.getParam(pouBlock,'PLCPOUType');
    globalVarNames={};
    if strcmpi(pouType,'Program')
        rootControllerBlock=slplc.utils.getRootPOU(pouBlock,'PLC Controller');
        if~isempty(rootControllerBlock)
            globalVariables=slplc.utils.getVariableList(rootControllerBlock);
            if~isempty(globalVariables)
                globalVarNames={globalVariables.Name};
            end
        end
    end

    if strcmpi(slplc.utils.getModelGenerationStatus(pouBlock),...
        'ModelUpdate')&&isempty(globalVarNames)

        return
    end


    operandVariables=slplc.utils.getOperandVariable(pouBlock);
    pouOperandVarNames={};
    if~isempty(operandVariables)
        pouOperandVarNames={operandVariables.Name};
    end

    defaultScope='Local';
    extVarNames={};
    if strcmpi(pouType,'PLC Controller')
        defaultScope='Global';
        extVariables=getExtVariables(pouBlock);
        if~isempty(extVariables)
            extVarNames={extVariables.Name};
        end
    end

    defautPortIndex='1';
    if strcmpi(pouType,'Function Block')
        defautPortIndex='2';
    end

    operandVarNames=unique([pouOperandVarNames,extVarNames]);
    varList=slplc.utils.getVariableList(pouBlock);


    for varCount=1:numel(varList)
        varList(varCount).IsUsed=ismember(varList(varCount).Name,operandVarNames);
        if~ismember('IsAutoImport',fieldnames(varList))||isempty(varList(varCount).IsAutoImport)
            varList(varCount).IsAutoImport=false;
        end
    end

    if~isempty(varList)
        varNames={varList.Name};
    else
        varNames={};
    end


    newVarNames=setdiff(operandVarNames,varNames);
    newVarList=[];
    for varCount=1:numel(newVarNames)
        varName=newVarNames{varCount};
        dataScope=defaultScope;
        if ismember(varName,globalVarNames)

            dataScope='External';
            inferredVarInfo=globalVariables(ismember(globalVarNames,varName));
        elseif ismember(varName,pouOperandVarNames)

            inferredVarInfo=operandVariables(ismember(pouOperandVarNames,varName));
        else

            inferredVarInfo=extVariables(ismember(extVarNames,varName));
        end
        varInfo=slplc.utils.createNewVar(varName,dataScope,defautPortIndex,inferredVarInfo.DataType,...
        inferredVarInfo.InitialValue,inferredVarInfo.IsFBInstance,'readwrite');
        if isempty(newVarList)
            newVarList=varInfo;
        else
            newVarList(end+1)=varInfo;
        end
    end



    for varCount=1:numel(varList)
        varInfo=varList(varCount);


        if~varInfo.IsUsed||varInfo.IsAutoImport
            continue
        end

        if ismember(varInfo.Name,pouOperandVarNames)

            inferredVarInfo=operandVariables(ismember(pouOperandVarNames,varInfo.Name));
        else

            inferredVarInfo=extVariables(ismember(extVarNames,varInfo.Name));
        end
        if(~isempty(inferredVarInfo.DataType)&&strcmpi(varInfo.DataType,slplc.utils.getDefaultDataType()))||...
            (~isempty(inferredVarInfo.IsFBInstance)&&inferredVarInfo.IsFBInstance)||...
            (~isempty(inferredVarInfo.IsFBInstance)&&~inferredVarInfo.IsFBInstance&&varInfo.IsFBInstance)
            varInfo.DataType=inferredVarInfo.DataType;
        end
        if(~isempty(inferredVarInfo.InitialValue)&&~strcmp(inferredVarInfo.InitialValue,'0')&&strcmpi(varInfo.InitialValue,'0'))
            varInfo.InitialValue=inferredVarInfo.InitialValue;
        end
        if~isempty(inferredVarInfo.IsFBInstance)
            varInfo.IsFBInstance=inferredVarInfo.IsFBInstance;
        end
        varInfo.Access=inferredVarInfo.Access;
        varList(varCount)=varInfo;
    end


    varList=[varList,newVarList];
    slplc.utils.setVariableList(pouBlock,varList);
end

function extVariables=getExtVariables(sysBlock)
    programPOUs=plc_find_system(sysBlock,'LookUnderMasks','all','FollowLinks','on','PLCPOUType','Program');
    fbPOUs=plc_find_system(sysBlock,'LookUnderMasks','all','FollowLinks','on','PLCPOUType','Function Block');
    pouBlks=[programPOUs;fbPOUs];

    extVariables=[];
    defaultDataType=slplc.utils.getDefaultDataType();
    for pouCount=1:numel(pouBlks)
        varList=slplc.utils.getVariableList(pouBlks{pouCount});
        for varCount=1:numel(varList)
            currentVar=varList(varCount);
            if strcmpi(currentVar.Scope,'External')
                if isempty(extVariables)

                    extVariables=currentVar;
                elseif~ismember(currentVar.Name,{extVariables.Name})

                    extVariables(end+1)=currentVar;%#ok<*AGROW>
                else
                    varIdx=ismember({extVariables.Name},currentVar.Name);
                    if~strcmpi(currentVar.DataType,defaultDataType)&&strcmpi(extVariables(varIdx).DataType,defaultDataType)
                        extVariables(varIdx).DataType=currentVar.DataType;
                    end
                    if~strcmpi(currentVar.InitialValue,'0')&&strcmpi(extVariables(varIdx).InitialValue,'0')
                        extVariables(varIdx).InitialValue=currentVar.InitialValue;
                    end
                    if currentVar.IsFBInstance&&~extVariables(varIdx).IsFBInstance
                        extVariables(varIdx).IsFBInstance=currentVar.IsFBInstance;
                    end
                    if~strcmpi(currentVar.Access,extVariables(varIdx).Access)
                        extVariables(varIdx).Access='ReadWrite';
                    end
                end
            end
        end
    end
end


