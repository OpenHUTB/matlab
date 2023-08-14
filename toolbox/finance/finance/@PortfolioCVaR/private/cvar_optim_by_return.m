function[pwgt,status]=cvar_optim_by_return(obj,r,n,AI,bI,AE,bE,lB,uB,f0,f,x0,gL,gU,...
    usePresolver,solverType,solverOptions)









































    pnum=numel(r);

    Y=obj.localScenarioHandle([],[]);
    plevel=obj.ProbabilityLevel;

    if isempty(Y)
        error(message('finance:PortfolioCVaR:cvar_optim_by_return:MissingScenarios'));
    end

    if isempty(plevel)
        error(message('finance:PortfolioCVaR:cvar_optim_by_return:MissingProbabilityLevel'));
    end

    pwgt=zeros(n,pnum);
    status=zeros(1,pnum);

    if strcmpi(obj.solverType,'cuttingplane')
        nX=numel(lB);
        nI=numel(bI);
        nE=numel(bE);

        c=[zeros(1,nX),1];

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

        if isempty(AI)
            AI=[-f',0];
        else
            AI=[AI,zeros(nI,1);-f',0];
        end

        if isempty(bI)
            bI=0;
        else
            bI=[bI;0];
        end

        if~isempty(AE)
            AE=[AE,zeros(nE,1)];
        end

        for i=1:pnum

            bI(end)=f0-r(i);

            [x,~,~,exitflag]=cvar_cuttingplane_solver(...
            c,AI,bI,AE,bE,lB,uB,plevel,Y,true,[],(n~=nX),[],obj.solverOptions);



            pwgt(:,i)=x(1:n);
            status(i)=exitflag;

        end
    elseif strcmpi(obj.solverType,'extendedcp')||...
        strcmpi(obj.solverType,'trustregioncp')
        nX=numel(lB);
        nI=numel(bI);
        nE=numel(bE);

        c=[zeros(1,nX),1];

        if isempty(AI)
            AI=[-f',0];
        else
            AI=[AI,zeros(nI,1);-f',0];
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
            bI(end)=f0-r(i);
            [x,~,status(i)]=obj.solverNLP.solve(linearCutOfCVaRTerm,obj.NumAssets,c,...
            AI,bI,AE,bE,lB,uB,hasExtraVars,[]);
            pwgt(:,i)=x(1:obj.NumAssets);
        end

    elseif strcmpi(obj.solverType,'fmincon')


        fhandle=@(x)cvar_function_as_objective(x,Y,plevel);

        if isempty(AI)
            AI=-f';
        else
            AI=[AI;-f'];
        end

        if isempty(bI)
            bI=0;
        else
            bI=[bI;0];
        end


        for i=1:pnum




            if i>2
                x0=x;
            end

            bI(end)=f0-r(i);

            [x,~,exitflag]=fmincon(fhandle,x0,AI,bI,AE,bE,lB,uB,[],obj.solverOptions);



            pwgt(:,i)=x(1:n);
            status(i)=exitflag;

        end

    end
