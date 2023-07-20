function[A,b,d]=mv_base_linear(obj)




















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

    if~isempty(obj.UpperBound)

        A=[A;eye(n)];
        b=[b;obj.UpperBound];
    end

    if~isempty(obj.LowerBound)

        d=obj.LowerBound;
    else
        d=-Inf(n,1);
    end

    if sum(~isfinite(b)&(b~=Inf))>0
        error(message('finance:Portfolio:mv_base_linear:InvalidUpperBoundConstraint'));
    end



    ii=isfinite(b);

    A=A(ii,:);
    b=b(ii);
