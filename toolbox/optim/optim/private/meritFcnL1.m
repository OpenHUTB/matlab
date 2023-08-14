function phi=meritFcnL1(funcEvalWellDefined,penaltyParam,fval,cEq,cIneq)














    if funcEvalWellDefined

        violIdx=cIneq<0;
        constrViolationEq=norm(cEq,1);
        constrViolationIneq=norm(cIneq(violIdx),1);

        phi=fval+penaltyParam*(constrViolationEq+constrViolationIneq);
    else


        phi=Inf;
    end
