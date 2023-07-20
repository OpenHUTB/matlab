function emit(obj,rpt,type,template)
    import mlreportgen.dom.*;
    chapter=DocumentPart(type,template);
    tableData=obj.getTableData(false);
    t=Table([[DAStudio.message('RTW:report:ReducedBlocksTableColumnBlock');tableData(:,1)],[DAStudio.message('RTW:report:ReducedBlocksTableColumnDescription');tableData(:,2)]],'TableStyleAltRow');
    while~strcmp(chapter.CurrentHoleId,'#end#')
        switch chapter.CurrentHoleId
        case 'ReducedBlocks'
            chapter.append(Paragraph(DAStudio.message('RTW:report:ReducedBlocksSummary')));
            chapter.append(t);
        end
        moveToNextHole(chapter);
    end
    rpt.append(chapter);
end
