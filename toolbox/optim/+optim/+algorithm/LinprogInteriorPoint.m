classdef(Sealed)LinprogInteriorPoint<optim.algorithm.GeneralizedLinear























    properties(Hidden,SetAccess=protected,GetAccess=public)
        LinprogInteriorPointVersion=1;
        Options=optim.options.Linprog;
    end

    properties(Constant,Hidden,GetAccess=public)
        ExitMessageCatalog='optim:algorithm:LinprogInteriorPointExitMessages';
        EmptyProblemMessageID='optim:algorithm:LinprogInteriorPoint:EmptyProblem';
    end


    methods

        function obj=LinprogInteriorPoint(Options)




            if nargin>0
                obj.Options=Options;
            end
        end

    end


    methods

        function[x,fval,exitflag,output,lambda,mexoutput]=run(obj,problem)





































            [x,fval,iplpexitcode,output,lambda,mexoutput]=...
            iplp(problem.f,problem.Aineq,problem.bineq,...
            problem.Aeq,problem.beq,problem.lb,problem.ub,...
            problem.options);


            [exitflag,output]=performExitflagAndMsgActions(...
            obj,iplpexitcode,output);

        end


    end

    methods(Hidden,Access=protected)

        function[exitflag,exitMessageLabel,holeInfo]=...
            getExitInfo(obj,iplpExitflagStruct)

















            exitflag=iplpExitflagStruct.MacroExitflag;


            macroFlag=iplpExitflagStruct.MacroExitflag;
            microFlag=iplpExitflagStruct.MicroExitflag;
            if macroFlag==1&&microFlag==1


                exitMessageLabel='Solved';
                TolFunInfo=getOptionValueAndFeedback(obj,('TolFun'));
                TolConInfo=getOptionValueAndFeedback(obj,('TolCon'));
                holeInfo=[...
                createCSHLinks('quadprogipc_min_found'),...
                createCSHLinks('quadprog_feasible_direction'),...
                TolFunInfo{2},...
                createCSHLinks('function_tolerance'),...
                TolConInfo{2},...
                createCSHLinks('constraint_tolerance')];
            elseif macroFlag==1&&microFlag==3
                exitMessageLabel='SolvedInPresolve';


                holeInfo=createCSHLinks('soln_found_in_presolve');
            elseif macroFlag==0
                exitMessageLabel='PremMaxIter';
                holeInfo=[createCSHLinks('lp_iter_limit'),...
                getOptionValueAndFeedback(obj,('MaxIter'))];
            elseif macroFlag==-2&&(microFlag==1||microFlag==2)






                exitMessageLabel='NoFeasibleSolution';
                holeInfo=createCSHLinks('lp_no_feas_solution');
            elseif macroFlag==-2&&microFlag==3
                exitMessageLabel='InfeasibleInPresolve';
                holeInfo=createCSHLinks('infeasible_presolve');
            elseif macroFlag==-3&&microFlag==1



                exitMessageLabel='AppearsUnbounded';
                holeInfo=createCSHLinks('linprog_appears_unbounded');
            elseif macroFlag==-3&&microFlag==3



                exitMessageLabel='UnboundedInPresolve';
                holeInfo=createCSHLinks('presolve_unbounded');
            elseif macroFlag==-8


                exitMessageLabel='UndefinedStep';
                holeInfo=createCSHLinks('qp_step_fails');
            elseif macroFlag==-10&&(microFlag>=10&&microFlag<=14)

                switch microFlag
                case 10

                    error(message('optim:algorithm:LinprogInteriorPoint:ComplexValues'));
                case 11

                    error(message('optim:algorithm:LinprogInteriorPoint:NaNValues'));
                case 12

                    error(message('optim:algorithm:LinprogInteriorPoint:InfValues'));
                case 13

                    error(message('optim:algorithm:LinprogInteriorPoint:FullMatrices'));
                case 14

                    error(message('optim:algorithm:LinprogInteriorPoint:OptsNotStruct'));

                end
            else



                error(message('optim:algorithm:LinprogInteriorPoint:InvalidExitflags'));
            end

        end

    end

end
