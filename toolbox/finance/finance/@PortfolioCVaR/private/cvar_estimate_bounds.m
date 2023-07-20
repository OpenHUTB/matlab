function[glb,gub,isbounded]=cvar_estimate_bounds(n0,A,b,lb,ub,options,usePresolver,obtainExactBounds)











































    if nargin<6
        error(message('finance:PortfolioCVaR:cvar_estimate_bounds:MissingInputArgument'));
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
        error(message('finance:PortfolioCVaR:cvar_estimate_bounds:IllDefinedSet'));
    end

    isbounded=true;

    glb=-Inf(n0,1);
    gub=Inf(n0,1);

    for i=1:n0

        f=zeros(n,1);

        if~obtainExactBounds&&~isempty(lb)&&isfinite(lb(i))&&i>1
            glb(i)=lb(i);
        else
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
                    gub=NaN(n0,1);
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

        if~obtainExactBounds&&~isempty(ub)&&isfinite(ub(i))&&i>1
            gub(i)=ub(i);
        else
            f(i)=-1;

            [x,exitflag]=cvar_low_level_solver_linprog(f,A,b,lb,ub,usePresolver,options);

            if~isempty(x)
                fval=x(i);
            else
                fval=Inf;
            end

            if exitflag<=0
                if exitflag==-2||exitflag==-5
                    isbounded=[];
                    glb=NaN(n0,1);
                    gub=NaN(n0,1);
                    break
                else
                    isbounded=false;
                end
            else
                gub(i)=fval;
            end
            if~obtainExactBounds&&~isempty(ub)&&isfinite(ub(i))
                gub(i)=ub(i);
            end
        end
    end
