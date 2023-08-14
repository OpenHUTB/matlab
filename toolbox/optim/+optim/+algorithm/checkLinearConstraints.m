function problem=checkLinearConstraints(problem,numVars,caller)

















    if i_isSolver(caller)
        varNamesForErrorMsg={'A','b','Aeq','beq'};
    else
        varNamesForErrorMsg={'Aineq','bineq','Aeq','beq'};
    end
    msg=isoptimargdbl(upper(caller),varNamesForErrorMsg,...
    problem.Aineq,problem.bineq,problem.Aeq,problem.beq);
    if~isempty(msg)
        error('optim:algorithm:checkLinearConstraints:NonDoubleInput',msg);
    end


    i_checkRealCoeffs(problem,varNamesForErrorMsg);


    i_checkConstraintSizes(problem,numVars);


    problem=i_ensureEmptyConHasCorrectSize(problem,numVars);


    problem.bineq=problem.bineq(:);
    problem.beq=problem.beq(:);

    function i_checkRealCoeffs(problem,varNamesForErrorMsg)

        if~isreal(problem.Aineq)
            error(message('optim:algorithm:checkLinearConstraints:ComplexInputMatrix',...
            varNamesForErrorMsg{1}));
        end
        if~isreal(problem.bineq)
            error('optim:algorithm:checkLinearConstraints:ComplexInput',...
            getString(message('optim:algorithm:commonMessages:ComplexInput',...
            varNamesForErrorMsg{2})));
        end
        if~isreal(problem.Aeq)
            error(message('optim:algorithm:checkLinearConstraints:ComplexInputMatrix',...
            varNamesForErrorMsg{3}));
        end
        if~isreal(problem.beq)
            error('optim:algorithm:checkLinearConstraints:ComplexInput',...
            getString(message('optim:algorithm:commonMessages:ComplexInput',...
            varNamesForErrorMsg{4})));
        end

        function i_checkConstraintSizes(problem,numVars)

            [nineqcstr,nvarsineq]=size(problem.Aineq);
            [neqcstr,nvarseq]=size(problem.Aeq);
            if~isequal(numel(problem.bineq),nineqcstr)
                error('optim:algorithm:checkLinearConstraints:SizeMismatchRowsOfA',...
                getString(message('optim:linprog:SizeMismatchRowsOfA')));
            end
            if~isequal(numel(problem.beq),neqcstr)
                error('optim:algorithm:checkLinearConstraints:SizeMismatchRowsOfAeq',...
                getString(message('optim:linprog:SizeMismatchRowsOfAeq')));
            end
            if~isempty(problem.Aineq)&&~isequal(nvarsineq,numVars)
                error('optim:algorithm:checkLinearConstraints:SizeMismatchColsOfA',...
                getString(message('optim:linprog:SizeMismatchColsOfA')));
            end
            if~isempty(problem.Aeq)&&~isequal(nvarseq,numVars)
                error('optim:algorithm:checkLinearConstraints:SizeMismatchColsOfAeq',...
                getString(message('optim:linprog:SizeMismatchColsOfAeq')));
            end

            function problem=i_ensureEmptyConHasCorrectSize(problem,numVars)

                if isempty(problem.Aineq)
                    problem.Aineq=zeros(0,numVars);
                end
                if isempty(problem.bineq)
                    problem.bineq=zeros(0,1);
                end
                if isempty(problem.Aeq)
                    problem.Aeq=zeros(0,numVars);
                end
                if isempty(problem.beq)
                    problem.beq=zeros(0,1);
                end

                function isSolver=i_isSolver(caller)








                    try
                        createProblemStruct(caller);
                        isSolver=true;
                    catch
                        isSolver=false;
                    end

