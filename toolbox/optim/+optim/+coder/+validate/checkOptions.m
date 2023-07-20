function checkOptions(options,solver,algorithm)













%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(options,solver,algorithm);

    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(solver,{'char'},{'vector'});
    validateattributes(algorithm,{'char'},{'vector'});


    OPTIMOPTIONS_FIELDNAME='SolverName';


    coder.internal.assert(isfield(options,OPTIMOPTIONS_FIELDNAME),...
    'optimlib_codegen:common:OnlyOptimoptionsSupported');

    coder.internal.assert(strcmp(options.SolverName,solver),...
    'optimlib_codegen:optimoptions:InvalidSolverOptions',solver);

    coder.internal.assert(strcmp(options.Algorithm,algorithm),...
    'optimlib_codegen:optimoptions:InvalidType','Algorithm',solver,[char(13),sprintf('''%s''',algorithm)]);



end

