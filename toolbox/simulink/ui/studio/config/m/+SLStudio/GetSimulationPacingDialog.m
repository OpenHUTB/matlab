function obj=GetSimulationPacingDialog(modelH)






    if Simulink.BlockDiagramAssociatedData.isRegistered(modelH,'SimulationPacingDialog')

        obj=Simulink.BlockDiagramAssociatedData.get(modelH,'SimulationPacingDialog');
    else


        obj=SLStudio.SimulationPacingDialog(modelH);
        Simulink.BlockDiagramAssociatedData.register(modelH,'SimulationPacingDialog','any');
        Simulink.BlockDiagramAssociatedData.set(modelH,'SimulationPacingDialog',obj);
        Simulink.addBlockDiagramCallback(modelH,'PreClose','SimulationPacingDialog',...
        @()obj.deleteDialog);
    end

end
