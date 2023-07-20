function options=solverOptions(solver)









%#codegen


    coder.allowpcode('plain');
    coder.internal.prefer_const(solver);

    validateattributes(solver,{'char'},{'row'});

    options=struct();



    options.InitDamping=1e-2;


    options.FiniteDifferenceType='forward';
    options.SpecifyObjectiveGradient=false;


    options.ScaleProblem=false;
    options.SpecifyConstraintGradient=false;


    options.NonFiniteSupport=true;
    options.IterDisplaySQP=false;



    options.FiniteDifferenceStepSize=-1;
    options.MaxFunctionEvaluations=-1;
    options.TypicalX=[];



    options.IterDisplayQP=false;


    options.PricingTolerance=0.0;









    options.Algorithm=blanks(63);
    options.ObjectiveLimit=-1e20;








    if strcmpi(solver,'fmincon')
        options.ConstraintTolerance=1e-6;
        options.OptimalityTolerance=1e-6;
        options.StepTolerance=1e-6;
        options.MaxIterations=400;


        options.FunctionTolerance=coder.internal.inf;

    elseif strcmpi(solver,'quadprog')||strcmpi(solver,'lsqlin')
        options.ConstraintTolerance=1e-8;
        options.OptimalityTolerance=1e-8;
        options.StepTolerance=1e-8;



        options.MaxIterations=-1;


        options.FunctionTolerance=coder.internal.inf;

    else




        options.ConstraintTolerance=coder.internal.inf;
        options.OptimalityTolerance=coder.internal.inf;


        options.StepTolerance=1e-6;
        options.MaxIterations=400;
        options.FunctionTolerance=1e-6;
    end


    options.SolverName=solver;



    options.CheckGradients=false;
    options.Diagnostics='off';
    options.DiffMaxChange=coder.internal.inf;
    options.DiffMinChange=0.0;
    options.Display='final';
    options.FunValCheck='off';
    options.PlotFcn=[];
    options.OutputFcn=[];
    options.UseParallel=false;


    options.Display='final';
    options.JacobianMultiplyFcn=[];
    options.LinearSolver='auto';
    options.SubproblemAlgorithm='cg';




















end