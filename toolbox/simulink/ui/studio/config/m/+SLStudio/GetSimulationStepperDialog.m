function obj=GetSimulationStepperDialog(modelH)







    if Simulink.BlockDiagramAssociatedData.isRegistered(modelH,'SimulationStepperDialog')

        obj=Simulink.BlockDiagramAssociatedData.get(modelH,'SimulationStepperDialog');
    else


        obj=SLStudio.SimulationStepperDialog(modelH);
        Simulink.BlockDiagramAssociatedData.register(modelH,'SimulationStepperDialog','any');
        Simulink.BlockDiagramAssociatedData.set(modelH,'SimulationStepperDialog',obj);
        Simulink.addBlockDiagramCallback(modelH,'PreClose','SimulationStepperDialog',...
        @()obj.deleteDialog);
    end

end
