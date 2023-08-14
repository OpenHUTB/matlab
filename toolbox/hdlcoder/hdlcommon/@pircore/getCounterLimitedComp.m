function ctrComp=getCounterLimitedComp(hN,hOutSignals,count_limit,compName)



    if nargin<4
        compName='counter';
    end

    ctrComp=hN.addComponent2(...
    'kind','counterlimited_comp',...
    'Name',compName,...
    'InputSignals',[],...
    'OutputSignals',hOutSignals,...
    'UpperLimit',count_limit);

end
