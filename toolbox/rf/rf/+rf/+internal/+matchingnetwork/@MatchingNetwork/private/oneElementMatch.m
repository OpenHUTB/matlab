




function[X1,X2]=oneElementMatch(sourceImpedance,loadImpedance)

    X1(1)=inf;X2(1)=(conj(loadImpedance)-sourceImpedance)/(1j);

    X2(2)=0;X1(2)=(conj(loadImpedance)*sourceImpedance)/(sourceImpedance-conj(loadImpedance))/(1j);

end

