function conj_comp=getComplexConjugateComp(hN,slbh,hInSignals,hOutSignals,satMode,compName,rndMode)




    if(nargin<7)
        rndMode='Floor';
    end

    if(nargin<6)
        compName='conj';
    end

    if(nargin<5)
        satMode='Saturate';
    end

    narginchk(4,7);


    conj_comp=hN.addComponent2(...
    'kind','complex_conjugate_comp',...
    'SimulinkHandle',slbh,...
    'name',compName,...
    'InputSignals',hInSignals(1),...
    'OutputSignals',hOutSignals(1),...
    'RoundingMode',rndMode,...
    'SaturationMode',satMode);
end