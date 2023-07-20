function[pmax,status]=mv_optim_max_return_te(n,A,b,f0,f,H,g,d,gT0,gT,...
    solverType,solverOptions,enforcePareto)











































    z0=zeros(size(d));

    fhandle=@(z)local_objective(z,f0,f);
    chandle=@(z)mv_tracking_error_as_constraint(z,H,gT,gT0);

    if isempty(solverOptions)
        solverOptions=optimset(optimset('fmincon'),'algorithm','sqp','display','off',...
        'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
        'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);
    end

    [z,~,status]=fmincon(fhandle,z0,A,b,[],[],zeros(size(d)),[],chandle,solverOptions);

    z=z+d;
    pmax=z(1:n);



    if enforcePareto












        maxreturn=f0+f'*z;

        z1=z;

        solverOptions=optimset(optimset('fmincon'),'algorithm','sqp','display','off',...
        'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
        'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);

        fhandle=@(z)local_pareto_objective(z,H,g);
        chandle=@(z)mv_tracking_error_as_constraint(z,H,gT,gT0);

        [z2,~,exitflag]=fmincon(fhandle,z,[A;-f'],[b;(f0-maxreturn)],...
        [],[],zeros(size(d)),[],chandle,solverOptions);

        if exitflag>0
            z2=z2+d;

            if fhandle(z1)<fhandle(z2)
                pmax=z1;
            else
                pmax=z2;
            end
            pmax=pmax(1:n);
        else
            warning(message('finance:Portfolio:mv_optim_max_return_te:UnsuccessfulParetoEnforcement'));
        end
    end



    function[fobj,df]=local_objective(z,f0,f)

        fobj=-(f0+f'*z);
        df=-f;

        function[fobj,df]=local_pareto_objective(z,H,g)

            fobj=0.5*(z'*H*z)+g'*z;
            df=H*z+g;
