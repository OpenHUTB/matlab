function[x,status]=mv_low_level_solver_linprog(f,A,b,lb,ub,solverOptions)





























    if nargin<6
        solverOptions=[];
    end

    if isempty(solverOptions)
        solverOptions=optimoptions('linprog','Algorithm','dual-simplex',...
        'Display','off','TolFun',1.0e-8);
    end

    [x,~,status]=linprog(f,A,b,[],[],lb,ub,[],solverOptions);
