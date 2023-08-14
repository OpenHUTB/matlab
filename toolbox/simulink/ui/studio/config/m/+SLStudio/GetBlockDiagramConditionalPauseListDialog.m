function obj=GetBlockDiagramConditionalPauseListDialog(modelH)





    if Simulink.BlockDiagramAssociatedData.isRegistered(modelH,'ConditionalPauseListDialog')

        obj=Simulink.BlockDiagramAssociatedData.get(modelH,'ConditionalPauseListDialog');
    else


        obj=SLStudio.BlockDiagramConditionalPauseListDialog(modelH);
        Simulink.BlockDiagramAssociatedData.register(modelH,'ConditionalPauseListDialog','any');
        Simulink.BlockDiagramAssociatedData.set(modelH,'ConditionalPauseListDialog',obj);
        Simulink.addBlockDiagramCallback(modelH,'PreClose','ConditionalPauseListDialog',...
        @()obj.deleteDialog);
    end

end

