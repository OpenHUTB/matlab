function checkIntegerConstraints(problem,numVars,caller)















    msg=isoptimargdbl(upper(caller),{'intcon'},problem.intcon);
    if~isempty(msg)
        error('optim:algorithm:checkIntegerConstraints:NonDoubleInput',msg);
    end


    if~isreal(problem.intcon)
        error('optim:algorithm:checkIntegerConstraints:ComplexInput',...
        getString(message('optim:algorithm:commonMessages:ComplexInput','INTCON')));
    end


    if any(problem.intcon~=floor(problem.intcon))
        error(message('optim:algorithm:checkIntegerConstraints:NonIntegerInput'));
    end





    if any(problem.intcon(:)<1)||any(problem.intcon(:)>numVars)
        error(message('optim:algorithm:checkIntegerConstraints:IntegerIndexOutOfBounds',...
        numVars));
    end
