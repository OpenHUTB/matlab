function[pwgt,status]=mv_optim_by_risk(risk,n,z0,f,A,b,H,g,g0,d,solverType,solverOptions)











































    pnum=numel(risk);

    pwgt=zeros(n,pnum);
    status=zeros(1,pnum);


    objFcn=@(z)mv_return_as_objective(z,f);

    requiredSolver='fmincon';
    if strcmpi(solverType,requiredSolver)
        options=optimoptions(solverOptions);
    else
        options=optimoptions(requiredSolver,'algorithm','sqp','display','off',...
        'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
        'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);
    end

    for i=1:pnum
        riskConsNL=@(z)mv_risk_as_constraint(z,risk(i),H,g,g0);
        [z,~,status(i)]=fmincon(objFcn,z0(:,i),A,b,[],[],zeros(size(A,2),1),[],...
        riskConsNL,options);
        pwgt(:,i)=z(1:n)+d(1:n);
    end

end
