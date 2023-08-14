function[d,isbounded]=mv_estimate_lower_bound(n0,A,b,lb,ub,options,obtainExactBounds)












































    if nargin<6
        error(message('finance:Portfolio:mv_estimate_lower_bound:MissingInputArgument'));
    end
    if nargin<7||isempty(obtainExactBounds)
        obtainExactBounds=false;
    end

    n=[];

    if~isempty(A)
        n=size(A,2);
        if size(b,1)==1
            b=b(:);
        end
    end

    if~isempty(lb)
        if size(lb,1)==1
            lb=lb(:);
        end
        n=size(lb,1);
    end

    if~isempty(ub)
        if size(ub,1)==1
            ub=ub(:);
        end
        n=size(ub,1);
    end

    if isempty(n)
        error(message('finance:Portfolio:mv_estimate_lower_bound:IllDefinedSet'));
    end

    isbounded=true;

    d=-Inf(n0,1);

    for i=1:n0

        if~obtainExactBounds&&~isempty(lb)&&isfinite(lb(i))&&i>1
            d(i)=lb(i);
        else
            f=zeros(n,1);
            f(i)=1;

            [x,~,exitflag]=linprog(f,A,b,[],[],lb,ub,[],options);

            if~isempty(x)
                fval=x(i);
            else
                fval=-Inf;
            end

            if exitflag<=0
                if exitflag==-2||exitflag==-5
                    isbounded=[];
                    d=NaN(n0,1);
                    break
                else
                    isbounded=false;
                end
            else
                d(i)=fval;
            end
            if~obtainExactBounds&&~isempty(lb)&&isfinite(lb(i))
                d(i)=lb(i);
            end
        end
    end
