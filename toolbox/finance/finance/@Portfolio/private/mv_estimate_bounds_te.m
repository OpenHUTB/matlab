function[glb,gub,isbounded]=mv_estimate_bounds_te(n0,A,b,lb,ub,C,xT,tauT,obtainExactBounds)










































    if nargin<8
        error(message('finance:Portfolio:mv_estimate_bounds_te:MissingInputArgument'));
    end
    if nargin<9||isempty(obtainExactBounds)
        obtainExactBounds=false;
    end

    n=[];

    if~isempty(A)
        n=size(A,2);
        if size(b,1)==1
            b=b(:);
        end
    elseif~isempty(C)
        n=size(C,1);
        [~,cholcheck]=chol(C);
        if cholcheck>0
            error(message('finance:Portfolio:mv_estimate_bounds_te:SingularTrackingErrorConstraint'));
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
        error(message('finance:Portfolio:mv_estimate_bounds_te:IllDefinedSet'));
    end

    if all(xT==0)
        x0=(1/n0)*ones(n0,1);
    else
        x0=xT;
    end
    if n>n0
        x0=[x0;zeros(n0,1)];
    end

    isbounded=true;

    glb=-Inf(n0,1);
    gub=Inf(n0,1);

    options=optimoptions('fmincon','algorithm','sqp','display','off',...
    'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
    'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);

    chandle=@(x)local_tracking_error_as_constraint(x,C,xT,tauT);

    for i=1:n0

        if~obtainExactBounds&&~isempty(lb)&&isfinite(lb(i))&&i>1
            glb(i)=lb(i);
        else
            fhandle=@(x)local_objective(x,i,1);

            [x,~,exitflag]=fmincon(fhandle,x0,A,b,[],[],lb,ub,chandle,options);

            if~isempty(x)
                fval=x(i);
            else
                fval=-Inf;
            end

            if exitflag<=0
                if exitflag==-2
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
            fhandle=@(x)local_objective(x,i,-1);

            [x,~,exitflag]=fmincon(fhandle,x0,A,b,[],[],lb,ub,chandle,options);

            if~isempty(x)
                fval=x(i);
            else
                fval=Inf;
            end

            if exitflag<=0
                if exitflag==-2
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



    function[f,df]=local_objective(x,i,s)

        n=numel(x);

        df=zeros(n,1);
        df(i)=s;

        f=df'*x;

        function[ci,ce,dci,dce]=local_tracking_error_as_constraint(x,C,xT,tauT)

            n=size(C,1);

            x=x(:);

            dx=x(1:n);

            if~isempty(xT)
                dx=dx-xT;
            end

            ci=dx'*C*dx-tauT^2;
            ce=[];

            if nargin>2
                dci=2*C*dx;
                dce=[];



                if n<numel(x)
                    dci=[dci;zeros(n,1)];
                end
            end
