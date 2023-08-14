function problem=checkLinearObjective(problem,numVars,caller)

















    msg=isoptimargdbl(upper(caller),{'f'},problem.f);
    if~isempty(msg)
        error('optim:algorithm:checkLinearObjective:NonDoubleInput',msg);
    end


    if~isreal(problem.f)
        error('optim:algorithm:checkLinearObjective:ComplexInput',...
        getString(message('optim:algorithm:commonMessages:ComplexInput','f')));
    end


    if isempty(problem.f)


        problem.f=zeros(numVars,1);
    else


        if~isequal(numel(problem.f),numVars)
            error(message('optim:algorithm:checkLinearObjective:IncorrectNumberOfElements'));
        end


        problem.f=problem.f(:);

    end


