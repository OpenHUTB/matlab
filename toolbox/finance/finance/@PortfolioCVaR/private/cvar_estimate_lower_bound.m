function[glb,isbounded]=cvar_estimate_lower_bound(n0,A,b,lb,ub,options,usePresolver,obtainExactBounds)












































    if nargin<6
        error(message('finance:PortfolioCVaR:cvar_estimate_lower_bound:MissingInputArgument'));
    end
    if nargin<7||isempty(usePresolver)
        usePresolver=false;
    end
    if nargin<8||isempty(obtainExactBounds)
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
        error(message('finance:PortfolioCVaR:cvar_estimate_lower_bound:IllDefinedSet'));
    end

    isbounded=true;

    glb=-Inf(n0,1);

    for i=1:n0

        if~obtainExactBounds&&~isempty(lb)&&isfinite(lb(i))&&i>1
            glb(i)=lb(i);
        else
            f=zeros(n,1);
            f(i)=1;

            [x,exitflag]=cvar_low_level_solver_linprog(f,A,b,lb,ub,usePresolver,options);

            if~isempty(x)
                fval=x(i);
            else
                fval=-Inf;
            end

            if exitflag<=0
                if exitflag==-2||exitflag==-5
                    isbounded=[];
                    glb=NaN(n0,1);
                    break
                else
                    isbounded=false;
                end
            else
                glb(i)=fval;
            end
            if~obtainExactBounds&&~isempty(lb)&&isfinite(lb(i))
                glb(i)=lb(i);
            end
        end
    end
