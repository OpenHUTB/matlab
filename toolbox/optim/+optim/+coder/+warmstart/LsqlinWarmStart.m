classdef(Sealed)LsqlinWarmStart<optim.coder.warmstart.qpactiveset.LinConstrWarmStart














%#codegen


    methods
        function obj=LsqlinWarmStart(x0,SolverOptions,WarmStartOptions)
            coder.columnMajor;
            coder.allowpcode('plain');

            coder.internal.prefer_const(x0,SolverOptions,WarmStartOptions);

            validateattributes(SolverOptions,{'struct'},{'scalar'});
            validateattributes(WarmStartOptions,{'struct'},{'scalar'});

            obj=obj@optim.coder.warmstart.qpactiveset.LinConstrWarmStart...
            (x0,SolverOptions,WarmStartOptions,'lsqlin');
        end

    end

    methods(Hidden)


        function[obj,resnorm,residual,exitflag,output,lambda]=lsqlin(C,d,Aineq,bineq,Aeq,beq,lb,ub,obj)

            coder.internal.prefer_const(C,d,Aineq,bineq,Aeq,beq,lb,ub);

            INT_ONE=coder.internal.indexInt(1);
            numInputs=nargin();
            numOutputs=nargout();



            coder.internal.errorIf(numInputs<9,'optimlib_codegen:common:TooFewInputs','LSQLIN',9,'active-set');


            optim.coder.validate.checkQuadraticObjective(C,d,'C','d');


            coder.internal.errorIf(isempty(C),'optim_codegen:lsqlin:NullCMatrix');


            coder.internal.errorIf(abs(C(coder.internal.blas.ixamax(numel(C),C,INT_ONE,INT_ONE)))<eps('double'),...
            'optim_codegen:lsqlin:NullCMatrix');


            coder.internal.errorIf(~isempty(d)&&(numel(d)~=size(C,1)),'optimlib:lsqlin:InvalidCAndD');

            coder.internal.errorIf(size(C,2)~=numel(obj.X),'optim_codegen:lsqlin:InvalidSizesOfCAndX0');




            C_rows=coder.internal.indexInt(size(C,1));
            C_cols=coder.internal.indexInt(size(C,2));


            H=coder.nullcopy(realmax*ones(C_cols,C_cols,'double'));
            H=coder.internal.blas.xgemm('T','N',C_cols,C_cols,C_rows,...
            1.0,C,INT_ONE,C_rows,C,INT_ONE,C_rows,0.0,H,INT_ONE,C_cols);


            f=coder.nullcopy(realmax*ones(C_cols,1,'double'));
            f=coder.internal.blas.xgemv('T',C_rows,C_cols,...
            -1.0,C,INT_ONE,C_rows,d,INT_ONE,INT_ONE,0.0,f,INT_ONE,INT_ONE);


            isQuadprog=false;
            [obj,~,exitflag,output,lambda]=solve(H,f,Aineq,bineq,Aeq,beq,lb,ub,obj,isQuadprog);

            if(numOutputs>=2)
                [residual,resnorm,obj]=getResiduals(obj,C,d);
            end
        end
    end

    methods(Access=private)

        function[residual,resnorm,obj]=getResiduals(obj,C,d)
            validateattributes(C,{'double'},{'2d'});
            validateattributes(d,{'double'},{'2d'});
            coder.inline('always');

            INT_ONE=coder.internal.indexInt(1);
            C_rows=coder.internal.indexInt(size(C,1));
            C_cols=coder.internal.indexInt(size(C,2));


            residual=coder.nullcopy(realmax*ones(C_rows,1,'double'));
            residual=coder.internal.blas.xcopy(C_rows,d,INT_ONE,INT_ONE,residual,INT_ONE,INT_ONE);
            residual=coder.internal.blas.xgemv('N',C_rows,C_cols,...
            1.0,C,INT_ONE,C_rows,obj.X,INT_ONE,INT_ONE,-1.0,residual,INT_ONE,INT_ONE);


            resnorm=coder.internal.blas.xdot(C_rows,residual,INT_ONE,INT_ONE,residual,INT_ONE,INT_ONE);
        end
    end

end

