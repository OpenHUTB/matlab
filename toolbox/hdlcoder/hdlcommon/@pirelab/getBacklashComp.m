function blComp=getBacklashComp(hN,hInSignals,hOutSignals,backlashWidth,initialOutput,name)



    if(nargin<6)
        name='backlash';
    end

    blComp=pircore.getBacklashComp(hN,hInSignals,hOutSignals,backlashWidth,initialOutput,name);
end
