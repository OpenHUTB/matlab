function newComp=elaborate(~,hN,hC)


    compName=get_param(hC.SimulinkHandle,'Name');

    if(strcmp(get_param(hC.SimulinkHandle,'BlockType'),'Terminator'))
        newComp=pirelab.getNilComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
        compName,'',-1);
    else
        assignedSignals=get_param(hC.SimulinkHandle,'assignedSignals');
        newComp=pirelab.getBusAssignmentComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
        assignedSignals);
    end

end
