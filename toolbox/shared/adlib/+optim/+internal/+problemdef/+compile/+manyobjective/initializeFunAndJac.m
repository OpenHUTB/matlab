function[idxVector,compiledEqnFun,compiledEqJac,extraParams,probStruct]=...
    initializeFunAndJac(prob,numEquations,idxEquations,sizeOfEquations,...
    objValue,gradientValue,probStruct)









    NumEq=numEquations.Linear+numEquations.Quadratic+numEquations.Nonlinear;
    NumArrayEq=numel(idxEquations.Linear)+numel(idxEquations.Quadratic)+numel(idxEquations.Nonlinear);
    JacobianRequired=isa(prob,'optim.problemdef.EquationProblem');

    if NumArrayEq>1
        idxVector=optim.internal.problemdef.compile.createStartEndIndexVectors(...
        sizeOfEquations);
        compiledEqnFun=objValue+" = zeros("+NumEq+", 1);"+newline;
        if JacobianRequired
            compiledEqJac=gradientValue+" = zeros("+NumEq+", "+probStruct.NumVars+");"+newline;
        else
            compiledEqJac=gradientValue+" = zeros("+probStruct.NumVars+", "+NumEq+");"+newline;
        end
    else
        idxVector=[];
        compiledEqnFun="";
        compiledEqJac="";
    end


    extraParams={};


    probStruct.f0=0;



