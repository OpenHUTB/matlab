function cgirComp=getBitExtractComp(hN,hInSignals,hOutSignals,ul,ll,mode,compName)








    if(nargin<7)
        compName='extract';
    end


    cgirComp=hN.addComponent2(...
    'kind','bitextract_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'UpperLimit',ul,...
    'LowerLimit',ll,...
    'TreatAsInteger',mode);


end


