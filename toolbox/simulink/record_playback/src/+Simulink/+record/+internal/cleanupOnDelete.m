function cleanupOnDelete(blockH,model)




    modelH=get_param(model,'handle');
    blockPath=getfullname(blockH);

    blockPathMod=strrep(blockPath,'/','_');

    if Simulink.BlockDiagramAssociatedData.isRegistered(modelH,blockPathMod)

        obj=Simulink.BlockDiagramAssociatedData.get(modelH,blockPathMod);
        obj.deleteDialog();
        Simulink.removeBlockDiagramCallback(modelH,'PreClose',blockPathMod);
        Simulink.BlockDiagramAssociatedData.unregister(modelH,blockPathMod);
    end

end



