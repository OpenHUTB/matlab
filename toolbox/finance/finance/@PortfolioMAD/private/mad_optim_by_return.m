function[pwgt,status]=mad_optim_by_return(obj,r,n,AI,bI,AE,bE,lB,uB,f0,f,x0,...
    usePresolver,solverType,solverOptions)








































    pnum=numel(r);

    Y=obj.localScenarioHandle([],[]);
    m=obj.sampleAssetMean;

    if isempty(Y)
        error(message('finance:PortfolioMAD:mad_optim_by_return:MissingScenarios'));
    end



    dY=bsxfun(@minus,Y,m(:)');

    pwgt=zeros(n,pnum);
    status=zeros(1,pnum);

    if strcmpi(obj.solverType,'fmincon')
        fhandle=@(x)mad_local_objective(x,dY);

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
    elseif strcmpi(obj.solverType,'extendedcp')||...
        strcmpi(obj.solverType,'trustregioncp')
        nX=numel(lB);
        nI=numel(bI);
        nE=numel(bE);
        gL=0;
        gU=Inf;

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

        linearCutOfMadTerm=@(x)mad_local_objective(x,dY);
        hasExtraVars=(n~=nX);
        for i=1:pnum
            bI(end)=f0-r(i);
            [x,~,status(i)]=obj.solverNLP.solve(linearCutOfMadTerm,obj.NumAssets,c,...
            AI,bI,AE,bE,lB,uB,hasExtraVars,[]);
            pwgt(:,i)=x(1:obj.NumAssets);
        end

    end
