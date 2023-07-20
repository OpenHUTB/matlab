function counterComp=getCounterFreeRunningComp(hN,hOutSignal,compName)




    if(nargin<3)
        compName='counter';
    end


    counterComp=pircore.getCounterFreeRunningComp(hN,hOutSignal,compName);

end


