function[pwgt,status]=mad_optim_by_risk(obj,risk,n,AI,bI,AE,bE,lB,uB,f,x0,...
    solverType,solverOptions)








































    Y=obj.localScenarioHandle([],[]);
    m=obj.sampleAssetMean;
    dY=bsxfun(@minus,Y,m(:)');

    pnum=numel(risk);
    pwgt=zeros(n,pnum);
    status=zeros(1,pnum);

    if strcmpi(obj.solverType,'fmincon')
        options=getFminconOptions(obj);
        objFunc=@(x)return_as_objective(f,x);

        for i=1:pnum
            consNL=@(x)risk_as_constraint(x,dY,risk(i));
            [x,~,status(i)]=fmincon(objFunc,x0(:,i),AI,bI,AE,bE,lB,uB,consNL,options);
            pwgt(:,i)=x(1:n);
        end
    elseif strcmpi(obj.solverType,'extendedcp')||...
        strcmpi(obj.solverType,'trustregioncp')
        nX=numel(lB);
        nI=numel(bI);
        nE=numel(bE);
        gL=0;
        gU=Inf;

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

        linearCutOfMadTerm=@(x)mad_local_objective(x,dY);
        hasExtraVars=(n~=nX);
        for i=1:pnum
            bI(end)=risk(i);
            [x,~,status]=obj.solverNLP.solve(linearCutOfMadTerm,obj.NumAssets,c,...
            AI,bI,AE,bE,lB,uB,hasExtraVars,[]);
            pwgt(:,i)=x(1:obj.NumAssets);
        end
    end


    function[obj,dobj]=return_as_objective(f,x)
        obj=-f'*x;

        if nargout>1
            dobj=-f;
        end



        function[ci,ce,dci,dce]=risk_as_constraint(x,dY,targetRisk)
            [ci,dci]=mad_local_objective(x,dY);
            ci=ci-targetRisk;
            ce=[];


            if nargout>2
                dce=[];
            end
