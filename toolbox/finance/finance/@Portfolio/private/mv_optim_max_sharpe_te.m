function[pwgt,status]=mv_optim_max_sharpe_te(H,g,g0,n,A,b,Aeq,beq,gT,gT0,d,solverType,solverOptions)








































    teConstraint=@(w)direct_local_te_constraint(w,H,gT,gT0);
    fhandle=@(w)direct_local_obj(w,H,g,g0);

    solver='fmincon';
    if strcmpi(solverType,solver)
        options=solverOptions;
    else
        options=optimoptions(solver,'algorithm','sqp','display','off',...
        'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
        'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);
    end

    [w,~,status]=fmincon(fhandle,zeros(size(A,2),1),A,b,Aeq,beq,...
    zeros(numel(d),1),[],teConstraint,options);

    if~isempty(w)
        pwgt=w(1:n,1)/w(end,1)+d(1:n);
    else
        pwgt=[];
    end

end

function[fobj,df]=direct_local_obj(w,H,g,g0)

    H=[H,g;g',g0];
    fobj=0.5*(w'*H*w);
    df=H*w;
end

function[ci,ce,dci,dce]=direct_local_te_constraint(w,H,gT,gT0)


    H=[H,gT;gT',gT0];

    ci=0.5*w'*H*w;
    ce=[];


    dci=H*w;
    dce=[];

end