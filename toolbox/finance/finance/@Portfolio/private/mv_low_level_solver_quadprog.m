function[x,status]=mv_low_level_solver_quadprog(H,g,A,b,solverOptions)





























    if nargin<5
        solverOptions=[];
    end

    if isempty(solverOptions)

        solverOptions=optimoptions('quadprog','Display','off','Algorithm','interior-point-convex');
    end

    [x,~,status]=quadprog(H,g,A,b,[],[],zeros(size(g)),[],[],solverOptions);
