function problem=checkBoundConstraints(problem,numVars,caller)





















    msg=isoptimargdbl(upper(caller),{'lb','ub'},problem.lb,problem.ub);
    if~isempty(msg)
        error('optim:algorithm:checkBoundConstraints:NonDoubleInput',msg);
    end


    if~isreal(problem.lb)
        error('optim:algorithm:checkBoundConstraints:ComplexInput',...
        getString(message('optim:algorithm:commonMessages:ComplexInput','LB')));
    end
    if~isreal(problem.ub)
        error('optim:algorithm:checkBoundConstraints:ComplexInput',...
        getString(message('optim:algorithm:commonMessages:ComplexInput','UB')));
    end



    [~,problem.lb,problem.ub]=checkbounds([],problem.lb,problem.ub,numVars);




