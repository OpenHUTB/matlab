function[A,b,d]=mv_augment_linear(obj,A,b,d)

    n=obj.NumAssets;

    A=[A,zeros(size(A))];
    A=[A;eye(n),-eye(n)];
    b=[b;obj.InitPort];

    d=[d;zeros(n,1)];

    if~isempty(obj.Turnover)

        A=[A;-ones(1,n),2*ones(1,n)];
        b=[b;(2*(obj.Turnover)-sum(obj.InitPort))];
        if any(~isfinite(d))
            d=max(d,[(obj.InitPort-2*(obj.Turnover));zeros(n,1)]);
        end
    end

    if~isempty(obj.BuyTurnover)

        A=[A;zeros(1,n),ones(1,n)];
        b=[b;obj.BuyTurnover];
    end

    if~isempty(obj.SellTurnover)

        A=[A;-ones(1,n),ones(1,n)];
        b=[b;((obj.SellTurnover)-sum(obj.InitPort))];
        if any(~isfinite(d))&&isempty(obj.Turnover)
            d=max(d,[(obj.InitPort-(obj.SellTurnover));zeros(n,1)]);
        end
    end
