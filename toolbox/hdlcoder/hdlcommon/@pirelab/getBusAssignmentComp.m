function bassignComp=getBusAssignmentComp(hN,hInSignals,hOutSignal,assignedSignals,compName)



    if nargin<5
        compName='bus_assignment';
    end

    bassignComp=pircore.getBusAssignmentComp(hN,hInSignals,hOutSignal,assignedSignals,compName);

end

