function typeHiliteInfo=getTaskHiliteInfo(taskNode,legendObj,mode)

    blks=[];
    taskBlockMap=get_param(bdroot,'taskIDToNonVirtualBlockMap');
    index=cellfun(@(x)isequal(x,taskNode.taskIdx),{taskBlockMap.taskIdx});

    if(~isempty(index)&&~isempty(taskBlockMap(index)))
        blks=cell2mat({taskBlockMap(index).AllBlocks.Path});
    end

    if(isempty(taskNode.mRateSet))
        typeHiliteInfo=[];
        return;
    else
        typeHiliteInfo=legendObj.rateHighlight({'rate',num2str(taskNode.mRateSet(1).TID),taskNode.mRateSet(1).mModelName,mode});
    end

    for rateIdx=2:length(taskNode.mRateSet)
        typeHiliteInfoTemp=legendObj.rateHighlight({'rate',num2str(taskNode.mRateSet(rateIdx).TID),taskNode.mRateSet(rateIdx).mModelName,mode});
        typeHiliteInfo.hilitePathSet=[typeHiliteInfo.hilitePathSet,typeHiliteInfoTemp.hilitePathSet];
        typeHiliteInfo.Annotation=[typeHiliteInfo.Annotation,typeHiliteInfoTemp.Annotation];
    end

    typeHiliteInfo.hilitePathSet=unique([typeHiliteInfo.hilitePathSet,blks]);
    typeHiliteInfo.hilitePathSet=typeHiliteInfo.hilitePathSet(typeHiliteInfo.hilitePathSet~=0);

    typeHiliteInfo.colorRGB=[0.851,0.644,0.125];
    typeHiliteInfo.Value=[1000,1000];