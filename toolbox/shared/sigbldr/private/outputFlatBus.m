function UD=outputFlatBus(UD)







    if isfield(UD,'simulink')&&~isempty(UD.simulink)
        UD.simulink=sigbuilder_block('output_FlatBus',UD.simulink);
        UD=update_undo(UD,'outputFlatBus','channel',[],[]);


        outputPortsMenuH=UD.menus.figmenu.SignalMenuOutputPorts;
        set(outputPortsMenuH,'Enable','on');
        outputFlatBusMenuH=UD.menus.figmenu.SignalMenuOutputFlatBus;
        set(outputFlatBusMenuH,'Enable','off');
    end
