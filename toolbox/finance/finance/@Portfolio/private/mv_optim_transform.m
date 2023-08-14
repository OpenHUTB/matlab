function[A,b,f0,f,H,g,d]=mv_optim_transform(obj)














































    n=obj.NumAssets;



    if isempty(obj.AssetMean)
        error(message('finance:Portfolio:mv_optim_transform:MissingAssetMean'));
    end

    if isempty(obj.AssetCovar)
        error(message('finance:Portfolio:mv_optim_transform:MissingAssetCovar'));
    end





    [A,b,d]=mv_base_linear(obj);



    if~isempty(obj.BuyCost)||~isempty(obj.SellCost)...
        ||~isempty(obj.Turnover)||~isempty(obj.BuyTurnover)||~isempty(obj.SellTurnover)
        augment=true;
    else
        augment=false;
    end

    if augment
        [A,b,d]=mv_augment_linear(obj,A,b,d);
    end









    if obj.checkBounds||any(~isfinite(d))
        if~isempty(obj.TrackingError)
            [glb,isbounded]=mv_estimate_lower_bound_te(obj.NumAssets,A,b,d,[],...
            obj.AssetCovar,obj.TrackingPort,obj.TrackingError);
        else
            [glb,isbounded]=mv_estimate_lower_bound(obj.NumAssets,A,b,d,[],obj.solverOptionsLP);
        end
        d(1:n)=glb;
    else
        isbounded=true;
    end

    if isempty(isbounded)
        if~isempty(obj.Turnover)||~isempty(obj.BuyTurnover)||~isempty(obj.SellTurnover)
            error(message('finance:Portfolio:mv_optim_transform:EmptySetWithTurnover'));
        else
            error(message('finance:Portfolio:mv_optim_transform:EmptySet'));
        end
    end

    if~isbounded
        error(message('finance:Portfolio:mv_optim_transform:UnboundedFromBelow'));
    end























    if augment
        if isempty(obj.RiskFreeRate)
            f0=0;
            fx=obj.AssetMean;
        else
            f0=obj.RiskFreeRate;
            fx=obj.AssetMean-(obj.RiskFreeRate)*ones(size(obj.AssetMean));
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
        H=[obj.AssetCovar,zeros(n);zeros(n),zeros(n)];
    else
        if isempty(obj.RiskFreeRate)
            f0=0;
            f=obj.AssetMean;
        else
            f0=obj.RiskFreeRate;
            f=obj.AssetMean-(obj.RiskFreeRate)*ones(size(obj.AssetMean));
        end
        H=obj.AssetCovar;
    end





















    if~isempty(A)
        b=b-A*d;
    end
    f0=f0+f'*d;
    g=H*d;



