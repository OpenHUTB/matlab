function[augSysSolutionPrimal,augSysSolutionDual]=solveAugSystem(AugFactor,...
    rhs1,rhs2,rhs3,rhs4,slacks,sizes)












    nVar=sizes.nVar;mEq=sizes.mEq;
    mIneq=sizes.mIneq;nPrimal=sizes.nPrimal;


    augSysSolutionPrimal=zeros(nPrimal,1);

    if isfield(AugFactor,'FeasibilityStep')&&AugFactor.FeasibilityStep
        [augSysSolutionPrimal,augSysSolutionDual]=solveFeasSystem(AugFactor,...
        rhs1,rhs2,rhs3,rhs4,slacks);
    else

        compactSysSol=backsolveSys(AugFactor,[rhs1;rhs3;rhs4+slacks.*rhs2]);

        augSysSolutionPrimal(1:nVar)=compactSysSol(1:nVar);
        augSysSolutionPrimal(nVar+1:nPrimal,1)=slacks.*compactSysSol(nVar+mEq+1:nVar+mEq+mIneq,1)+rhs2;
        augSysSolutionDual=compactSysSol(nVar+1:end,1);
    end

