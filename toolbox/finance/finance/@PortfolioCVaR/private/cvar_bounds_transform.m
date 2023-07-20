function[A,b,lb,ub]=cvar_bounds_transform(obj)

























    n=obj.NumAssets;

    A=[];
    b=[];

    if~isempty(obj.AInequality)&&~isempty(obj.bInequality)

        A=[A;obj.AInequality];
        b=[b;obj.bInequality];
    end

    if~isempty(obj.AEquality)&&~isempty(obj.bEquality)


        A=[A;obj.AEquality;-(obj.AEquality)];
        b=[b;obj.bEquality;-(obj.bEquality)];
    end

    if~isempty(obj.LowerBudget)&&isfinite(obj.LowerBudget)

        A=[A;-ones(1,n)];
        b=[b;-(obj.LowerBudget)];
    end

    if~isempty(obj.UpperBudget)&&isfinite(obj.UpperBudget)

        A=[A;ones(1,n)];
        b=[b;obj.UpperBudget];
    end

    if~isempty(obj.GroupMatrix)
        if~isempty(obj.UpperGroup)

            A=[A;obj.GroupMatrix];
            b=[b;obj.UpperGroup];
        end
        if~isempty(obj.LowerGroup)

            A=[A;-(obj.GroupMatrix)];
            b=[b;-(obj.LowerGroup)];
        end
    end

    if~isempty(obj.GroupA)
        if~isempty(obj.UpperRatio)

            A=[A;(obj.GroupA-bsxfun(@times,obj.GroupB,obj.UpperRatio))];
            b=[b;zeros(size(obj.UpperRatio))];
        end
        if~isempty(obj.LowerRatio)

            A=[A;(bsxfun(@times,obj.GroupB,obj.LowerRatio)-obj.GroupA)];
            b=[b;zeros(size(obj.LowerRatio))];
        end
        ii=all(isfinite(A),2);
        A=A(ii,:);
        b=b(ii);
    end

    if sum(~isfinite(b)&(b~=Inf))>0
        error(message('finance:PortfolioCVaR:cvar_bounds_transform:InvalidUpperBoundConstraint'));
    end



    ii=isfinite(b);
    A=A(ii,:);
    b=b(ii);






    if~isempty(obj.LowerBound)
        lb=obj.LowerBound;
    else
        lb=-Inf(n,1);
    end

    if~isempty(obj.UpperBound)
        ub=obj.UpperBound;
    else
        ub=Inf(n,1);
    end








































    if~isempty(obj.BuyCost)||~isempty(obj.SellCost)...
        ||~isempty(obj.Turnover)||~isempty(obj.BuyTurnover)||~isempty(obj.SellTurnover)
        A=[A,zeros(size(A))];
        A=[A;eye(n),-eye(n)];
        b=[b;obj.InitPort];

        lb=[lb;zeros(n,1)];
        ub=[ub;Inf(n,1)];

        if~isempty(obj.Turnover)
            A=[A;-ones(1,n),2*ones(1,n)];
            b=[b;(2*(obj.Turnover)-sum(obj.InitPort))];

            if any(~isfinite(lb))
                lb=max(lb,[(obj.InitPort-2*(obj.Turnover));zeros(n,1)]);
            end
        end

        if~isempty(obj.BuyTurnover)
            A=[A;zeros(1,n),ones(1,n)];
            b=[b;obj.BuyTurnover];
        end

        if~isempty(obj.SellTurnover)
            A=[A;-ones(1,n),ones(1,n)];
            b=[b;((obj.SellTurnover)-sum(obj.InitPort))];
            if any(~isfinite(lb))&&isempty(obj.Turnover)
                lb=max(lb,[(obj.InitPort-(obj.SellTurnover));zeros(n,1)]);
            end
        end
    end



