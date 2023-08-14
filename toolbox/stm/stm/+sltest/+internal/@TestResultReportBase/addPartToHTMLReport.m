function addPartToHTMLReport(obj,outputPath,fileName)










    entries=obj.getArchiveEntries(outputPath,{fileName});
    for entryK=1:length(entries)
        entry=entries(entryK);
        if~strcmp(entry.entry(1),'/')
            entry.entry=['/',entry.entry];
        end

        part=mlreportgen.dom.OPCPart(entry.entry,entry.file);
        part.RelationshipId=sprintf('%s_%d',fileName,entryK);
        package(obj.Doc,part);
    end
end
