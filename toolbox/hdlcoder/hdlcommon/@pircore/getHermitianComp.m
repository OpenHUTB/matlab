function hermitian_comp=getHermitianComp(hN,hInSignals,hOutSignals,satMode,compName)




    if(nargin<5)
        compName='hermitian';
    end


    hermitian_comp=hN.addComponent2(...
    'kind','hermitian_comp',...
    'name',compName,...
    'InputSignals',hInSignals(1),...
    'OutputSignals',hOutSignals(1),...
    'SaturationMode',satMode);

end
