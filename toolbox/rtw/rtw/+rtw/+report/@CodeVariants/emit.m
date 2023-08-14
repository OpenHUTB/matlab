function emit(obj,rpt,type,template)
    import mlreportgen.dom.*;
    chapter=DocumentPart(type,template);

    objectTable=obj.variantObjectTable(true);

    modelBlockTable=obj.variantModelBlockTable('ModelReference','Model Block','Model',true);

    subsystemBlockTable=obj.variantModelBlockTable('SubSystem','Subsystem Block','Subsystem',true);
    while~strcmp(chapter.CurrentHoleId,'#end#')
        switch chapter.CurrentHoleId
        case 'VariantControl'
            chapter.append(objectTable);
        case 'ModelRef'
            chapter.append(modelBlockTable);
        case 'Subsystems'
            chapter.append(subsystemBlockTable);
        end
        moveToNextHole(chapter);
    end
    rpt.append(chapter);
end
