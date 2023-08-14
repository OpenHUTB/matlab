function out=getReferenceBlocksWithLink(modelOwnerName)




    out=[];
    reqData=slreq.data.ReqData.getInstance;
    [libList,~,copyFromMap]=rmisl.getLoadedLibraries(modelOwnerName);

    for index=1:length(libList)
        cLib=libList{index};
        if dig.isProductInstalled('Simulink')&&bdIsLoaded(cLib)
            cLinkSet=reqData.getLinkSet(get_param(cLib,'FileName'));
            if~isempty(cLinkSet)
                linkedItems=cLinkSet.getLinkedItems();
                for i=1:length(linkedItems)
                    cLinkedItem=linkedItems(i);
                    [isSf,libObjH]=rmi.resolveobj([cLib,cLinkedItem.id]);
                    if~isempty(libObjH)
                        if isSf
                            out=[out;libObjH];%#ok<AGROW>
                        else
                            libBlkName=getfullname(libObjH);
                            if isKey(copyFromMap,libBlkName)
                                referenceBlocks=copyFromMap(libBlkName);
                            else
                                referenceBlocks=[];
                            end
                            out=[out;referenceBlocks];%#ok<AGROW>
                        end

                    end
                end
            end
        end
    end
end



