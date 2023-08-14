function[pwgt,status]=cvar_optim_by_risk(obj,r,n,AI,bI,AE,bE,lB,uB,f0,f,x0,...
    usePresolver,solverType,solverOptions)









































    pnum=numel(r);

    Y=obj.localScenarioHandle([],[]);
    plevel=obj.ProbabilityLevel;

    if isempty(Y)
        error(message('finance:PortfolioCVaR:cvar_optim_by_risk:MissingScenarios'));
    end

    if isempty(plevel)
        error(message('finance:PortfolioCVaR:cvar_optim_by_risk:MissingProbabilityLevel'));
    end

    pwgt=zeros(n,pnum);
    status=zeros(1,pnum);

    if strcmpi(obj.solverType,'cuttingplane')

        nX=numel(lB);

        if isempty(lB)
            lB=-Inf(nX,1);
        end

        if isempty(uB)
            uB=Inf(nX,1);
        end

        for i=1:pnum

            [x,~,~,exitflag]=cvar_cuttingplane_solver(...
            -f,AI,bI,AE,bE,lB,uB,plevel,Y,false,r(i),(n~=nX),[],obj.solverOptions);



            pwgt(:,i)=x(1:n);
            status(i)=exitflag;

        end
    elseif strcmpi(obj.solverType,'extendedcp')||...
        strcmpi(obj.solverType,'trustregioncp')
        nX=numel(lB);
        nI=numel(bI);
        nE=numel(bE);
        [gL,gU]=cvar_bounds_for_var(obj);

        c=[-f',0];

        if isempty(AI)
            AI=[zeros(1,nX),1];
        else
            AI=[AI,zeros(nI,1);zeros(1,nX),1];
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

        linearCutOfCVaRTerm=@(x)cvar_function_as_objective(x,Y,plevel);
        hasExtraVars=(n~=nX);
        for i=1:pnum
            bI(end)=r(i);
            [x,~,status]=obj.solverNLP.solve(linearCutOfCVaRTerm,obj.NumAssets,c,...
            AI,bI,AE,bE,lB,uB,hasExtraVars,[]);
            pwgt(:,i)=x(1:obj.NumAssets);
        end

    elseif strcmpi(obj.solverType,'fmincon')

        for i=1:pnum
            if i>2
                x0=x;
            end



            localOptions=optimoptions(obj.solverOptions,'GradObj','off');

            [x,~,exitflag]=fmincon(@(x)(-f'*x),x0,AI,bI,AE,bE,lB,uB,...
            @(x)cvar_function_as_constraint(x,Y,plevel,r(i)),localOptions);



            pwgt(:,i)=x(1:n);
            status(i)=exitflag;
        end

    end
