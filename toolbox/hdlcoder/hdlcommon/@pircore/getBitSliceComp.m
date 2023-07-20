function cgirComp=getBitSliceComp(hN,hInSignals,hOutSignals,msbPos,lsbPos,compName)







    if(nargin<6)
        compName='slice';
    end


    cgirComp=hN.addComponent2(...
    'kind','bitslice_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'LeftIndex',msbPos,...
    'RightIndex',lsbPos);


end


