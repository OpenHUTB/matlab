function typeHiliteInfo=getTypeHiliteInfo(typeNode,legendObj,mode)












    if(isempty(typeNode.mRateSet))
        typeHiliteInfo=[];
        return;
    end

    nRate=length(typeNode.mRateSet);
    tmpHiliteInfo=cell(nRate,1);

    for rateIdx=1:nRate
        if(isempty(typeNode.mRateSet(rateIdx).TID))
            tmpHiliteInfo{rateIdx}=legendObj.rateHighlight({'rate','M',...
            typeNode.mRateSet(rateIdx).mModelName,mode});
        else
            tmpHiliteInfo{rateIdx}=legendObj.rateHighlight({'rate',num2str(typeNode.mRateSet(rateIdx).TID),...
            typeNode.mRateSet(rateIdx).mModelName,mode});
        end
    end

    typeHiliteInfo=tmpHiliteInfo{1};
    tmpHiliteInfo=cell2mat(tmpHiliteInfo);

    typeHiliteInfo.hilitePathSet=[tmpHiliteInfo(:).hilitePathSet];
    typeHiliteInfo.Annotation=[tmpHiliteInfo(:).Annotation];

    typeHiliteInfo.colorRGB=[-1,-1,-1];
    typeHiliteInfo.Value=[1000,1000];
end
