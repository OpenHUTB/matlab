function subsystemBlock(obj)


    modelNameNoPath=obj.modelName;
    import slexportprevious.utils.findBlockType;

    if isR2021bOrEarlier(obj.ver)
        ssBlks=findBlockType(modelNameNoPath,'SubSystem','ShowSubsystemReinitializePorts','on');
        for i=1:length(ssBlks)
            blk=ssBlks{i};
            locDeleteReinitLines(blk);
        end
    end
end

function locDeleteReinitLines(block)
    lh=get_param(block,'LineHandles');
    eventLines=lh.Event;
    for i=1:numel(eventLines)
        line=eventLines(i);
        if ishandle(line)
            delete_line(line);
        end
    end
end
