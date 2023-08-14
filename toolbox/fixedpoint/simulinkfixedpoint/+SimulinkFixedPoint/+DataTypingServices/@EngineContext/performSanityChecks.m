function performSanityChecks(this)









    if~isequal(class(this.action),'SimulinkFixedPoint.DataTypingServices.EngineActions')
        DAStudio.error(this.invalidActionMessageID);
    end



    sudObject=get_param(this.systemUnderDesign,'Object');
    if~isa(sudObject,'Simulink.BlockDiagram')&&~isa(sudObject,'Simulink.SubSystem')
        DAStudio.error(this.invalidSUDMessageID);
    end

end
