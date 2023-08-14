



function allInportHandles=getAllInportHandles(portHandles)

    Inport=portHandles.Inport;
    Enable=portHandles.Enable;
    Trigger=portHandles.Trigger;


    Ifaction=portHandles.Ifaction;
    Reset=portHandles.Reset;
    Event=portHandles.Event;
    allInportHandles=[Inport,Enable,Trigger,Ifaction,Reset,Event];
end