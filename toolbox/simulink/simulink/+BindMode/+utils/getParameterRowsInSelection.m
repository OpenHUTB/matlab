
function[selectionRows,updateDiagramNeeded]=getParameterRowsInSelection(selectionHandles,varargin)



    if nargin>1
        usefindVars=varargin{1};
    else
        usefindVars=false;
    end

    tpStruct.allParams={};
    tpStruct.allIsParams={};
    tpStruct.allVarWorkspaceType={};
    tpStruct.blockNames={};
    tpStruct.blockHandles={};
    tpStruct.bUpdateDiagramNeeded=false;
    tpStruct.allIsComposite={};

    for i=1:length(selectionHandles)
        if(selectionHandles(i)==0)
            continue;
        end
        type=get_param(selectionHandles(i),'Type');
        if(~strcmp(type,'block'))
            continue;
        end
        modelName=bdroot(getfullname(selectionHandles(i)));

        if usefindVars
            [bindableParams,bUpdateDiagramNeeded]=BindMode.utils.getParametersUsedByBlk(getfullname(selectionHandles(i)));
        else
            parameterInterface=Simulink.HMI.ParamInterface(modelName);
            [bindableParams,bUpdateDiagramNeeded,~]=parameterInterface.getBindableParams(getfullname(selectionHandles(i)));
        end

        if isempty(bindableParams)
            paramsLabel={};
        else
            paramsLabel={bindableParams.ParamName};
        end
        isParam=cell(1,numel(paramsLabel));
        varWksType=cell(1,numel(paramsLabel));
        isComposite=cell(1,numel(paramsLabel));
        for j=1:length(paramsLabel)
            isParam{j}=strcmp(bindableParams(j).WksType,'');
            varWksType{j}=bindableParams(j).WksType;

            if~isParam{j}
                paramsLabel{j}=bindableParams(j).VarName;
            end
            if ismethod(bindableParams(j),'getValue')
                value=bindableParams(j).getValue;
                isComposite{j}=isstruct(value)||~isscalar(value);
            else
                isComposite{j}=false;
            end
        end
        if~isempty(isParam)
            tpStruct.blockNames{end+1}=get_param(selectionHandles(i),'Name');
            tpStruct.blockHandles{end+1}=selectionHandles(i);
            tpStruct.allParams{end+1}=paramsLabel;
            tpStruct.allVarWorkspaceType{end+1}=varWksType;
            tpStruct.allIsParams{end+1}=isParam;
            tpStruct.allIsComposite{end+1}=isComposite;
        end
        if(bUpdateDiagramNeeded)
            tpStruct.bUpdateDiagramNeeded=true;
        end
    end


    totalNumRows=0;
    for idx=1:numel(tpStruct.blockNames)
        params=tpStruct.allParams{idx};
        for k=1:numel(params)
            totalNumRows=totalNumRows+1;
        end
    end


    connectionStatus=cell(1,totalNumRows);
    bindableType=cell(1,totalNumRows);
    bindableName=cell(1,totalNumRows);
    paramName=cell(1,totalNumRows);
    blockHandle=cell(1,totalNumRows);
    varWorkspaceType=cell(1,totalNumRows);
    paramIsComposite=cell(1,totalNumRows);



    rowCount=1;
    for idx=1:numel(tpStruct.blockNames)
        params=tpStruct.allParams{idx};
        isParams=tpStruct.allIsParams{idx};
        workspaceType=tpStruct.allVarWorkspaceType{idx};
        isComposite=tpStruct.allIsComposite{idx};
        for k=1:numel(params)
            connectionStatus{rowCount}=false;
            blockHandle{rowCount}=tpStruct.blockHandles{idx};
            if(isParams{k})
                bindableType{rowCount}=BindMode.BindableTypeEnum.SLPARAMETER;
                bindableName{rowCount}=[tpStruct.blockNames{idx},':',params{k}];
                paramName{rowCount}=params{k};
                varWorkspaceType{rowCount}='';
            else
                bindableType{rowCount}=BindMode.BindableTypeEnum.VARIABLE;
                bindableName{rowCount}=params{k};
                paramName{rowCount}=params{k};
                varWorkspaceType{rowCount}=workspaceType{k};
            end
            paramIsComposite{rowCount}=isComposite{k};
            rowCount=rowCount+1;
        end
    end


    numRows=numel(connectionStatus);
    selectionRows=cell(1,numRows);
    seenVariables={};
    for idx=1:numRows
        if(bindableType{idx}==BindMode.BindableTypeEnum.SLPARAMETER)
            metaData=BindMode.SLParamMetaData(paramName{idx},...
            getfullname(blockHandle{idx}),...
            paramIsComposite{idx});
            selectionRows{idx}=BindMode.BindableRow(connectionStatus{idx},BindMode.BindableTypeEnum.SLPARAMETER,...
            bindableName{idx},metaData);
        elseif(bindableType{idx}==BindMode.BindableTypeEnum.VARIABLE)
            metaData=BindMode.VariableMetaData(paramName{idx},...
            BindMode.VarWorkspaceTypeEnum.getEnumTypeFromStr(varWorkspaceType{idx}),...
            getfullname(blockHandle{idx}),...
            paramIsComposite{idx});
            variableRow=BindMode.BindableRow(connectionStatus{idx},BindMode.BindableTypeEnum.VARIABLE,...
            bindableName{idx},metaData);
            exclude=false;
            if(numel(seenVariables)>0)



                for varCount=1:numel(seenVariables)
                    if(strcmp(variableRow.bindableMetaData.name,seenVariables{varCount}.bindableMetaData.name)&&...
                        variableRow.bindableMetaData.workspaceType==seenVariables{varCount}.bindableMetaData.workspaceType)
                        exclude=true;
                        break;
                    end
                end
            end
            if(exclude)
                selectionRows{idx}=[];
            else
                seenVariables{end+1}=variableRow;
                selectionRows{idx}=variableRow;
            end
        end
    end
    selectionRows=selectionRows(~cellfun('isempty',selectionRows));
    updateDiagramNeeded=tpStruct.bUpdateDiagramNeeded;
end