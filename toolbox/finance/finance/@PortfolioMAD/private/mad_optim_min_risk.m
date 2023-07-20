function[pmin,status]=mad_optim_min_risk(obj,AI,bI,AE,bE,lB,uB,f0,f,x0,...
    usePresolver,solverType,solverOptions,enforcePareto)










































    n=obj.NumAssets;

    Y=obj.getScenarios;
    m=obj.sampleAssetMean;

    if isempty(Y)
        error(message('finance:PortfolioMAD:mad_optim_min_risk:MissingScenarios'));
    end

    dY=bsxfun(@minus,Y,m(:)');

    if strcmpi(obj.solverType,'fmincon')
        fhandle=@(x)mad_local_objective(x,dY);



        [x,~,exitflag]=fmincon(fhandle,x0,AI,bI,AE,bE,lB,uB,[],obj.solverOptions);



        pmin=x(1:n);
        status=exitflag;
    elseif strcmpi(obj.solverType,'extendedcp')||...
        strcmpi(obj.solverType,'trustregioncp')
        nX=numel(lB);
        nI=numel(bI);
        nE=numel(bE);
        gL=0;
        gU=Inf;

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

        linearCutOfMadTerm=@(x)mad_local_objective(x,dY);
        hasExtraVars=(n~=nX);
        [pmin,~,status]=obj.solverNLP.solve(linearCutOfMadTerm,obj.NumAssets,c,...
        AI,bI,AE,bE,lB,uB,hasExtraVars,[]);
        pmin=pmin(1:obj.NumAssets);
    end








































