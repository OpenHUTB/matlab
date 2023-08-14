function dzComp=getDeadZoneComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,name)



    if(nargin<6)
        name='deadzone';
    end

    dzComp=pircore.getDeadZoneComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,name);
end
