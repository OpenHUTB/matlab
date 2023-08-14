classdef LinConstrWarmStart














%#codegen


    properties
X
Options
MaxLinearEqualities
MaxLinearInequalities
    end





    properties(Access=private)


solution
memspace
WorkingSet
QPObjective
QRManager
CholRegManager
runTimeOptions


isLinIneqUnbounded
isLinEqUnbounded

    end

    methods
        function obj=LinConstrWarmStart(x0,SolverOptions,WarmStartOptions,SolverName)
            coder.columnMajor;
            coder.allowpcode('plain');
            coder.inline('always');

            coder.internal.prefer_const(x0,SolverOptions,WarmStartOptions,SolverName);

            validateattributes(SolverOptions,{'struct'},{'scalar'});
            validateattributes(WarmStartOptions,{'struct'},{'scalar'});
            validateattributes(SolverName,{'char'},{'2d'});


            INT_ONE=coder.internal.indexInt(1);
            nVar=coder.internal.indexInt(numel(x0));


            optim.coder.validate.checkProducts();


            coder.internal.errorIf(isempty(x0),'optimlib_codegen:common:EmptyX');
            optim.coder.validate.checkX0(x0);




            optim.coder.validate.checkOptions(SolverOptions,SolverName,'active-set');




            obj.X=coder.nullcopy(realmax*ones(nVar,1,'double'));
            obj.X=coder.internal.blas.xcopy(nVar,x0,INT_ONE,INT_ONE,obj.X,INT_ONE,INT_ONE);


            obj.Options=SolverOptions;




            if(WarmStartOptions.MaxLinearEqualities<0)
                obj.MaxLinearEqualities=coder.internal.inf;
                obj.isLinEqUnbounded=true;
            else
                obj.MaxLinearEqualities=WarmStartOptions.MaxLinearEqualities;
                obj.isLinEqUnbounded=false;
            end

            if(WarmStartOptions.MaxLinearInequalities<0)
                obj.MaxLinearInequalities=coder.internal.inf;
                obj.isLinIneqUnbounded=true;
            else
                obj.MaxLinearInequalities=WarmStartOptions.MaxLinearInequalities;
                obj.isLinIneqUnbounded=false;
            end

            INT_ONE=coder.internal.indexInt(1);
            nVar=coder.internal.indexInt(numel(obj.X));
            nVarMax=nVar+INT_ONE;


            staticMemoryOnly=strcmpi(eml_option('UseMalloc'),'Off');



            if staticMemoryOnly
                prepConstrMemBnd=@coder.internal.indexInt;
            else
                prepConstrMemBnd=@coder.ignoreConst;
            end






            if(WarmStartOptions.MaxLinearEqualities<0&&~staticMemoryOnly)
                mEqBound=coder.internal.indexInt(nVar);
            else
                mEqBound=coder.internal.indexInt(WarmStartOptions.MaxLinearEqualities);
            end
            if(WarmStartOptions.MaxLinearInequalities<0&&~staticMemoryOnly)
                mIneqBound=coder.internal.indexInt(nVar);
            else
                mIneqBound=coder.internal.indexInt(WarmStartOptions.MaxLinearInequalities);
            end

            mConstrMax=mEqBound+mIneqBound+nVar+nVar+INT_ONE;
            maxDims=max(nVarMax,mConstrMax);



            solutionStruct=struct();
            solutionStruct.xstar=coder.nullcopy(realmax*ones(nVarMax,1,'double'));
            solutionStruct.fstar=0.0;
            solutionStruct.firstorderopt=0.0;
            solutionStruct.lambda=zeros(prepConstrMemBnd(mConstrMax),1,'double');
            solutionStruct.state=coder.internal.indexInt(0);
            solutionStruct.maxConstr=0.0;
            solutionStruct.iterations=coder.internal.indexInt(0);
            solutionStruct.searchDir=zeros(nVarMax,1,'double');
            obj.solution=solutionStruct;
            obj.solution.xstar=coder.internal.blas.xcopy(nVar,obj.X,INT_ONE,INT_ONE,obj.solution.xstar,INT_ONE,INT_ONE);




            integerArraySizes=coder.internal.indexInt(maxDims+max(mEqBound,mIneqBound));
            compareArraySize=coder.internal.indexInt(max(2*mIneqBound,mConstrMax)*nVarMax);

            memspaceStruct=struct();
            memspaceStruct.workspace_double=coder.nullcopy(realmax*ones(prepConstrMemBnd(maxDims),nVarMax,'double'));
            memspaceStruct.workspace_int=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(prepConstrMemBnd(integerArraySizes),1,coder.internal.indexIntClass));
            memspaceStruct.workspace_sort=coder.nullcopy(intmax(coder.internal.indexIntClass)*ones(prepConstrMemBnd(integerArraySizes),1,coder.internal.indexIntClass));
            memspaceStruct.workspace_compareIneq=coder.nullcopy(realmax*ones(prepConstrMemBnd(compareArraySize),1,'double'));
            obj.memspace=memspaceStruct;



            WorkingSetStruct=optim.coder.qpactiveset.WorkingSet.factoryConstruct(prepConstrMemBnd(mIneqBound),prepConstrMemBnd(mEqBound),nVar,nVarMax,prepConstrMemBnd(mConstrMax));
            obj.WorkingSet=WorkingSetStruct;
            obj.WorkingSet.SLACK0=0.0;


            obj.QPObjective=optim.coder.qpactiveset.Objective.factoryConstruct(nVarMax);



            QRRowBound=nVar+max(INT_ONE,mEqBound);
            QRManagerStruct=optim.coder.QRManager.factoryConstruct(prepConstrMemBnd(QRRowBound),prepConstrMemBnd(maxDims));
            obj.QRManager=QRManagerStruct;

            CholRegManagerStruct=optim.coder.DynamicRegCholManager.factoryConstruct(prepConstrMemBnd(QRRowBound));
            obj.CholRegManager=CholRegManagerStruct;
            obj.CholRegManager.scaleFactor=1e2;


            runTimeOptionsStruct=struct();
            runTimeOptionsStruct.MaxIterations=coder.internal.indexInt(obj.Options.MaxIterations);
            runTimeOptionsStruct.ConstrRelTolFactor=1.0;
            runTimeOptionsStruct.ProbRelTolFactor=1.0;
            runTimeOptionsStruct.RemainFeasible=false;
            obj.runTimeOptions=runTimeOptionsStruct;

        end

    end

    methods(Hidden)

        function obj=struct(obj)
            coder.internal.error('optimlib:warmstart:StructConversionUnsupported');
        end
    end

    methods(Access=protected)


        function[obj,fval,exitflag,output,lambda]=solve(H,f,Aineq,bineq,Aeq,beq,lb,ub,obj,isQuadprog)
            coder.inline('always');

            validateattributes(isQuadprog,{'logical'},{'scalar'});

            coder.internal.prefer_const(H,f,Aineq,bineq,Aeq,beq,lb,ub,isQuadprog);

            INT_ONE=coder.internal.indexInt(1);
            mIneq=coder.internal.indexInt(numel(bineq));
            mEq=coder.internal.indexInt(numel(beq));
            nVar=coder.internal.indexInt(numel(obj.X));
            nVarMax=coder.internal.indexInt(nVar+INT_ONE);

            numOutputs=nargout();


            optim.coder.validate.checkLinearInputs(nVar,Aineq,bineq,Aeq,beq,lb,ub);


            if(~strcmpi(eml_option('UseMalloc'),'Off'))

                mEqMax=mEq;
                mIneqMax=mIneq;





                if(numel(obj.WorkingSet.beq)<mEq)
                    EQ_EXPAND=coder.const(optim.coder.warmstart.constants.ConstrResize('LinearEq'));
                    mEqMax=coder.internal.indexInt(EQ_EXPAND+mEq);
                end

                if(numel(obj.WorkingSet.bineq)<mIneq)
                    INEQ_EXPAND=coder.const(optim.coder.warmstart.constants.ConstrResize('LinearIneq'));
                    mIneqMax=coder.internal.indexInt(INEQ_EXPAND+mIneq);
                end

                mConstrMax=mEqMax+mIneqMax+nVar+nVar+INT_ONE;
                maxDims=max(nVarMax,mConstrMax);
                QRRowBound=nVar+max(INT_ONE,mEqMax);
                memspaceIntBnd=coder.internal.indexInt(maxDims+max(mEqMax,mIneqMax));
                memspaceDblBnd=coder.internal.indexInt(max(2*mIneqMax,mConstrMax)*nVarMax);

                [obj.solution,obj.memspace,obj.WorkingSet,obj.QRManager,obj.CholRegManager]=...
                optim.coder.warmstart.qpactiveset.resizeDataStructs(mEqMax,mIneqMax,mConstrMax,QRRowBound,memspaceIntBnd,memspaceDblBnd,...
                obj.solution,obj.memspace,obj.WorkingSet,obj.QRManager,obj.CholRegManager);

            else




                mEqMax=coder.internal.indexInt(obj.MaxLinearEqualities);
                mIneqMax=coder.internal.indexInt(obj.MaxLinearInequalities);






                if coder.internal.hasRuntimeErrors
                    coder.internal.errorIf(mEq>mEqMax,'optim_codegen:warmstart:ExceededMaxLinEq','QUADPROG','IfNotConst','CheckAtRunTime');
                    coder.internal.errorIf(mIneq>mIneqMax,'optim_codegen:warmstart:ExceededMaxLinIneq','QUADPROG','IfNotConst','CheckAtRunTime');
                else
                    if(mIneq>mIneqMax||mEq>mEqMax)
                        if(numOutputs>=2)
                            fval=coder.internal.inf;
                            if(numOutputs>=3)
                                exitflag=double(coder.const(optim.coder.SolutionState('UndefinedStep')));
                                if(numOutputs>=4)
                                    output=struct('algorithm','active-set',...
                                    'firstorderopt',coder.internal.inf,...
                                    'constrviolation',coder.internal.inf,...
                                    'iterations',0);
                                    if(numOutputs>=5)
                                        lambda=struct('ineqlin',zeros(mIneq,1,'double'),...
                                        'eqlin',zeros(mEq,1,'double'),...
                                        'lower',zeros(nVar,1,'double'),...
                                        'upper',zeros(nVar,1,'double'));
                                    end
                                end
                            end
                        end
                        return;
                    end
                end

            end




            obj.QPObjective=optim.coder.qpactiveset.Objective.setQuadratic(obj.QPObjective,~isempty(f),nVar);


            tolcon=obj.Options.ConstraintTolerance;
            [obj.WorkingSet,obj.memspace]=...
            optim.coder.warmstart.qpactiveset.updateWorkingSet(...
            obj.WorkingSet,obj.memspace,Aineq,bineq,Aeq,beq,lb,ub,tolcon);


            obj.runTimeOptions(:)=optim.coder.options.convertQuadprogOptionsForSolver(obj.Options,nVar,obj.WorkingSet.mConstr);


            obj.runTimeOptions.ConstrRelTolFactor(:)=...
            optim.coder.qpactiveset.stopping.computePhaseOneRelativeTolerances(obj.WorkingSet);


            obj.runTimeOptions.ProbRelTolFactor(:)=...
            optim.coder.qpactiveset.stopping.updateRelativeTolerancesForPhaseTwo(obj.runTimeOptions.ConstrRelTolFactor,H,f);


            [obj.solution,obj.memspace,obj.WorkingSet,obj.QRManager,...
            obj.CholRegManager,obj.QPObjective]=...
            optim.coder.qpactiveset.driver(H,f,...
            obj.solution,obj.memspace,obj.WorkingSet,obj.QRManager,...
            obj.CholRegManager,obj.QPObjective,obj.Options,obj.runTimeOptions);


            obj.X=coder.internal.blas.xcopy(nVar,obj.solution.xstar,INT_ONE,INT_ONE,obj.X,INT_ONE,INT_ONE);

            if(numOutputs>=2)
                if(isQuadprog)
                    [fval,obj]=getFval(obj,H,f);
                else
                    fval=coder.internal.inf;
                end
                if(numOutputs>=3)
                    [exitflag,obj]=getExitFlag(obj);
                    if(numOutputs>=4)
                        [output,obj]=getOutputStruct(obj,H,f);
                        if(numOutputs>=5)
                            [lambda,obj]=getLambdaStruct(obj,mIneq,mEq);
                        end
                    end
                end
            end

        end

    end

    methods(Access=private)

        function[fval,obj]=getFval(obj,H,f)
            validateattributes(H,{'double'},{'2d'});
            validateattributes(f,{'double'},{'2d'});
            coder.inline('always');

            if(obj.solution.state>0)
                fval=obj.solution.fstar;
            else
                [fval,obj.memspace.workspace_double,obj.QPObjective]=...
                optim.coder.qpactiveset.Objective.computeFval(obj.QPObjective,obj.memspace.workspace_double,H,f,obj.solution.xstar);
            end
        end

        function[exitflag,obj]=getExitFlag(obj)
            coder.inline('always');
            obj.solution=optim.coder.qpactiveset.parseoutput.mapExitFlags(obj.solution);
            exitflag=double(obj.solution.state);
        end

        function[output,obj]=getOutputStruct(obj,H,f)
            coder.inline('always');

            INT_ONE=coder.internal.indexInt(1);
            INFEASIBLE=coder.const(optim.coder.SolutionState('Infeasible'));

            if(obj.solution.state==INFEASIBLE)
                obj.solution.firstorderopt=coder.internal.inf;
            elseif(obj.solution.state<=0)










                [obj.solution.maxConstr,obj.WorkingSet]=...
                optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(obj.WorkingSet,obj.solution.xstar,INT_ONE);

                if(obj.solution.maxConstr<=obj.Options.ConstraintTolerance*obj.runTimeOptions.ConstrRelTolFactor)

                    obj.QPObjective=optim.coder.qpactiveset.Objective.computeGrad(obj.QPObjective,H,f,obj.solution.xstar);
                    [obj.solution,obj.QPObjective,obj.memspace.workspace_double]=...
                    optim.coder.qpactiveset.parseoutput.computeFirstOrderOpt(obj.solution,obj.QPObjective,obj.WorkingSet,...
                    obj.memspace.workspace_double);
                else
                    obj.solution.firstorderopt=coder.internal.inf;
                end
            end





            output=struct('algorithm','active-set',...
            'firstorderopt',obj.solution.firstorderopt,...
            'constrviolation',max(0.0,obj.solution.maxConstr),...
            'iterations',double(obj.solution.iterations));
        end

        function[lambda,obj]=getLambdaStruct(obj,mIneq,mEq)

            coder.inline('always');

            validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
            validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});

            INT_ONE=coder.internal.indexInt(1);
            nVar=coder.internal.indexInt(numel(obj.X));






            lambda=struct('ineqlin',zeros(mIneq,1,'double'),...
            'eqlin',zeros(mEq,1,'double'),...
            'lower',zeros(nVar,1,'double'),...
            'upper',zeros(nVar,1,'double'));



            if(obj.WorkingSet.nActiveConstr>0)
                [obj.solution.lambda,obj.memspace.workspace_double]=...
                optim.coder.qpactiveset.parseoutput.sortLambdaQP...
                (obj.solution.lambda,obj.WorkingSet,obj.memspace.workspace_double,INT_ONE);

                lambda=optim.coder.qpactiveset.parseoutput.dealLambdaIntoStruct(lambda,obj.solution,obj.WorkingSet);
            end
        end

    end

end

