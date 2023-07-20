function appendRptgenReuseExceptions(obj,chapter)
    import mlreportgen.dom.*
    diagInfo=obj.ReuseDiag;
    for i=1:length(diagInfo)
        if isempty(diagInfo(i).Blockers)
            continue
        end
        if isempty(diagInfo(i).BlockSID)
            continue
        end
        nl=sprintf('\n');
        nameCol=sprintf('<S%d>',diagInfo(i).SystemID);
        currStr=[DAStudio.message('RTW:report:ReuseExceptionReason',nameCol),nl];
        chapter.append(Paragraph(Text(currStr)));
        if~isempty(diagInfo(i).Blockers)
            aList=UnorderedList;
            for k=1:length(diagInfo(i).Blockers)
                blk=getfullname(diagInfo(i).Blockers(k).SrcBlock);
                aList.append(ListItem([diagInfo(i).Blockers(k).Reason,' [',blk,']']));
            end
            chapter.append(aList);
        end
    end
end
