function counterComp=getCounterFreeRunningComp(hN,hOutSignals,compName)




    if(nargin<3)
        compName='counter';
    end

    counterComp=hN.addComponent2(...
    'kind','counterfreerunning_comp',...
    'Name',compName,...
    'InputSignals',[],...
    'OutputSignals',hOutSignals);

end


