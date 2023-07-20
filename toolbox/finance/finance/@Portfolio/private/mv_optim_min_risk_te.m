function[pmin,status]=mv_optim_min_risk_te(n,A,b,f0,f,H,g,d,gT0,gT,...
    solverType,solverOptions,enforcePareto)























































    z0=zeros(size(d));

    fhandle=@(z)local_objective(z,H,g);
    chandle=@(z)mv_tracking_error_as_constraint(z,H,gT,gT0);

    if isempty(solverOptions)
        solverOptions=optimset(optimset('fmincon'),'algorithm','sqp','display','off',...
        'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
        'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);
    end

    [z,~,status]=fmincon(fhandle,z0,A,b,[],[],zeros(size(d)),[],chandle,solverOptions);

    z=z+d;
    pmin=z(1:n);



    if enforcePareto



        minrisk=z'*H*z+2*g'*z;

        z1=z;

        solverOptions=optimset(optimset('fmincon'),'algorithm','sqp','display','off',...
        'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
        'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);

        fhandle=@(z)local_pareto_objective(z,f0,f);
        chandle=@(z)local_pareto_constraint(z,H,g,gT,gT0,minrisk);

        [z2,~,exitflag]=fmincon(fhandle,z,A,b,[],[],zeros(size(z)),[],chandle,solverOptions);

        if exitflag>0
            z2=z2+d;

            if fhandle(z1)<fhandle(z2)
                pmin=z1;
            else
                pmin=z2;
            end
            pmin=pmin(1:n);
        else
            warning(message('finance:Portfolio:mv_optim_min_risk_te:UnsuccessfulParetoEnforcement'));
        end
    end



    function[fobj,df]=local_objective(z,H,g)

        fobj=0.5*(z'*H*z)+g'*z;
        df=H*z+g;

        function[fobj,df]=local_pareto_objective(z,f0,f)

            fobj=-(f0+f'*z);
            df=-f;

            function[ci,ce,dci,dce]=local_pareto_constraint(z,H,g,gT,gT0,minrisk)






                ci=z'*H*z+2*gT'*z+gT0;
                ce=z'*H*z+2*g'*z-minrisk;

                if nargout>2
                    dci=2*(H*z+gT);
                    dce=2*(H*z+g);
                end
