function transpose_comp=getTransposeComp(hN,hInSignals,hOutSignals,compName)




    if(nargin<4)
        compName='transpose';
    end


    transpose_comp=hN.addComponent2(...
    'kind','transpose_comp',...
    'name',compName,...
    'InputSignals',hInSignals(1),...
    'OutputSignals',hOutSignals(1));

end
