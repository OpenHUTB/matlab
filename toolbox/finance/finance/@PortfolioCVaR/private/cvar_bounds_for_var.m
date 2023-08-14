function[gL,gU]=cvar_bounds_for_var(obj)













    [glb,gub,isbounded]=obj.estimateBounds(false);

    if~isbounded
        error(message('finance:PortfolioCVaR:cvar_bounds_for_var:UnboundedProblem'))
    end

    Y=obj.localScenarioHandle([],[]);

    yL=min(Y,[],1)';
    yU=max(Y,[],1)';

    yx=[-yL.*glb,-yU.*glb,-yL.*gub,-yU.*gub];

    gL=sum(min(yx,[],2));
    gU=sum(max(yx,[],2));
