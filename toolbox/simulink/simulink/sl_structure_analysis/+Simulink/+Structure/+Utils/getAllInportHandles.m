


function allInportHandles=getAllInportHandles(portHandles)

    Inport=portHandles.Inport;
    Enable=portHandles.Enable;
    Trigger=portHandles.Trigger;

    Ifaction=portHandles.Ifaction;
    Reset=portHandles.Reset;

    allInportHandles=[Inport,Enable,Trigger,Ifaction,Reset];
end
