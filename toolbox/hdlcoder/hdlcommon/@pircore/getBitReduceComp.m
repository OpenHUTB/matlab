function cgirComp=getBitReduceComp(hN,hInSignals,hOutSignals,opName,compName)







    if(nargin<5)
        compName='bitreduce';
    end


    cgirComp=hN.addComponent2(...
    'kind','bitreduce_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'Mode',opName);


end


