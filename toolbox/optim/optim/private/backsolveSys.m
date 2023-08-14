function sysSolution=backsolveSys(FactorsStruct,rhs)













    p=FactorsStruct.p;
    sysSolution=FactorsStruct.S(:,p)*(FactorsStruct.U\(FactorsStruct.D\...
    (FactorsStruct.U'\(FactorsStruct.S(p,:)*rhs))));



    idx=~isfinite(sysSolution);
    sysSolution(idx)=0.0;
