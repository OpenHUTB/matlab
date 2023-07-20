classdef(Sealed)IntlinprogBranchAndCut<optim.algorithm.SlbiCommon























    properties(Hidden,SetAccess=protected,GetAccess=public)
        IntlinprogBranchAndCutVersion=2;
        Options=optim.options.Intlinprog;
    end

    properties(Hidden,Access=private)

        PreCheckedOptions=struct.empty;
    end

    properties(Constant,Hidden,GetAccess=public)
        ExitMessageCatalog='optim:algorithm:IntlinprogBranchAndCutExitMessages';
        EmptyProblemMessageID='optim:algorithm:IntlinprogBranchAndCut:EmptyProblem';
    end


    methods

        function obj=IntlinprogBranchAndCut(Options)




            if nargin>0
                obj.Options=Options;
            end
        end

    end


    methods

        function[x,fval,exitflag,output]=run(obj,problem)








































            [x,fval,slbiexitcode,output]=slbiClient(problem.f,...
            problem.intcon,problem.Aineq,problem.bineq,...
            problem.Aeq,problem.beq,problem.lb,problem.ub,...
            problem.x0,obj.Options);


            [exitflag,output]=performExitflagAndMsgActions(...
            obj,slbiexitcode,output);

        end

        function problem=checkProblem(~,problem,caller)






















            numVars=optim.algorithm.SlbiCommon.getNumVars(problem);


            if nargin<3
                caller=mfilename;
            end


            problem=optim.algorithm.checkLinearObjective(problem,numVars,caller);
            optim.algorithm.checkIntegerConstraints(problem,numVars,caller);
            problem=optim.algorithm.checkLinearConstraints(problem,numVars,caller);
            problem=optim.algorithm.checkBoundConstraints(problem,numVars,caller);
            problem=optim.algorithm.checkInitialPoint(problem,numVars,caller);

        end

    end

    methods(Access=protected)

        function[exitflag,exitMessageLabel,holeInfo]=getExitInfo(obj,slbiCode)

















            exitflag=regexp(slbiCode,'_(-?\d)','tokens');
            exitflag=str2double(exitflag{1});


            switch slbiCode
            case 'IP_2_0'
                exitMessageLabel='PrematureUnknown';
                holeInfo=[createCSHLinks('milp_premature_stop_yes'),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_2_3'
                exitMessageLabel='PrematureOutOfMemory';
                holeInfo=[createCSHLinks('milp_premature_stop_yes'),...
                createCSHLinks('milp_memory'),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_2_4'
                exitMessageLabel='PrematureMaxNodes';
                holeInfo=[createCSHLinks('milp_premature_stop_yes'),...
                createCSHLinks('milp_max_nodes'),...
                getOptionValueAndFeedback(obj,('MaxNodes')),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_2_5'
                exitMessageLabel='PrematureMaxTime';
                holeInfo=[createCSHLinks('milp_premature_stop_yes'),...
                createCSHLinks('milp_time_limit'),...
                getOptionValueAndFeedback(obj,('MaxTime')),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_2_6'
                exitMessageLabel='PrematureLPMaxIter';
                holeInfo=[createCSHLinks('milp_premature_stop_yes'),...
                createCSHLinks('milp_iteration_limit'),...
                getOptionValueAndFeedback(obj,('LPMaxIter')),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_2_7'
                exitMessageLabel='PrematureMaxNumFeasPoints';
                holeInfo=[createCSHLinks('milp_premature_stop_yes'),...
                createCSHLinks('milp_max_feaspts'),...
                getOptionValueAndFeedback(obj,('MaxNumFeasPoints')),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_1_1'
                exitMessageLabel='TolGapAbs';
                holeInfo=[createCSHLinks('milp_abs_gap'),...
                getOptionValueAndFeedback(obj,('TolGapAbs')),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_1_2'
                exitMessageLabel='TolGapRel';
                holeInfo=[createCSHLinks('milp_rel_gap'),...
                getOptionValueAndFeedback(obj,('TolGapRel')),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_1_3'
                exitMessageLabel='BeforeBandBTolGapAbs';
                holeInfo=[createCSHLinks('milp_abs_gap'),...
                getOptionValueAndFeedback(obj,('TolGapAbs')),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_1_4'
                exitMessageLabel='BeforeBandBTolGapRel';
                holeInfo=[createCSHLinks('milp_rel_gap'),...
                getOptionValueAndFeedback(obj,('TolGapRel')),...
                createCSHLinks('milp_integer_within_tolerance'),...
                getOptionValueAndFeedback(obj,('TolInteger'))];
            case 'IP_3_1'
                exitMessageLabel='PoorConstrFeasibility';
                holeInfo={};
            case 'IP_3_2'
                exitMessageLabel='PremPoorConstrFeasibility';
                holeInfo={};
            case 'LP_3_1'
                exitMessageLabel='LPPoorConstrFeasibility';
                holeInfo=createCSHLinks('milp_no_intcon');
            case 'LP_1_1'
                exitMessageLabel='SolvedCts';
                holeInfo=createCSHLinks('milp_no_intcon');
            case 'IP_0_0'
                exitMessageLabel='PremNoFeasUnknown';
                holeInfo=createCSHLinks('milp_premature_stop_no');
            case 'IP_0_1'
                exitMessageLabel='PremNoFeasRootLPMaxIter';
                holeInfo=[createCSHLinks('milp_premature_stop_no'),...
                createCSHLinks('milp_root_iter_limit'),...
                getOptionValueAndFeedback(obj,('RootLPMaxIter'))];
            case 'IP_0_3'
                exitMessageLabel='PremNoFeasRootOutOfMemory';
                holeInfo=[createCSHLinks('milp_premature_stop_no'),...
                createCSHLinks('milp_memory')];
            case 'IP_0_4'
                exitMessageLabel='PremNoFeasMaxNodes';
                holeInfo=[createCSHLinks('milp_premature_stop_no'),...
                createCSHLinks('milp_max_nodes'),...
                getOptionValueAndFeedback(obj,('MaxNodes'))];
            case 'IP_0_5'
                exitMessageLabel='PremNoFeasMaxTime';
                holeInfo=[createCSHLinks('milp_premature_stop_no'),...
                createCSHLinks('milp_time_limit'),...
                getOptionValueAndFeedback(obj,('MaxTime'))];
            case 'IP_0_6'
                exitMessageLabel='PremNoFeasLPMaxIter';
                holeInfo=[createCSHLinks('milp_premature_stop_no'),...
                createCSHLinks('milp_iteration_limit'),...
                getOptionValueAndFeedback(obj,('LPMaxIter'))];
            case 'LP_0_0'
                exitMessageLabel='PremCtsUnknown';
                holeInfo=createCSHLinks('milp_no_intcon');
            case 'LP_0_1'
                exitMessageLabel='PremCtsRootLPMaxIter';
                holeInfo=[createCSHLinks('milp_no_intcon'),...
                createCSHLinks('milp_root_iter_limit'),...
                getOptionValueAndFeedback(obj,('RootLPMaxIter'))];
            case 'LP_0_3'
                exitMessageLabel='PremCtsOutOfMemory';
                holeInfo=[createCSHLinks('milp_no_intcon'),...
                createCSHLinks('milp_memory')];
            case 'LP_0_5'
                exitMessageLabel='PremCtsMaxTime';
                holeInfo=[createCSHLinks('milp_no_intcon'),...
                createCSHLinks('milp_time_limit'),...
                getOptionValueAndFeedback(obj,('MaxTime'))];
            case 'IP_-2_1'
                exitMessageLabel='NoFeasIntegerSoln';
                holeInfo=createCSHLinks('milp_no_feas_solution');
            case 'IP_-2_2'
                exitMessageLabel='NoFeasibleSolution';
                holeInfo=createCSHLinks('milp_no_feas_solution');
            case 'IP_-2_3'
                exitMessageLabel='NoFeasIntegerBound';
                holeInfo=createCSHLinks('milp_no_feas_solution');
            case 'IP_-2_4'
                exitMessageLabel='NoFeasChkBnds';
                holeInfo=createCSHLinks('milp_no_feas_solution');
            case 'LP_-2'
                exitMessageLabel='CtsNoFeasibleSolution';
                holeInfo=[createCSHLinks('milp_no_feas_solution'),...
                createCSHLinks('milp_no_intcon')];
            case 'LP_-2_4'
                exitMessageLabel='CtsNoFeasChkBnds';
                holeInfo=[createCSHLinks('milp_no_feas_solution'),...
                createCSHLinks('milp_no_intcon')];
            case 'IP_-3'
                exitMessageLabel='Unbounded';
                holeInfo=createCSHLinks('milp_infeas_or_unbounded');
            case 'LP_-3'
                exitMessageLabel='CtsUnbounded';
                holeInfo=[createCSHLinks('milp_unbounded'),...
                createCSHLinks('milp_no_intcon')];
            case 'IP_-9'
                exitMessageLabel='ConstrFeasibilityLost';
                holeInfo={};
            case 'LP_-9'
                exitMessageLabel='LPConstrFeasibilityLost';
                holeInfo=createCSHLinks('milp_no_intcon');
            case{'IP_-1','LP_-1'}
                exitMessageLabel='outputFcnStop';
                holeInfo={};
            end

        end

    end

    methods(Hidden)
        function obj=initialize(obj,f,intcon,Aineq,bineq,Aeq,beq,lb,ub,x0)








            [~,~,~,~,~,obj.PreCheckedOptions]=slbiClient(...
            f,intcon,Aineq,bineq,Aeq,beq,lb,ub,x0,obj.Options);



            obj.PreCheckedOptions.Heuristics=obj.Options.Heuristics;
            obj.PreCheckedOptions.ConstraintTolerance=obj.Options.ConstraintTolerance;
            obj.PreCheckedOptions.IntegerTolerance=obj.Options.IntegerTolerance;
        end

        function[x,fval,exitflag,output,obj]=runNoChecks(obj,...
            f,intcon,Aineq,bineq,Aeq,beq,lb,ub,x0)





            if isempty(obj.PreCheckedOptions)

                obj=obj.initialize(f,intcon,Aineq,bineq,Aeq,beq,lb,ub,x0);
            end


            [x,fval,slbiexitcode,output]=slbiClient(...
            f,intcon,Aineq,bineq,Aeq,beq,lb,ub,x0,obj.PreCheckedOptions);


            exitflag=regexp(slbiexitcode,'_(-?\d)','tokens');
            exitflag=double(string(exitflag{1}));
            output.message='';
        end
    end
end