function[cEq_all,cIneq_all]=formConstraints(xCurrent,xIndices,Aeq,beq,Ain,bin,lb,ub,cEq,cIneq)












    cEq_all=[Aeq*xCurrent-beq
    xCurrent(xIndices.fixed)-lb(xIndices.fixed)
    cEq];



    cIneq_all=[Ain*xCurrent-bin
    xCurrent(xIndices.finiteLb)-lb(xIndices.finiteLb)
    ub(xIndices.finiteUb)-xCurrent(xIndices.finiteUb)
    cIneq];

