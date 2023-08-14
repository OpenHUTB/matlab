function muxComp=getBusSelectorComp(hN,hInSignals,hOutSignal,indexStr,outputIsBus,compName)



    if nargin<6
        compName='bus_selector';
    end

    if nargin<5
        outputIsBus=false;
    end

    muxComp=pircore.getBusSelectorComp(hN,hInSignals,hOutSignal,indexStr,outputIsBus,compName);

end

