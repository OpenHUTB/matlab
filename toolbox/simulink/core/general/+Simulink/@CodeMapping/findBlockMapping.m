function out=findBlockMapping(mappings,eventName)




    mapping=[];
    for mappingIdx=1:length(mappings)
        mappingClass=metaclass(mappings(mappingIdx));
        for eventIdx=1:length(mappingClass.EventList)
            if strcmp(mappingClass.EventList(eventIdx).Name,eventName)
                mapping=mappings(mappingIdx);
                break;
            end
        end
    end
    out=mapping;
end
