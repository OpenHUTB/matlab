function fixGotoFromblocks(obj,mdlRefItem)




    assert(isa(mdlRefItem,'Sldv.xform.RepMdlRefBlkTreeNode'),...
    getString(message('Sldv:xform:BlkReplacer:BlkReplacer:OnlyModelRefsAllowed')));

    modelRefBlkTree=obj.MdlInfo.ModelRefBlkTree;


    topFromGotoInfo=modelRefBlkTree.GotoFromInformation;
    currentFromGotoInfo=mdlRefItem.GotoFromInformation;

    inlinedSSPath=getfullname(mdlRefItem.ReplacementInfo.AfterReplacementH);

    if isempty(topFromGotoInfo)
        for idx=1:length(currentFromGotoInfo)
            bottomGotoFrom=currentFromGotoInfo(idx);
            topFromGotoInfo(end+1)=...
            fixBlockPath(bottomGotoFrom,inlinedSSPath);%#ok<AGROW>
        end
    else
        for idx=1:length(currentFromGotoInfo)
            bottomGotoFrom=currentFromGotoInfo(idx);

            bottomGotoFrom=...
            fixBlockPath(bottomGotoFrom,inlinedSSPath);

            if strcmp(bottomGotoFrom.Scope,'global')

                matchingIndex=strcmp(bottomGotoFrom.Tag,{topFromGotoInfo.Tag});
                if~any(matchingIndex)


                    topFromGotoInfo(end+1)=bottomGotoFrom;%#ok<AGROW>
                else
                    matchedTopGotoFrom=topFromGotoInfo(matchingIndex);
                    numGlobalTagConflicts=nnz(strcmp({matchedTopGotoFrom.Scope},'global'));
                    assert(numGlobalTagConflicts<=1);

                    if numGlobalTagConflicts==1



                        topFromGotoInfo(end+1)=...
                        reTagGotoFromBlocks(bottomGotoFrom,obj.incAndGetTagId,mdlRefItem);%#ok<AGROW>
                    else
                        depthBottom=getModelDepth(bottomGotoFrom);
                        blockMoved=false;
                        for jdx=1:length(matchedTopGotoFrom)
                            if strcmp(matchedTopGotoFrom(jdx).Scope,'scoped')&&...
                                getModelDepth(matchedTopGotoFrom(jdx))<depthBottom
                                topFromGotoInfo(end+1)=...
                                reTagGotoFromBlocks(bottomGotoFrom,obj.incAndGetTagId,mdlRefItem);%#ok<AGROW>
                                blockMoved=true;
                                break;
                            end
                        end
                        if~blockMoved
                            topFromGotoInfo(end+1)=bottomGotoFrom;%#ok<AGROW>
                        end
                    end
                end
            else


                topFromGotoInfo(end+1)=bottomGotoFrom;%#ok<AGROW>
            end
        end
    end


    modelRefBlkTree.GotoFromInformation=topFromGotoInfo;
end

function gotoFromInfo=fixBlockPath(info,inlinedSSPath)
    gotoFromInfo=info;
    hierIdx=strfind(gotoFromInfo.FullPath,'/');
    gotoFromInfo.FullPath=sprintf('%s%s',inlinedSSPath,gotoFromInfo.FullPath(hierIdx(1):end));
    fromBlocks=gotoFromInfo.FromBlocks;
    for idx=1:length(fromBlocks)
        currentFrmBlock=fromBlocks{idx};
        hierIdx=strfind(currentFrmBlock,'/');
        fromBlocks{idx}=...
        sprintf('%s%s',inlinedSSPath,currentFrmBlock(hierIdx(1):end));
    end
    gotoFromInfo.FromBlocks=fromBlocks;
end

function gotoFromInfo=reTagGotoFromBlocks(info,tagId,mdlRefItem)
    gotoFromInfo=info;
    gotoFromInfo.Tag=sprintf('globalDVGOTOTAG%d',tagId);
    Sldv.xform.BlkReplacer.breakLibraryLinks(gotoFromInfo.FullPath,mdlRefItem);
    set_param(gotoFromInfo.FullPath,'GotoTag',gotoFromInfo.Tag);
    fromBlocks=gotoFromInfo.FromBlocks;
    for idx=1:length(fromBlocks)
        Sldv.xform.BlkReplacer.breakLibraryLinks(fromBlocks{idx},mdlRefItem);
        set_param(fromBlocks{idx},'GotoTag',gotoFromInfo.Tag);
    end
end

function depth=getModelDepth(info)
    currentBlk=info.FullPath;
    depth=0;
    while~strcmp(get_param(currentBlk,'type'),'block_diagram')
        currentBlk=get_param(currentBlk,'Parent');
        depth=depth+1;
    end
end