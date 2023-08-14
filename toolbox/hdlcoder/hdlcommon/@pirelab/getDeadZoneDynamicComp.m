function deadzoneComp=getDeadZoneDynamicComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='deadzoneDynamic';
    end

    deadzoneComp=pircore.getDeadZoneDynamicComp(hN,hInSignals,hOutSignals,compName);

end


