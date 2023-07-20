function[pwgt,VaR,CVaR,exitflag,bswgt]=cvar_cuttingplane_solver(...
    c,Ain,bin,Aeq,beq,lb,ub,VaRLevel,scenarios,...
    minRiskProblem,CVaRLimit,buySellVars,x0,options)












































































    if isfield(options,'MaxIter')
        if~internal.finance.naturalcheck(options.MaxIter)
            error(message('finance:PortfolioCVaR:cvar_cuttingplane_solver:InvalidMaxIter'))
        else
            maxIter=round(options.MaxIter);
        end
    else
        maxIter=1000;
    end

    if isfield(options,'AbsTol')
        if isempty(options.AbsTol)||options.AbsTol<=0
            error(message('finance:PortfolioCVaR:cvar_cuttingplane_solver:InvalidAbsTol'))
        else
            absTol=options.AbsTol;
        end
    else
        absTol=1e-6;
    end

    if isfield(options,'RelTol')
        if isempty(options.RelTol)||options.RelTol<=0
            error(message('finance:PortfolioCVaR:cvar_cuttingplane_solver:InvalidRelTol'))
        else
            relTol=options.RelTol;
        end
    else
        relTol=1e-5;
    end

    if isfield(options,'MasterSolverOptions')
        masterSolverOptions=options.MasterSolverOptions;
    else
        masterSolverOptions=optimoptions('linprog','Algorithm','Dual-Simplex','Display','off');
    end
    if~(isa(masterSolverOptions,'optim.options.SolverOptions')||isstruct(masterSolverOptions))
        error(message('finance:PortfolioCVaR:cvar_cuttingplane_solver:InvalidMasterSolverOptions'))
    end

    if isstruct(masterSolverOptions)&&~isfield(masterSolverOptions,'TolFun')
        masterSolverOptions.TolFun=[];
    end

    iter=1;
    exitflag=1;

    absGap=Inf;
    relGap=Inf;

    absTolChange=absTol*absTol;
    relTolChange=relTol*relTol;

    [nScen,nAssets]=size(scenarios);

    ka=ceil(VaRLevel*nScen);
    c1=(ka-VaRLevel*nScen);
    c2=nScen*(1-VaRLevel);

    if buySellVars
        cutBswgt=zeros(1,length(nAssets+1:2*nAssets));
    else
        cutBswgt=[];
    end

    if minRiskProblem
        cutPadding=[cutBswgt,-1];
    else
        cutPadding=cutBswgt;
    end

    nIneq=size(Ain,1);
    Ain=[Ain;zeros(maxIter,length(c))];
    if minRiskProblem
        bin=[bin;zeros(maxIter,1)];
    else
        bin=[bin;CVaRLimit*ones(maxIter,1)];
    end

    VaR=NaN;
    CVaR=NaN;



    while(iter<=maxIter)

        if(iter>1)||(isempty(x0))
            [xMaster,~,masterExitFlag,masterOutput]=...
            linprog(c,Ain(1:nIneq,:),bin(1:nIneq),...
            Aeq,beq,lb,ub,[],masterSolverOptions);
        else
            xMaster=x0(:);
        end

        if(masterExitFlag<0)
            alg=masterOutput.algorithm;
            tol=masterSolverOptions.TolFun;
            if strcmpi(alg,'simplex')
                if isempty(tol)
                    tol=1e-6;
                end
                while(tol>1e-10)&&(masterExitFlag<0)
                    tol=1e-2*tol;
                    masterSolverOptions.TolFun=tol;
                    [xMaster,~,masterExitFlag]=...
                    linprog(c,Ain(1:nIneq,:),bin(1:nIneq),...
                    Aeq,beq,lb,ub,[],masterSolverOptions);
                end
            elseif strcmpi(alg,'interior-point')
                if isempty(tol)
                    tol=1e-8;
                end
                while(tol<1e-6)&&(masterExitFlag<0)
                    tol=10*tol;
                    masterSolverOptions.TolFun=tol;
                    [xMaster,~,masterExitFlag]=...
                    linprog(c,Ain(1:nIneq,:),bin(1:nIneq),...
                    Aeq,beq,lb,ub,[],masterSolverOptions);
                end
            end
            if(masterExitFlag<0)
                exitflag=-1;
                break;
            end
        end


        portLosses=-scenarios*xMaster(1:nAssets);
        [~,iSortedLosses]=sort(portLosses);
        VaR=portLosses(iSortedLosses(ka));
        if ka<nScen
            CVaR=(c1*VaR+sum(portLosses(iSortedLosses(ka+1:nScen))))/c2;
        else
            CVaR=VaR;
        end

        if minRiskProblem
            gapLB=xMaster(end);
        else
            gapLB=CVaRLimit;
        end

        absGapOld=absGap;
        relGapOld=relGap;
        absGap=CVaR-gapLB;
        relGap=absGap/max(abs(gapLB),relTol);




        if(absGap<=absTol||relGap<=relTol)
            exitflag=1;
            break;
        elseif(abs(absGapOld-absGap)<=absTolChange&&...
            abs(relGapOld-relGap)<=relTolChange)
            exitflag=2;
            break;
        end



        nIneq=nIneq+1;
        if ka<nScen
            Ain(nIneq,:)=[-(c1*scenarios(iSortedLosses(ka),:)+...
            sum(scenarios(iSortedLosses(ka+1:nScen),:),1))/c2,cutPadding];
        else
            Ain(nIneq,:)=[-scenarios(iSortedLosses(ka),:),cutPadding];
        end

        iter=iter+1;

    end

    pwgt=full(xMaster(1:nAssets));

    if(exitflag<0)
        error(message('finance:PortfolioCVaR:cvar_cuttingplane_solver:CouldNotSolve'))
    end

    if(iter>maxIter)
        warning(message('finance:PortfolioCVaR:cvar_cuttingplane_solver:DidNotConverge'))
        exitflag=0;
    end

    if buySellVars&&(nargout>4)
        if(exitflag<0)
            bswgt=NaN(nAssets,1);
        else
            bswgt=full(xMaster(nAssets+1:2*nAssets));
        end
    end



