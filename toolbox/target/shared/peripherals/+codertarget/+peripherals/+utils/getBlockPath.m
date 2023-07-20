function BlockPath=getBlockPath(BlockID)




    if~contains(BlockID,':')
        BlockID=regexprep(BlockID,'(^.*)(_)(\d+)$','$1:$3');
    end
    validBlock=false;
    if~isempty(BlockID)
        try
            validBlock=Simulink.ID.isValid(BlockID);
            BlockPath=Simulink.ID.getFullName(BlockID);
            if validBlock&&isequal(BlockPath,codertarget.utils.getModelForBlock(BlockPath))
                validBlock=false;
            end
        catch exc %#ok<NASGU>
            validBlock=false;
        end
    end

    if~validBlock
        BlockPath='';
    end
end
