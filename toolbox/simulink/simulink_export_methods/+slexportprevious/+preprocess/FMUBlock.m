function FMUBlock(obj)



    if isR2020bOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|FMU><FMUCreateBusObject:remove>>');
        obj.appendRule('<Block<BlockType|FMU><FMUInternalMapping:remove>>');
        obj.appendRule('<Block<BlockType|FMU><FMUInputVisibility:remove>>');
        obj.appendRule('<Block<BlockType|FMU><FMUOutputVisibility:remove>>');
        obj.appendRule('<Block<BlockType|FMU><FMUInternalNameVisibilityList:remove>>');
        obj.appendRule('<Block<BlockType|FMU><FMUInputAlteredNameStartMap:remove>>');
    end

    if isR2017aOrEarlier(obj.ver)
        FMUBlks=slexportprevious.utils.findBlockType(obj.modelName,'FMU');

        for i=1:length(FMUBlks)
            blk=FMUBlks{i};
            obj.replaceWithEmptySubsystem(blk);

            sldiagviewer.reportWarning(MException(message('Simulink:ExportPrevious:FMUBlockRemoved',blk,obj.origModelName)));
        end

    end

end
