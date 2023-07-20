function res=isBlockMaskOpenable(block)




    if block.isSubsystem
        res=SLStudio.Utils.isSubsystemMaskOpenable(block);
    else
        res=hasmask(block.handle)&&hasmaskdlg(block.handle);
    end
end
