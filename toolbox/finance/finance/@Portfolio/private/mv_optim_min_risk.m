function[pmin,status]=mv_optim_min_risk(n,A,b,f0,f,H,g,d,...
    solverType,solverOptions,enforcePareto)







































    if strcmpi(solverType,'lcprog')
        [z,status]=mv_low_level_solver_lcprog(H,g,A,b,solverOptions);
    elseif strcmpi(solverType,'quadprog')
        [z,status]=mv_low_level_solver_quadprog(H,g,A,b,solverOptions);
    end

    z=z+d;
    pmin=z(1:n);



    if enforcePareto



        minrisk=z'*H*z+2*g'*z;

        p1=z;

        solverOptions=optimset(optimset('fmincon'),'algorithm','sqp','display','off',...
        'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
        'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);

        fhandle=@(z)local_min_risk_objective(z,f0,f);
        chandle=@(z)local_min_risk_constraint(z,H,g,minrisk);

        [z,~,exitflag]=fmincon(fhandle,z,A,b,[],[],zeros(size(z)),[],chandle,solverOptions);
        if exitflag>0
            p2=z+d;

            if f'*p2>f'*p1
                pmin=p2;
            else
                pmin=p1;
            end
            pmin=pmin(1:n);
        else
            warning(message('finance:Portfolio:mv_optim_min_risk:UnsuccessfulParetoEnforcement'));
        end
    end



    function[fobj,df]=local_min_risk_objective(z,f0,f)

        fobj=-(f0+f'*z);
        df=-f;

        function[ci,ce,dci,dce]=local_min_risk_constraint(z,H,g,minrisk)

            ci=[];
            ce=z'*H*z+2*g'*z-minrisk;

            if nargout>2
                dci=[];
                dce=2*(H*z+g);
            end
