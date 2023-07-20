classdef(Sealed)QuadprogWarmStart<optim.coder.warmstart.qpactiveset.LinConstrWarmStart














%#codegen


    methods
        function obj=QuadprogWarmStart(x0,SolverOptions,WarmStartOptions)
            coder.columnMajor;
            coder.allowpcode('plain');

            coder.internal.prefer_const(x0,SolverOptions,WarmStartOptions);

            validateattributes(SolverOptions,{'struct'},{'scalar'});
            validateattributes(WarmStartOptions,{'struct'},{'scalar'});

            obj=obj@optim.coder.warmstart.qpactiveset.LinConstrWarmStart...
            (x0,SolverOptions,WarmStartOptions,'quadprog');
        end

    end

    methods(Hidden)


        function[obj,fval,exitflag,output,lambda]=quadprog(H,f,Aineq,bineq,Aeq,beq,lb,ub,obj)

            coder.internal.prefer_const(H,f,Aineq,bineq,Aeq,beq,lb,ub);

            INT_ONE=coder.internal.indexInt(1);
            nVar=coder.internal.indexInt(numel(obj.X));

            numInputs=nargin();


            coder.internal.errorIf(numInputs<9,'optimlib_codegen:common:TooFewInputs','QUADPROG',9,'active-set');


            coder.internal.errorIf(isempty(H),'optim_codegen:quadprog:NullHessian');
            coder.internal.errorIf(size(H,1)~=nVar,'optim:quadprog:InvalidSizesOfHAndX0');
            coder.internal.errorIf(size(H,1)~=size(H,2),'optim:quadprog:NonSquareHessian');
            coder.internal.errorIf(abs(H(coder.internal.blas.ixamax(numel(H),H,INT_ONE,INT_ONE)))<eps('double'),...
            'optim_codegen:quadprog:NullHessian');
            coder.internal.errorIf(~isempty(f)&&(numel(f)~=size(H,1)),'optim:quadprog:MismatchObjCoefSize');
            optim.coder.validate.checkQuadraticObjective(H,f,'H','f');


            isQuadprog=true;
            [obj,fval,exitflag,output,lambda]=solve(H,f,Aineq,bineq,Aeq,beq,lb,ub,obj,isQuadprog);

        end

    end

end

