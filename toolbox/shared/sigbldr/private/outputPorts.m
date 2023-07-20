function UD=outputPorts(UD)







    if isfield(UD,'simulink')&&~isempty(UD.simulink)
        UD.simulink=sigbuilder_block('output_Ports',UD.simulink);
        UD=update_undo(UD,'outputPorts','channel',[],[]);


        outputPortsMenuH=UD.menus.figmenu.SignalMenuOutputPorts;
        set(outputPortsMenuH,'Enable','off');
        outputFlatBusMenuH=UD.menus.figmenu.SignalMenuOutputFlatBus;
        set(outputFlatBusMenuH,'Enable','on');
    end
