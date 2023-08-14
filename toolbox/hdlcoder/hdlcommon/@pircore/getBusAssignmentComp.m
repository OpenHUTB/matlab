function bassignComp=getBusAssignmentComp(hN,hInSignals,hOutSignal,assignedSignals,compName)



    if nargin<5
        compName='bus_assignment';
    end

    bassignComp=hN.addComponent2(...
    'kind','busassignment_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignal,...
    'AssignedSignals',assignedSignals);

end

