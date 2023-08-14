function muxComp=getBusCreatorComp(hN,hInSignals,hOutSignal,busTypeStr,nonVirtualBus,compName)


    narginchk(5,6);
    if nargin<6
        compName='bus_creator';
    end

    muxComp=pircore.getBusCreatorComp(hN,hInSignals,hOutSignal,busTypeStr,nonVirtualBus,compName);
end
