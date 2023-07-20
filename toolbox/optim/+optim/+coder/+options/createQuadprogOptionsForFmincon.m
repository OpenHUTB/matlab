function qpoptions=createQuadprogOptionsForFmincon(options,nVar,mFixed,mIneq,mLB,mUB)





%#codegen


    coder.allowpcode('plain');

    coder.inline('always');
    coder.internal.prefer_const(options,nVar,mFixed,mIneq,mLB,mUB);

    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mFixed,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mLB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mUB,{coder.internal.indexIntClass},{'scalar'});

    qpoptions.SolverName='fmincon';
    qpoptions.MaxIterations=10*max(nVar,mIneq+mLB+mUB+2*mFixed);
    qpoptions.StepTolerance=1e-6;
    qpoptions.OptimalityTolerance=100*eps('double');
    qpoptions.ConstraintTolerance=options.ConstraintTolerance;
    qpoptions.ObjectiveLimit=-coder.internal.inf;
    qpoptions.PricingTolerance=0.0;
    qpoptions.ConstrRelTolFactor=1.0;
    qpoptions.ProbRelTolFactor=1.0;
    qpoptions.RemainFeasible=false;
    qpoptions.IterDisplayQP=false;

end