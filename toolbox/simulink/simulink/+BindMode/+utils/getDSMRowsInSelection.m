
function selectionRows=getDSMRowsInSelection(selectionHandles,topModel,varargin)






















    varTypeFilter=[];
    if nargin>2
        varTypeFilter=varargin{1};
    end


    selectionRows=cell(1,numel(selectionHandles));



    if isempty(selectionHandles)
        return;
    end
    currModel=get_param(bdroot(selectionHandles(1)),'Name');
    isSelnInModelRef=~strcmp(currModel,topModel);

    for idx=1:numel(selectionHandles)
        if(selectionHandles(idx)==0)
            continue;
        end
        dsSrcPath='';
        DSMType='';
        type=get_param(selectionHandles(idx),'Type');
        if strcmp(type,'block')
            blkType=get_param(selectionHandles(idx),'BlockType');
            if strcmp(blkType,'DataStoreMemory')
                DSMType='block';
            elseif strcmp(blkType,'DataStoreRead')||strcmp(blkType,'DataStoreWrite')
                dsmHdl=BindMode.utils.getDataStoreHandleFromReadWriteBlock(selectionHandles(idx));
                if isempty(dsmHdl)
                    DSMType='variable';
                else
                    DSMType='block';
                    if isSelnInModelRef
                        dsSrcPath=getfullname(dsmHdl);
                    else
                        selectionHandles(idx)=dsmHdl;
                    end
                end
            end
        end

        if strcmp(DSMType,'block')
            selectionRows{idx}=createDSMRow(selectionHandles(idx),dsSrcPath);
        elseif strcmp(DSMType,'variable')
            vRow=BindMode.utils.getParameterRowsInSelection(selectionHandles(idx),true);

            if~isempty(vRow)
                varType=vRow{1}.bindableMetaData.workspaceTypeStr;
                paramSrcType=BindMode.VarWorkspaceTypeEnum.getEnumTypeFromStr(varType);


                if isempty(varTypeFilter)||any(find(varTypeFilter==paramSrcType))
                    selectionRows{idx}=vRow{1};
                end
            end
        end
    end
    selectionRows=selectionRows(~cellfun('isempty',selectionRows));


    rowIDs=cellfun(@(rw)rw.bindableMetaData.id,selectionRows,'UniformOutput',false);
    [~,uqIdx]=unique(rowIDs);
    selectionRows=selectionRows(uqIdx);
end

function row=createDSMRow(blkH,sourcePath)
    connectStatus=false;
    bindableType=BindMode.BindableTypeEnum.DSM;
    bindableName=get_param(blkH,'DataStoreName');
    selBlockPath=getfullname(blkH);
    bindableMetaData=BindMode.SLDSMMetaData(bindableName,selBlockPath,sourcePath);
    row=BindMode.BindableRow(connectStatus,bindableType,bindableName,bindableMetaData);
end