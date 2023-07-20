function[pmin,status]=cvar_optim_min_risk(obj,AI,bI,AE,bE,lB,uB,f0,f,x0,gL,gU,...
    usePresolver,solverType,solverOptions,enforcePareto)









































    n=obj.NumAssets;

    Y=obj.getScenarios;
    plevel=obj.ProbabilityLevel;

    if isempty(Y)
        error(message('finance:PortfolioCVaR:cvar_optim_min_risk:MissingScenarios'));
    end

    if isempty(plevel)
        error(message('finance:PortfolioCVaR:cvar_optim_min_risk:MissingProbabilityLevel'));
    end

    if strcmpi(obj.solverType,'cuttingplane')

        nX=numel(lB);
        nI=numel(bI);
        nE=numel(bE);

        c=[zeros(1,nX),1];

        if isempty(lB)
            lB=[-Inf(nX,1);gL];
        else
            lB=[lB;gL];
        end

        if isempty(uB)
            uB=[Inf(nX,1);gU];
        else
            uB=[uB;gU];
        end

        if~isempty(AI)
            AI=[AI,zeros(nI,1)];
        end

        if~isempty(AE)
            AE=[AE,zeros(nE,1)];
        end

        [pmin,~,~,status]=cvar_cuttingplane_solver(...
        c,AI,bI,AE,bE,lB,uB,plevel,Y,true,[],(n~=nX),[],obj.solverOptions);

    elseif strcmpi(obj.solverType,'extendedcp')||...
        strcmpi(obj.solverType,'trustregioncp')

        nX=numel(lB);
        nI=numel(bI);
        nE=numel(bE);

        c=[zeros(1,nX),1];

        if isempty(AI)
            AI=[-f',0];
        else
            AI=[AI,zeros(nI,1);-f',0];
        end

        if isempty(bI)
            bI=0;
        else
            bI=[bI;0];
        end

        if~isempty(AE)
            AE=[AE,zeros(nE,1)];
        end

        if isempty(lB)
            lB=[-Inf(nX,1);gL];
        else
            lB=[lB;gL];
        end

        if isempty(uB)
            uB=[Inf(nX,1);gU];
        else
            uB=[uB;gU];
        end

        linearCutOfCVaRTerm=@(x)cvar_function_as_objective(x,Y,plevel);
        hasExtraVars=(n~=nX);
        [pmin,~,status]=obj.solverNLP.solve(linearCutOfCVaRTerm,obj.NumAssets,c,...
        AI,bI,AE,bE,lB,uB,hasExtraVars,[]);
        pmin=pmin(1:obj.NumAssets);

    elseif strcmpi(obj.solverType,'fmincon')

        fhandle=@(x)cvar_function_as_objective(x,Y,plevel);



        [x,~,exitflag]=fmincon(fhandle,x0,AI,bI,AE,bE,lB,uB,[],obj.solverOptions);



        pmin=x(1:n);
        status=exitflag;

    end








































