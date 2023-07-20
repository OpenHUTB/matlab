function[pwgt,status]=mv_optim_by_risk_te(risk,n,z0,f,A,b,H,g,g0,gT,gT0,d,...
    solverType,solverOptions)














































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
        consNL=@(z)local_nl_constraints(z,risk(i),H,g,g0,gT,gT0);
        [z,~,status(i)]=fmincon(objFcn,z0(:,i),A,b,[],[],zeros(size(A,2),1),[],...
        consNL,options);
        pwgt(:,i)=z(1:n)+d(1:n);
    end
end



function[ci,ce,dci,dce]=local_nl_constraints(z,targetRiskStd,H,g,g0,gT,gT0)

    [ci_risk,~,dci_risk,~]=mv_risk_as_constraint(z,targetRiskStd,H,g,g0);


    [ci_te,~,dci_te,~]=mv_tracking_error_as_constraint(z,H,gT,gT0);

    ci=[ci_risk;ci_te];
    ce=[];

    if nargout>2
        dci=[dci_risk,dci_te];
        dce=[];
    end

end
