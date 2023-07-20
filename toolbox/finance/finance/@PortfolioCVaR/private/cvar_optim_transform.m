function[AI,bI,AE,bE,lB,uB,f0,f,x0]=cvar_optim_transform(obj)















































    n=obj.NumAssets;

    AI=[];
    bI=[];
    AE=[];
    bE=[];
    lB=[];
    uB=[];



    if~isempty(obj.AInequality)&&~isempty(obj.bInequality)

        AI=[AI;obj.AInequality];
        bI=[bI;obj.bInequality];
    end

    if~isempty(obj.AEquality)&&~isempty(obj.bEquality)


        AE=[AE;obj.AEquality];
        bE=[bE;obj.bEquality];
    end

    if~isempty(obj.LowerBudget)&&isfinite(obj.LowerBudget)

        AI=[AI;-ones(1,n)];
        bI=[bI;-(obj.LowerBudget)];
    end

    if~isempty(obj.UpperBudget)&&isfinite(obj.UpperBudget)

        AI=[AI;ones(1,n)];
        bI=[bI;obj.UpperBudget];
    end

    if~isempty(obj.GroupMatrix)
        if~isempty(obj.UpperGroup)

            AI=[AI;obj.GroupMatrix];
            bI=[bI;obj.UpperGroup];
        end
        if~isempty(obj.LowerGroup)

            AI=[AI;-(obj.GroupMatrix)];
            bI=[bI;-(obj.LowerGroup)];
        end
    end

    if~isempty(obj.GroupA)
        if~isempty(obj.UpperRatio)

            AI=[AI;(obj.GroupA-bsxfun(@times,obj.GroupB,obj.UpperRatio))];
            bI=[bI;zeros(size(obj.UpperRatio))];
        end
        if~isempty(obj.LowerRatio)

            AI=[AI;(bsxfun(@times,obj.GroupB,obj.LowerRatio)-obj.GroupA)];
            bI=[bI;zeros(size(obj.LowerRatio))];
        end
        ii=all(isfinite(AI),2);
        AI=AI(ii,:);
        bI=bI(ii);
    end

    if~isempty(obj.UpperBound)

        uB=obj.UpperBound;
    end

    if sum(~isfinite(bI)&(bI~=Inf))>0
        error(message('finance:PortfolioCVaR:cvar_optim_transform:InvalidUpperBoundConstraint'));
    end



    ii=isfinite(bI);
    AI=AI(ii,:);
    bI=bI(ii);






    if~isempty(obj.LowerBound)
        lB=obj.LowerBound;
    else
        lB=-Inf(n,1);
    end





    if isempty(obj.sampleAssetMean)
        error(message('finance:PortfolioCVaR:cvar_optim_transform:MissingScenarios'));
    end

















































    if~isempty(obj.BuyCost)||~isempty(obj.SellCost)...
        ||~isempty(obj.Turnover)||~isempty(obj.BuyTurnover)||~isempty(obj.SellTurnover)
        AI=[AI,zeros(size(AI))];
        AI=[AI;eye(n),-eye(n)];
        bI=[bI;obj.InitPort];

        AE=[AE,zeros(size(AE))];

        lB=[lB;zeros(n,1)];
        if~isempty(obj.UpperBound)
            uB=[obj.UpperBound;Inf(n,1)];
        else
            uB=Inf(2*n,1);
        end

        if~isempty(obj.Turnover)
            AI=[AI;-ones(1,n),2*ones(1,n)];
            bI=[bI;(2*(obj.Turnover)-sum(obj.InitPort))];

            if any(~isfinite(lB))
                lB=max(lB,[(obj.InitPort-2*(obj.Turnover));zeros(n,1)]);
            end




        end

        if~isempty(obj.BuyTurnover)
            AI=[AI;zeros(1,n),ones(1,n)];
            bI=[bI;obj.BuyTurnover];








        end

        if~isempty(obj.SellTurnover)
            AI=[AI;-ones(1,n),ones(1,n)];
            bI=[bI;((obj.SellTurnover)-sum(obj.InitPort))];

            if any(~isfinite(lB))&&isempty(obj.Turnover)
                lB=max(lB,[(obj.InitPort-(obj.SellTurnover));zeros(n,1)]);
            end








        end
    end









    if obj.checkBounds||any(~isfinite(lB))
        [glb,isbounded]=cvar_estimate_lower_bound(obj.NumAssets,[AI;AE;-AE],[bI;bE;-bE],...
        lB,uB,obj.solverOptionsLP,obj.usePresolver);
        lB(1:n)=glb;



    else
        isbounded=true;
    end

    if isempty(isbounded)
        if~isempty(obj.Turnover)||~isempty(obj.BuyTurnover)||~isempty(obj.SellTurnover)
            error(message('finance:PortfolioCVaR:cvar_optim_transform:EmptySetWithTurnover'));
        else
            error(message('finance:PortfolioCVaR:cvar_optim_transform:EmptySet'));
        end
    end

    if~isbounded
        error(message('finance:PortfolioCVaR:cvar_optim_transform:UnboundedFromBelow'));
    end























    if~isempty(obj.BuyCost)||~isempty(obj.SellCost)...
        ||~isempty(obj.Turnover)||~isempty(obj.BuyTurnover)||~isempty(obj.SellTurnover)
        if isempty(obj.RiskFreeRate)
            f0=0;
            fx=obj.sampleAssetMean;
        else
            f0=obj.RiskFreeRate;
            fx=obj.sampleAssetMean-(obj.RiskFreeRate)*ones(size(obj.sampleAssetMean));
        end
        fy=zeros(n,1);
        if~isempty(obj.BuyCost)
            fy=fy-obj.BuyCost;
        end
        if~isempty(obj.SellCost)
            f0=f0-(obj.SellCost)'*(obj.InitPort);
            fx=fx+obj.SellCost;
            fy=fy-obj.SellCost;
        end
        f=[fx;fy];
    else
        if isempty(obj.RiskFreeRate)
            f0=0;
            f=obj.sampleAssetMean;
        else
            f0=obj.RiskFreeRate;
            f=obj.sampleAssetMean-(obj.RiskFreeRate)*ones(size(obj.sampleAssetMean));
        end
    end











    n=numel(lB);

    [x0,~,exitflag]=linprog(ones(n,1),AI,bI,AE,bE,lB,uB,[],obj.solverOptionsLP);

    if exitflag<0
        if n>obj.NumAssets
            x0=rand(obj.NumAssets,1);
            x0=[(1/sum(x0))*x0;zeros(obj.NumAssets,1)];
        else
            x0=rand(n,1);
            x0=(1/sum(x0))*x0;
        end
    end
