function obj=getGridDialog(model,blockH)





    modelH=get_param(model,'handle');
    blockPath=getfullname(blockH);

    blockPathMod=strrep(blockPath,'/','_');
    if Simulink.BlockDiagramAssociatedData.isRegistered(modelH,blockPathMod)

        obj=Simulink.BlockDiagramAssociatedData.get(modelH,blockPathMod);
    else


        obj=Simulink.record.internal.CustomGridDialog(model,blockH);
        Simulink.BlockDiagramAssociatedData.register(modelH,blockPathMod,'any');
        Simulink.BlockDiagramAssociatedData.set(modelH,blockPathMod,obj);
        Simulink.addBlockDiagramCallback(modelH,'PreClose',blockPathMod,...
        @()obj.deleteDialog);
    end

end
