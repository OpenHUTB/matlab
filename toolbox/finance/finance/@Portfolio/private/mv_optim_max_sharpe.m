function[pwgt,status]=mv_optim_max_sharpe(H,g,g0,n,A,b,Aeq,beq,d,solverType,solverOptions)





































    solver='quadprog';
    if strcmpi(solverType,solver)
        options=solverOptions;
    else
        options=optimoptions(solver,'display','off',...
        'tolfun',1.0e-8,'tolcon',1.0e-8,'tolx',1.0e-8,'maxiter',10000);
    end
    [w,~,status]=quadprog([H,g;g',g0],[],A,b,Aeq,beq,zeros(size(Aeq,2),1),[],[],options);

    if~isempty(w)
        pwgt=w(1:n,1)/w(end,1)+d(1:n);
    else
        pwgt=[];
    end

end