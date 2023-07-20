function[x,fval,exitflag,output,lambda]=callGlobalSolver(prob,probStruct)










    if isa(probStruct.globalSolver,'MultiStart')
        [x,fval,exitflag,output,sols]=runMultiStart(prob,probStruct);
    else
        [x,fval,exitflag,output,sols]=run(probStruct.globalSolver,probStruct);
    end


    output=addLocalSolutions2OutputStructure(prob,output,sols);



    output.objectiveDerivative=probStruct.objectiveDerivative;
    if isfield(probStruct,'constraintDerivative')
        output.constraintDerivative=probStruct.constraintDerivative;
    end


    output.globalSolver=class(probStruct.globalSolver);


    lambda=[];


    fval=fval+probStruct.f0;

end

function[x,fval,exitflag,output,sols]=runMultiStart(prob,probStruct)


    numVars=sum(structfun(@numel,prob.Variables));
    numPts=numel(probStruct.x0)/numVars;




    startPoints{1}=CustomStartPointSet(probStruct.x0');


    numExtraPts=probStruct.minNumStartPoints-numPts;
    if numExtraPts>0
        startPoints{2}=RandomStartPointSet("NumStartPoints",numExtraPts);
    end


    probStruct.x0=probStruct.x0(:,1);


    [x,fval,exitflag,output,sols]=run(probStruct.globalSolver,probStruct,startPoints);

end

function output=addLocalSolutions2OutputStructure(prob,output,sols)


    numLocalSolutions=numel(sols);



    cellX=cell(1,numLocalSolutions);
    [cellX{:}]=deal(sols.X);
    cellX=cellfun(@(x)x(:),cellX,'UniformOutput',false);
    allX=[cellX{:}]';
    allFval=[sols.Fval]';
    output.local.sol=optim.problemdef.OptimizationValues.createFromSolverBased(prob,allX,allFval);


    cellX0=cell(1,numLocalSolutions);
    for i=1:numLocalSolutions
        thisX0=sols(i).X0;
        thisX0=cellfun(@(x)x(:),thisX0,'UniformOutput',false);
        allthisX0=[thisX0{:}]';
        cellX0{i}=optim.problemdef.OptimizationValues.createFromSolverBased(prob,allthisX0);
    end
    output.local.x0=cellX0;


    output.local.exitflag=[sols.Exitflag];
    output.local.output=[sols.Output];

end