function prelookInterpNDBlock(obj)



    blkType='Interpolation_n-D';

    if isR2016aOrEarlier(obj.ver)

        blksInterp=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if~isempty(blksInterp)
            for i=1:length(blksInterp)
                blk=blksInterp{i};

                if strcmp(get_param(blk,'RequireIndexFractionAsBus'),'on')
                    obj.replaceWithEmptySubsystem(blk);
                end
            end
        end
    end

    if isR2010bOrEarlier(obj.ver)


        blksInterp=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if~isempty(blksInterp)
            for i=1:length(blksInterp)
                blk=blksInterp{i};
                remove_value=get_param(blk,'RemoveProtectionIndex');
                if strcmp(remove_value,'on')
                    set_param(blk,'RemoveProtectionIndex','off');
                else
                    set_param(blk,'RemoveProtectionIndex','on');
                end
            end
        end
    end


