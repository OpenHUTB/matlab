function[pwgt,status]=mv_optim_by_return(r,n,A,b,f0,f,H,g,d,solverType,solverOptions)










































    pnum=numel(r);

    pwgt=zeros(n,pnum);
    status=zeros(1,pnum);

    for i=1:pnum
        if strcmpi(solverType,'lcprog')
            [z,status(i)]=mv_low_level_solver_lcprog(H,g,[A;-f'],[b;(f0-r(i))],...
            solverOptions);
        elseif strcmpi(solverType,'quadprog')
            [z,status(i)]=mv_low_level_solver_quadprog(H,g,[A;-f'],[b;(f0-r(i))],...
            solverOptions);
        end

        z=z+d;
        pwgt(:,i)=z(1:n);
    end
