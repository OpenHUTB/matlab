function runTimeOptions=convertQuadprogOptionsForSolver(options,nVar,mConstr)





%#codegen


    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(options,nVar,mConstr);
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mConstr,{coder.internal.indexIntClass},{'scalar'});

    defaultIterations=coder.internal.indexInt(10*(nVar+mConstr));


    runTimeOptions=struct();
    runTimeOptions.MaxIterations=coder.internal.indexInt(options.MaxIterations);
    runTimeOptions.ConstrRelTolFactor=1.0;
    runTimeOptions.ProbRelTolFactor=1.0;
    runTimeOptions.RemainFeasible=false;



    if(runTimeOptions.MaxIterations<0)
        runTimeOptions.MaxIterations=defaultIterations;
    end

end