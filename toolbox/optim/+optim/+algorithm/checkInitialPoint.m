function problem=checkInitialPoint(problem,numVars,caller)















    problem.x0=problem.x0(:);



    msg=isoptimargdbl(upper(caller),{'x0'},problem.x0);
    if~isempty(msg)
        error('optim:algorithm:checkInitialPoint:NonDoubleInput',msg);
    end


    if~isreal(problem.x0)
        error('optim:algorithm:checkInitialPoint:ComplexInput',...
        getString(message('optim:algorithm:commonMessages:ComplexInput','X0')));
    end


    if any(isnan(problem.x0))||any(isinf(problem.x0))
        error(message('optim:algorithm:checkInitialPoint:NaNOrInfInput'));
    end


    if~isempty(problem.x0)&&(numel(problem.x0)~=numVars)
        error(message('optim:algorithm:checkInitialPoint:WrongSizeX0'));
    end




