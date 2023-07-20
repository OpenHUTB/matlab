function[pmax,status]=mv_optim_max_return(n,A,b,f0,f,H,g,d,lpOptions,...
    solverType,solverOptions,enforcePareto)













































    if strcmpi(solverType,'lcprog')
        [z,status]=mv_low_level_solver_lcprog(zeros(numel(f)),-f,A,b,solverOptions);
    elseif strcmpi(solverType,'quadprog')

        [z,status]=mv_low_level_solver_linprog(-f,A,b,zeros(numel(f),1),[],lpOptions);
        if status==-3
            error(message('finance:Portfolio:mv_optim_max_return:UnboundedProblem'));
        elseif status==-2
            error(message('finance:Portfolio:mv_optim_max_return:InfeasibleProblem'));
        elseif status<0
            error(message('finance:Portfolio:mv_optim_max_return:IllDefinedProblem'));
        end
    end

    maxreturn=f0+f'*z;

    z=z+d;
    pmax=z(1:n);



    if enforcePareto



        p1=z;

        if strcmpi(solverType,'lcprog')
            [z,exitflag]=mv_low_level_solver_lcprog(H,g,[A;-f'],[b;(f0-maxreturn)],...
            solverOptions);
        elseif strcmpi(solverType,'quadprog')
            [z,exitflag]=mv_low_level_solver_quadprog(H,g,[A;-f'],[b;(f0-maxreturn)],...
            solverOptions);
        end

        if exitflag>0
            p2=z+d;

            if p1'*H*p1+g'*p1<p2'*H*p2+g'*p2
                pmax=p1;
            else
                pmax=p2;
            end
            pmax=pmax(1:n);
        else
            warning(message('finance:Portfolio:mv_optim_max_return:UnsuccessfulParetoEnforcement'));
        end
    end
