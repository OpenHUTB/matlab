classdef(Abstract)GeneralizedLinear























    properties(Hidden,SetAccess=protected,GetAccess=public)
        GeneralizedLinearVersion=1;
    end

    properties(Abstract,Constant,Hidden,GetAccess=public)
        ExitMessageCatalog;
        EmptyProblemMessageID;
    end


    methods

        function obj=GeneralizedLinear()
        end

    end


    methods(Abstract)
        run(obj,problem);
    end


    methods(Abstract,Hidden,Access=protected)
        getExitInfo(obj,exitCode);
    end

    methods(Hidden,Access=public)

        function[exitflag,exitmsg]=createExitflagAndMsg(obj,exitcode)



            [exitflag,exitMessageLabel,holeInfo]=getExitInfo(obj,exitcode);


            messageID=sprintf([obj.ExitMessageCatalog,':%s'],...
            exitMessageLabel);



            exitmsg=getString(message(messageID,holeInfo{:}));

        end

        function optionValueAndFeedback=getOptionValueAndFeedback(obj,optionName)










            optionValue=num2str(obj.Options.(optionName));
            if isSetByUser(obj.Options,optionName)
                optionFeedback='selected';
            else
                optionFeedback='default';
            end

            optionValueAndFeedback={optionValue,optionFeedback};
        end

    end


    methods

        function problem=checkRun(obj,problem,caller)






















            if nargin<3
                caller=mfilename;
            end


            problem=checkProblem(obj,problem,caller);
            checkOptions(obj.Options,problem,caller);


            numVars=optim.algorithm.GeneralizedLinear.getNumVars(problem);
            if numVars==0
                error(message(obj.EmptyProblemMessageID));
            end

        end

        function problem=checkProblem(~,problem,caller)





















            numVars=optim.algorithm.GeneralizedLinear.getNumVars(problem);


            if nargin<3
                caller=mfilename;
            end


            problem=optim.algorithm.checkLinearObjective(problem,numVars,caller);
            problem=optim.algorithm.checkLinearConstraints(problem,numVars,caller);
            problem=optim.algorithm.checkBoundConstraints(problem,numVars,caller);

        end

        function[exitflag,output]=performExitflagAndMsgActions(...
            obj,exitcode,output)

            [exitflag,exitmessage]=createExitflagAndMsg(obj,exitcode);


            if any(strcmpi(obj.Options.Display,{'final','iter','testing'}))
                dispExitMsg(exitmessage);
            end


            output.message=removeHTMLTags(exitmessage);
        end

    end


    methods(Static)

        function numVars=getNumVars(problem)
























            numVarsInObjective=numel(problem.f);
            numVarsInIneqCon=size(problem.Aineq,2);
            numVarsInEqCon=size(problem.Aeq,2);
            numVars=max([numVarsInObjective,numVarsInIneqCon,numVarsInEqCon]);

        end

    end

end
