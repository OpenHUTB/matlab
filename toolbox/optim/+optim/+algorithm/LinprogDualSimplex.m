classdef(Sealed)LinprogDualSimplex<optim.algorithm.SlbiCommon























    properties(Hidden,SetAccess=protected,GetAccess=public)
        LinprogDualSimplexVersion=2;
        Options=optim.options.Linprog;
    end

    properties(Constant,Hidden,GetAccess=public)
        ExitMessageCatalog='optim:algorithm:LinprogDualSimplexExitMessages';
        EmptyProblemMessageID='optim:algorithm:LinprogDualSimplex:EmptyProblem';
        IntlinprogOptions=optimoptions('intlinprog','RootLPAlgorithm','dual-simplex');
    end

    properties(Hidden,Access=private)

        PreCheckedOptions=struct.empty;
    end


    methods

        function obj=LinprogDualSimplex(Options)





            if nargin>0
                obj.Options=Options;
            end
        end

    end


    methods

        function[x,fval,exitflag,output,lambda]=run(obj,problem)


































            intlinprogoptions=optim.algorithm.LinprogDualSimplex.IntlinprogOptions;

            intlinprogoptions.Display=obj.Options.Display;
            thisMaxIter=obj.Options.MaxIter;
            if ischar(thisMaxIter)
                if strcmpi(thisMaxIter,'10*(numberofequalities+numberofinequalities+numberofvariables)')
                    [nineqcstr,~]=size(problem.Aineq);
                    [neqcstr,~]=size(problem.Aeq);
                    ncstr=nineqcstr+neqcstr;
                    nvars=optim.algorithm.SlbiCommon.getNumVars(problem);
                    thisMaxIter=10*(ncstr+nvars);
                else
                    error(message('optim:linprog:InvalidMaxIter'));
                end
            end




            try
                intlinprogoptions.RootLPMaxIterations=thisMaxIter;
                intlinprogoptions.MaxTime=obj.Options.MaxTime;
                intlinprogoptions.LPPreprocess=obj.Options.Preprocess;
                intlinprogoptions.ConstraintTolerance=obj.Options.TolCon;
                intlinprogoptions.LPOptimalityTolerance=obj.Options.TolFun;
            catch ME


                if strcmpi(ME.identifier,'optim:options:meta:NumericType:validate:InvalidNumericType')&&...
                    strcmpi(ME.stack(1).name,'Intlinprog.set.LPOptimalityTolerance')
                    error('optim:linprog:InvalidOptimalityTol',...
                    getString(message('MATLAB:optimfun:optimoptioncheckfield:notAboundedReal',...
                    'OptimalityTolerance',sprintf('[%6.3g, %6.3g]',1e-10,1e-1))));
                else
                    throw(ME);
                end
            end


            optsStruct=extractOptionsStructure(obj.Options);
            intlinprogoptions=setInternalOptions(intlinprogoptions,...
            optsStruct.InternalOptions);





            [x,fval,slbiexitcode,output,lambda]=slbiClient(problem.f,...
            [],problem.Aineq,problem.bineq,...
            problem.Aeq,problem.beq,problem.lb,problem.ub,[],...
            intlinprogoptions);


            [exitflag,output]=performExitflagAndMsgActions(...
            obj,slbiexitcode,output);

        end

        function problem=checkProblem(~,problem,caller)





















            numVars=optim.algorithm.SlbiCommon.getNumVars(problem);


            if nargin<3
                caller=mfilename;
            end


            problem=optim.algorithm.checkLinearObjective(problem,numVars,caller);
            problem=optim.algorithm.checkLinearConstraints(problem,numVars,caller);
            problem=optim.algorithm.checkBoundConstraints(problem,numVars,caller);

        end

    end

    methods(Access=protected)

        function[exitflag,exitMessageLabel,holeInfo]=getExitInfo(obj,slbiCode)

















            exitflag=regexp(slbiCode,'_(-?\d)','tokens');
            exitflag=str2double(exitflag{1});


            switch slbiCode
            case 'LP_1_1'
                exitMessageLabel='Solved';
                holeInfo={};
            case 'LP_3_1'
                exitMessageLabel='PoorConstrFeasibility';
                holeInfo={};
            case 'LP_0_0'
                exitMessageLabel='PremUnknown';
                holeInfo={};
            case 'LP_0_1'
                exitMessageLabel='PremMaxIter';
                holeInfo=[createCSHLinks('lp_iter_limit'),...
                getOptionValueAndFeedback(obj,('MaxIter'))];
            case 'LP_0_3'
                exitMessageLabel='PremOutOfMemory';
                holeInfo=createCSHLinks('lp_memory');
            case 'LP_0_5'
                exitMessageLabel='PremMaxTime';
                holeInfo=[createCSHLinks('lp_time_limit'),...
                getOptionValueAndFeedback(obj,('MaxTime'))];
            case 'LP_-2'
                exitMessageLabel='NoFeasibleSolution';
                holeInfo=createCSHLinks('lp_no_feas_solution');
            case 'LP_-2_4'
                exitMessageLabel='NoFeasChkBnds';
                holeInfo=createCSHLinks('lp_no_feas_solution');
            case 'LP_-3'
                exitMessageLabel='Unbounded';
                holeInfo=createCSHLinks('lp_unbounded');
            case 'LP_-9'
                exitMessageLabel='ConstrFeasibilityLost';
                holeInfo={};
            end

        end

    end

    methods(Hidden)
        function obj=initialize(obj,f,Aineq,bineq,Aeq,beq,lb,ub)







            intlinprogoptions=optim.algorithm.LinprogDualSimplex.IntlinprogOptions;


            intlinprogoptions.Display=obj.Options.Display;
            thisMaxIter=obj.Options.MaxIter;
            if ischar(thisMaxIter)
                if strcmpi(thisMaxIter,'10*(numberofequalities+numberofinequalities+numberofvariables)')
                    [nineqcstr,~]=size(Aineq);
                    [neqcstr,~]=size(Aeq);
                    ncstr=nineqcstr+neqcstr;
                    nvars=numel(f);
                    thisMaxIter=10*(ncstr+nvars);
                else
                    error(message('optim:linprog:InvalidMaxIter'));
                end
            end




            try
                intlinprogoptions.RootLPMaxIterations=thisMaxIter;
                intlinprogoptions.MaxTime=obj.Options.MaxTime;
                intlinprogoptions.LPPreprocess=obj.Options.Preprocess;
                intlinprogoptions.ConstraintTolerance=obj.Options.TolCon;
                intlinprogoptions.LPOptimalityTolerance=obj.Options.TolFun;
            catch ME


                if strcmpi(ME.identifier,'optim:options:meta:NumericType:validate:InvalidNumericType')
                    error('optim:linprog:InvalidOptimalityTol',...
                    getString(message('MATLAB:optimfun:optimoptioncheckfield:notAboundedReal',...
                    'OptimalityTolerance',sprintf('[%6.3g, %6.3g]',1e-10,1e-1))));
                else
                    throw(ME);
                end
            end


            optsStruct=extractOptionsStructure(obj.Options);
            intlinprogoptions=setInternalOptions(intlinprogoptions,...
            optsStruct.InternalOptions);



            [~,~,~,~,~,obj.PreCheckedOptions]=slbiClient(...
            f,[],Aineq,bineq,Aeq,beq,lb,ub,[],intlinprogoptions);
        end

        function[x,fval,exitflag,output,obj]=runNoChecks(obj,...
            f,Aineq,bineq,Aeq,beq,lb,ub)





            if isempty(obj.PreCheckedOptions)

                obj=obj.initialize(f,Aineq,bineq,Aeq,beq,lb,ub);
            end


            [x,fval,slbiexitcode,output]=slbiClient(...
            f,[],Aineq,bineq,Aeq,beq,lb,ub,[],obj.PreCheckedOptions);


            exitflag=regexp(slbiexitcode,'_(-?\d)','tokens');
            exitflag=double(string(exitflag{1}));
            output.message='';
        end
    end
end
