function btvComp=getBustoVectorComp(hN,hInSignals,hOutSignal,compName,slhandle)



    narginchk(3,5);
    if nargin<5
        slhandle=-1;
    end
    if nargin<4
        compName='bus_to_vector';
    end

    btvComp=pircore.getBustoVectorComp(hN,hInSignals,hOutSignal,compName,slhandle);
end

