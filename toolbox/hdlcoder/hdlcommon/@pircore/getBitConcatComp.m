function cgirComp=getBitConcatComp(hN,hInSignals,hOutSignals,compName)







    if(nargin<4)
        compName='concat';
    end


    cgirComp=hN.addComponent2(...
    'kind','bitconcat_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals);


end


