function[X,Lambda,debugOutput]=lanczos(K,M,opts)




























    if nargin<2

        error(message('MATLAB:lanczos:NeedKM'));
    end
    if nargin<3

        error(message('MATLAB:lanczos:NoOpts'));
    end

    if~isstruct(opts)
        error(message('MATLAB:lanczos:NoOpts'));
    end

    if~isa(K,'double')||~isa(M,'double')||...
        ~issparse(K)||~issparse(M)
        error(message('MATLAB:lanczos:KMSparseDouble'));
    end
    n=size(K,1);
    if~isequal(size(K),[n,n])||~isequal(size(M),[n,n])
        error(message('MATLAB:lanczos:NotSquare'));
    end

    opts=setOpts(K,M,opts);
    bs=opts.BlockSize;
    reuseShift=false;

    randStr=RandStream('mt19937ar','Seed',1);













    defaultSentinels=[-opts.shiftScale/10,Inf];







    intervalList=[-Inf,Inf,0,n,defaultSentinels];


    endpointRatio=[0,0];
    for ii=1:2
        shift=opts.FrequencyRange(ii);
        if isfinite(shift)
            [~,~,~,~,sturm,~,endpointRatio(ii)]=getFactor(K-shift*M);
            sentinel=shift;
        elseif shift==-Inf
            sturm=0;
            sentinel=defaultSentinels(1);
        else
            sturm=n;
            sentinel=defaultSentinels(2);
        end
        intervalList(ii+[0,2,4])=[shift,sturm,sentinel];
    end


    X=[];
    Lambda=[];
    RB=[];
    exitcodes=zeros(1,opts.MaxShift);
    expectAll=true;

    numShifts=max([numel(opts.Shifts),...
    numel(opts.need),numel(opts.needL),numel(opts.needR)]);
    if numShifts<1
        numShifts=opts.MaxShift;
    end


    [intervalCode,intervalList]=analyzeIntervals(intervalList,Lambda);
    if intervalCode~=0
        numShifts=0;
    end

    for shiftNumber=1:numShifts

        if~reuseShift
            [shiftList,need,needL,needR,range,ii]=...
            getRecurrenceParameters(shiftNumber,Lambda,intervalList,opts);
        end
        if any(isfinite([need,needL,needR]))
            expectAll=false;
        end


        shift=[];
        for shiftInd=1:numel(shiftList)

            sigma=shiftList(shiftInd);
            [fL,fD,fP,fS,sturm,maxfront,factorDiagRatio]=getFactor(K-sigma*M);
            if factorDiagRatio>opts.factorDiagTol
                if opts.debug>0
                    disp(getString(message('MATLAB:lanczos:FactorizationFailed',...
                    shiftInd,numel(shiftList),...
                    num2str(factorDiagRatio),num2str(sigma))));
                end
            else
                shift=sigma;
                break
            end
        end
        if isempty(shift)
            error(message('MATLAB:lanczos:BadFactor'));
        end


        [intervalList,ii]=splitIntervals(intervalList,ii,shift,sturm);






        if~all(isfinite([need,needL,needR]))


            lf=intervalList(ii(1),1);
            rf=intervalList(ii(end),2);
            nfound=nnz(Lambda>=lf&Lambda<=rf);
            nneed=intervalList(ii(end),4)-intervalList(ii(1),3)-nfound;
            need=min(nneed,need);
        end
        if any(isnan(range))||isempty(range)
            ll=intervalList(ii(1),5);
            rr=intervalList(ii(end),6);
            range=[ll,rr];
        end
        if range(2)<=range(1)
            range=[intervalList(ii(1),1),intervalList(ii(end),2)];
        end

        p=(Lambda>range(1)&Lambda<range(2));
        soX=X(:,p);
        soL=Lambda(p);
        soRB=RB(p,:);

        if opts.debug>0
            disp(getString(message('MATLAB:lanczos:BeginningBanner',...
            shiftNumber,need,num2str(needL),num2str(needR),...
            num2str(range(1)),num2str(range(2)))));
            if opts.debug>1
                disp(getString(message('MATLAB:lanczos:BeginningLanczosParameters',...
                num2str(shift),sturm,num2str(factorDiagRatio),...
                bs,num2str(opts.minStep),num2str(opts.maxStep),numel(soL))));
            end
            fprintf('\n');


            if numel(soL)>0&&opts.debug>2
                disp(getString(message('MATLAB:lanczos:BeginningSOTitle')));
                for k=1:numel(soL)
                    fprintf(' %16.8e %16.8e %16.8e\n',...
                    soL(k),soRB(k,2),soRB(k,1));
                end
                fprintf('\n');
            end
        end


        q1=opts.q1;
        if~isequal(size(q1),[n,bs])
            q1=randn(randStr,n,bs);
        end
        q1=selectiveReorth(q1,M*q1,soX);

        if opts.UseERC

            q1=fS*fP*(fL'\(fD\(fL\(fP'*(fS*(M*q1))))));
        end
        [q1,~,exitcode]=MQR(q1,M,opts.Bsmall,opts.Bcond,opts.Breorth);
        if exitcode~=0





            error(message('MATLAB:lanczos:MassIndefinite'));
        end

        [V,D,RB1,Q,Tup,Alpha,tau,tau_act,sl,sr,...
        exitcodes(shiftNumber),newbs,convInfo]=...
        recurrence(M,q1,soX,soL,soRB,shift,range,...
        need,needL,needR,fL,fD,fP,fS,maxfront,opts);


        D1=shift+1./diag(D);
        [D1,p]=sort(D1);
        V1=V(:,p);
        RB1=RB1(p,:);


        if~isempty(Alpha)&&~isempty(D)&&opts.refineSO
            denom=diag(D)'-(1./(soL-shift));
            AV=Alpha*V(1:size(Alpha,2),:);
            Beta=AV./denom;


            Beta(opts.tauTol*abs(denom)<=abs(AV))=0;


            newX=Q*V1+soX*Beta(:,p);
        else
            newX=Q*V1;
        end


        if opts.UseERC
            if~isempty(newX)
                newX=fS*fP*(fL'\(fD\(fL\(fP'*(fS*(M*newX))))));
                nn=sum(newX.*(M*newX),1);
                newX=newX./sqrt(nn);
            end
        end
        X=[X,newX];%#ok<AGROW>
        Lambda=[Lambda;D1];%#ok<AGROW>
        RB=[RB;RB1];%#ok<AGROW>



        debugOutput.shifts(shiftNumber)=shift;
        debugOutput.Tresiduals{shiftNumber}=vecnorm(Tup*V-V*D,2,1);
        debugOutput.tau{shiftNumber}=tau;

        if opts.expensiveDebug

            debugOutput.tau_actual{shiftNumber}=tau_act;

            recurrenceRes=(K-shift*M)\(M*Q)-Q*Tup;
            if~isempty(Alpha)&&~isempty(D)
                sa2=1:size(Alpha,2);
                recurrenceRes(:,sa2)=recurrenceRes(:,sa2)-soX*Alpha;
            end
            debugOutput.residuals{shiftNumber}=...
            vecnorm(recurrenceRes,2,1);
            debugOutput.KMresiduals{shiftNumber}=...
            vecnorm(K*newX-M*newX*diag(D1),2,1);
        end






        sl(sl<=max(intervalList(ii(1),[1,5])))=[];
        sr(sr>=min(intervalList(ii(end),[2,6])))=[];


        intervalList(ii(1),6)=min([intervalList(ii(1),6),sl]);

        intervalList(ii(end),5)=max([intervalList(ii(end),5),sr]);


        [intervalCode,intervalList]=analyzeIntervals(intervalList,Lambda);
        if opts.debug>0
            displayIntervals(intervalList,Lambda);
        end

        if intervalCode~=0
            break
        end


        reuseShift=false;
        if isempty(D)
            [intervalList,bs,reuseShift]=avoidStagnation(intervalList,...
            ii,bs,newbs,convInfo,opts);
        end
    end


    displayTerminationMessage(intervalCode,opts,expectAll,...
    endpointRatio>opts.factorDiagTol);

    exitcodes(shiftNumber+1:end)=[];
    debugOutput.exitcodes=exitcodes(1:shiftNumber);


    [Lambda,p]=sort(Lambda);
    ll=(Lambda<=intervalList(end,2)&Lambda>=intervalList(1,1));
    Lambda=Lambda(ll);
    p=p(ll);
    X=X(:,p);

end



function[V,D,RB,Q,Tup,Alpha,tau,SOact,sl,sr,exitcode,newbs,convInfo]=...
    recurrence(M,q1,soVec,soVal,soRB,shift,range,need,needL,needR,...
    fL,fD,fP,fS,maxfront,opts)


    omega(2,1)=opts.omegaEps;
    exitcode=0;


    V=[];
    D=[];
    res=[];
    convInfo=struct('converged',[]);


    npro=0;
    TT=[];


    [n,bs]=size(q1);
    newbs=bs;
    qk=q1;
    Mqk=M*qk;
    qkm1=[];
    Bk=[];
    Q=[];
    MQ=[];
    T=[];
    Tup=[];


    Alpha=[];
    tau=ones(size(soVec,2),1)*opts.tauEps;
    flagSO=~isempty(soVec);
    if opts.expensiveDebug&&~isempty(soVec)
        SOact=vecnorm(soVec'*Mqk,2,2);
    else
        SOact=[];
    end


    TotalCostFcn=CreateCostFcn(n,nnz(M),nnz(fL),bs,maxfront,opts.refineU,4);


    excessCost=0;

    nstep=min(opts.maxStep,n/bs);

    for k=1:nstep














        r=fS*fP*(fL'\(fD\(fL\(fP'*(fS*Mqk)))));

        if~isempty(qkm1)
            r=r-qkm1*Bk';
        end

        Ak=Mqk'*r;
        Ak=(Ak+Ak')/2;

        r=r-qk*Ak;


        QRcond=opts.Bcond;
        reorthTol=opts.Breorth;

        tb=[max([0;abs(diag(D))]),norm(Bk);norm(Bk),norm(Ak)];
        QRsmall=opts.Bsmall*norm(tb);








        [qkp1,Bkp1,exitcode,newbs]=MQR(r,M,QRsmall,QRcond,reorthTol);

        if exitcode~=0&&opts.debug>0
            disp(getString(message('MATLAB:lanczos:QRFailedKp1',exitcode)));
            fprintf('\n');
        end

        if exitcode==-1






            flagSO=false;
            flagReorth=false;
        elseif exitcode<-1


            break
        else

            [TT,omega]=updateOmega(TT,omega,Ak,Bk,Bkp1,k,opts.omegaEps);
            flagReorth=(k>1&&(max(omega(k+1,:))>opts.omegaTol));
        end



        if flagReorth
            npro=npro+1;

            [omega,f,qk,Mqk,Aku,Bku,r,g]=partialReorthSweep(k,bs,omega,...
            qk,Mqk,r,M,Q,MQ,QRsmall,QRcond,reorthTol,opts);
            [qkp1,Bkp1,exitcode,newbs]=MQR(r,M,QRsmall,QRcond,reorthTol);
            if exitcode~=0
                if opts.debug>0
                    disp(getString(message('MATLAB:lanczos:ProQRFailedKp1')));
                    fprintf('\n');
                end
                break
            end
        end


        if flagReorth

            Tupnew=updateTup(Tup,k,bs,f,g,Ak,Bk,Aku,Bku);
        else

            Tupnew=updateT(Tup,k,Ak,Bk);
        end







        if flagSO
            tau=updateTau(tau,Tupnew,Bkp1,shift,soVec,soVal,soRB,Alpha);
            [Alpha1,tau,r1]=selectiveR(Alpha,k,bs,soVec,M,r,tau,opts);
            if~isempty(r1)

                [qkp1,Bkp1,exitcode]=MQR(r1,M,QRsmall,QRcond,reorthTol);
                if exitcode~=0
                    if opts.debug>0
                        disp(getString(message('MATLAB:lanczos:SoQRFailedKp1')));
                        fprintf('\n');
                    end
                    break
                end
                Alpha=Alpha1;
            end
            if opts.expensiveDebug
                SOact(:,k+1)=vecnorm(soVec'*M*qkp1,2,2);
            end
        end







        if flagReorth&&opts.updateAk
            Ak=Ak+Aku;Ak=(Ak+Ak')/2;
        end
        T=updateT(T,k,Ak,Bk);
        Tup=Tupnew;
        Q=[Q,qk];%#ok<AGROW>
        MQ=[MQ,Mqk];%#ok<AGROW>
        Mqkp1=M*qkp1;


        [V,D,res,~,convInfo,exitcode,excessCost]=endRecurrence...
        (k,T,Tup,Bkp1,shift,range,opts,exitcode,need,needL,needR,...
        excessCost,TotalCostFcn);


        if exitcode~=0,break;end


        qkm1=qk;
        qk=qkp1;
        Mqk=Mqkp1;
        Bk=Bkp1;
    end




    converged=convInfo.converged;
    [sl,sr]=getSentinels(D,res+eps*max(abs(diag(D))),converged,shift);
    V=V(:,converged);
    D=D(converged,converged);
    RB=[res(converged)'+eps*max(abs(diag(D))),...
    shift*ones(nnz(converged'),1)];





    if opts.debug>0
        disp(getString(message('MATLAB:lanczos:SummaryBanner',...
        exitcode,nnz(converged),num2str(sl),num2str(sr),k,npro)));
        fprintf('\n');
    end





    scaleFactor=sum((MQ*V).*(Q*V),1).^-0.5;
    V=V*diag(scaleFactor);
end



function opts=setOpts(K,M,inputopt)

    opts.BlockSize=floor(size(K,1)/1000);
    opts.BlockSize=max(7,min(opts.BlockSize,25));
    opts.BlockSize=min(opts.BlockSize,size(K,1));
    opts.maxStep=100;
    opts.MaxShift=100;
    opts.minStep=15;
    opts.debug=0;
    opts.expensiveDebug=false;
    opts.q1=[];


    opts.FrequencyRange=[-Inf,Inf];




    opts.range=[];
    opts.Shifts=[];
    opts.need=[];
    opts.needL=[];
    opts.needR=[];














    opts.PROqk=false;
    opts.PROtwice=false;
    opts.updateAk=true;
    opts.updateBk=true;
    opts.omegaTol=1.e-8;
    opts.refineU=2;
    opts.factorDiagTol=1.e10;


    opts.refineSO=true;
    opts.tauTol=1.e-8;


    opts.expConvRate=5;
    opts.expLookahead=2;
    opts.expConsecutive=2;


    opts.convTol=eps^(2/3);
    opts.Bsmall=eps^(2/3);
    opts.Bcond=1/eps;

    if~isempty(inputopt)
        for fn=fieldnames(inputopt)'
            if~isempty(inputopt.(fn{1}))
                opts.(fn{1})=inputopt.(fn{1});
            end
        end
    end
    opts.FrequencyRange=double(opts.FrequencyRange);


    n=size(K,1);
    bs=opts.BlockSize;
    if isempty(inputopt)||~isfield(inputopt,'omegaEps')
        opts.omegaEps=eps*bs*sqrt(n);
    end
    if isempty(inputopt)||~isfield(inputopt,'tauEps')
        opts.tauEps=eps*bs*sqrt(n);
    end
    if isempty(inputopt)||~isfield(inputopt,'Breorth')

        opts.Breorth=opts.omegaEps/(2*sqrt(n)*bs*eps);
    end
    if isempty(inputopt)||~isfield(inputopt,'target')

        opts.target=10*bs;
    end
    if isempty(inputopt)||~isfield(inputopt,'Bsmall')


        opts.Bsmall=min(opts.Bsmall,opts.convTol);
    end


    if~isfield(inputopt,'UseERC')
        opts.UseERC=~all(any(M));
    end
    if isempty(inputopt)||~isfield(inputopt,'shiftScale')
        opts.shiftScale=shiftScale(K,M);
    end
end



function[shift,need,needL,needR,range,interval]=...
    getRecurrenceParameters(shiftNumber,Lambda,intervalList,opts)



    shift=nth(opts.Shifts);
    need=nth(opts.need);
    needL=nth(opts.needL);
    needR=nth(opts.needR);
    if isempty(opts.range)
        range=[];
    else
        range=opts.range(min(shiftNumber,size(opts.range,1)),:);
    end


    if isfinite(shift)

        interval=find(shift>=intervalList(:,1)&shift<=intervalList(:,2));
        assert(numel(interval)<3);
        if isempty(interval)
            error(message('MATLAB:lanczos:OutsideShift'));
        end
    else

        zz=histcounts(Lambda,[intervalList(1,1);intervalList(:,2)]);
        needlist=intervalList(:,4)'-intervalList(:,3)'-zz;
        interval=find(needlist>0,1);


        il=max(intervalList(interval,[1,5]));
        ir=min(intervalList(interval,[2,6]));

        if isfinite(ir-il)


            ratio=min(1/2,opts.target/needlist(interval));
            delta=(ir-il)*ratio;
        else


            delta=opts.shiftScale;
        end


        shift=[il,ir,0];
        shift=shift(find(isfinite(shift),1));



        sgn=1-2*(shift+delta>ir);


        ssc=min((ir-il)/400,opts.shiftScale);
        shift=shift+sgn*(delta+ssc*[0,9,99]);


        shift=shift(shift<intervalList(interval,2)...
        &shift>intervalList(interval,1));
        assert(numel(shift)>0);
    end

    function v1=nth(v)
        if isscalar(v)
            v1=v;
        elseif isempty(v)
            v1=Inf;
        else
            v1=v(shiftNumber);
        end
    end
end



function[intervalList,ii]=splitIntervals(intervalList,ii,shift,sturm)



    assert(isequal(ii(:),...
    find(shift>=intervalList(:,1)&shift<=intervalList(:,2))));

    if numel(ii)==1

        intervalList(ii+1:end+1,:)=intervalList(ii:end,:);



        intervalList(ii,2)=shift;
        intervalList(ii,4)=sturm;

        intervalList(ii+1,1)=shift;
        intervalList(ii+1,3)=sturm;






        ii=[ii,ii+1];
    end

end



function[ec,intervalList]=analyzeIntervals(intervalList,Lambda)






    toFind=intervalList(:,4)-intervalList(:,3)-...
    histcounts(Lambda,[intervalList(1,1);intervalList(:,2)])';




    if any(toFind<0)
        ec=-1;
    elseif all(toFind<1)
        ec=1;
    else
        ec=0;
    end

end



function displayProgress(k,convInfo,res,D,shift,opts)


    converged=convInfo.converged;
    convergedL=convInfo.L;
    convergedR=convInfo.R;
    if opts.debug>0
        disp(getString(message('MATLAB:lanczos:ProgressBanner',...
        k,nnz(converged),convergedL,convergedR)));


        if opts.debug>2||(opts.debug>1&&any(converged))
            disp(getString(message('MATLAB:lanczos:ProgressEvalTitle')));
            for j=1:length(res)
                if converged(j)
                    fprintf('   %16.8e  %16.8e  %16.8e\n',...
                    D(j,j),shift+(1/D(j,j)),res(j));
                elseif opts.debug>2
                    fprintf('** %16.8e  %16.8e  %16.8e\n',...
                    D(j,j),shift+(1/D(j,j)),res(j));
                end
            end
            fprintf('\n');
        end
    end

end



function displayIntervals(intervalList,Lambda)

    zz=histcounts(Lambda,[intervalList(1,1);intervalList(:,2)]);

    for k=1:size(intervalList,1)
        endL=intervalList(k,1);
        endR=intervalList(k,2);

        inL=intervalList(k,3);
        inR=intervalList(k,4);
        tot=inR-inL;

        sentL=intervalList(k,5);
        sentR=intervalList(k,6);

        if zz(k)<=0&&tot>0
            disp(getString(message('MATLAB:lanczos:DisplayEmptyIntervalInfo',...
            k,zz(k),tot,num2str(endL),num2str(endR),...
            num2str(sentL),num2str(sentR),inL,inR)));
        elseif zz(k)<tot
            disp(getString(message('MATLAB:lanczos:DisplayPartialIntervalInfo',...
            k,zz(k),tot,num2str(endL),num2str(endR),...
            num2str(sentL),num2str(sentR),inL,inR)));
        elseif zz(k)==tot
            disp(getString(message('MATLAB:lanczos:DisplayFullIntervalInfo',...
            k,zz(k),tot,num2str(endL),num2str(endR),...
            num2str(sentL),num2str(sentR),inL,inR)));
        else
            disp(getString(message('MATLAB:lanczos:DisplayOverfullIntervalInfo',...
            k,zz(k),tot,num2str(endL),num2str(endR),...
            num2str(sentL),num2str(sentR),inL,inR)));
        end
    end
    fprintf('\n');

end



function[intervalList,bs,reuseShift]=avoidStagnation(intervalList,...
    ii,bs,newbs,convInfo,opts)

    reuseShift=false;

    if newbs<bs



        bs=newbs;
        reuseShift=true;
        if opts.debug>0
            disp(getString(message('MATLAB:lanczos:BlockSizeReduced',bs)));
        end
    else






        if convInfo.outOfRangeR>0
            rightEndpoint=intervalList(ii(end),2);
            rightSentinel=intervalList(ii(end),6);
            reuseShift=(rightEndpoint>rightSentinel);
            intervalList(ii(end),6)=max([rightEndpoint,rightSentinel]);
        end

        if convInfo.outOfRangeL>0
            leftEndpoint=intervalList(ii(1),1);
            leftSentinel=intervalList(ii(1),5);
            reuseShift=reuseShift|(leftEndpoint<leftSentinel);
            intervalList(ii(1),5)=min([leftEndpoint,leftSentinel]);
        end
    end

end



function displayTerminationMessage(intervalCode,opts,expectAll,largeRatio)

    if intervalCode>0

        if opts.debug>0
            disp(getString(message('MATLAB:lanczos:AllFound')));
            fprintf('\n');
        end
    elseif largeRatio(1)



        throwAsCaller(MException(message('MATLAB:lanczos:BadLeft')));
    elseif largeRatio(2)
        throwAsCaller(MException(message('MATLAB:lanczos:BadRight')));
    elseif intervalCode<0
        throwAsCaller(MException(message('MATLAB:lanczos:Overfull')));
    elseif expectAll

        throwAsCaller(MException(message('MATLAB:lanczos:NotAllFound')));
    end

end



function[fL,fD,fP,fS,sturm,maxfront,ratio]=getFactor(KsM)


    [fL,fD,fP,fS,sturm,~,maxfront]=ldl(KsM);

    num=full(diag(KsM).*diag(fS).^2);
    den=diag(fP*fD*fP');


    ind=true(size(KsM,1),1);
    [i,j]=find(triu(fP*fD*fP',1));
    ind([i,j])=false;

    diags=num(ind)./den(ind);
    ratio=max(abs(diags));


    if any(isnan(diags))
        ratio=Inf;
    end
end



function Tnew=updateT(T,k,Ak,Bk)
    bs=size(Ak,1);

    Tnew=blkdiag(T,Ak);
    if k>1

        Tnew((k-1)*bs+1:k*bs,(k-2)*bs+1:(k-1)*bs)=Bk;
        Tnew((k-2)*bs+1:(k-1)*bs,(k-1)*bs+1:k*bs)=Bk';
    end
end



function Tup=updateTup(Tup,k,bs,f,g,Ak,Bk,Aku,Bku)










    Tup=updateT(Tup,k,Ak,Bk);








    if~isempty(f)
        If0b=[eye((k-1)*bs),f;zeros(bs,(k-1)*bs),Bku];
        Tup=If0b*(Tup/If0b);
    end


    Tup(1:k*bs,(k-1)*bs+1:k*bs)=...
    Tup(1:k*bs,(k-1)*bs+1:k*bs)+[g;Aku];
end



function[qnew,U,exitcode,newbs]=MQR(q,M,smallNorm,maxCondition,reorthTol)













    exitcode=0;
    bs=size(q,2);
    newbs=0;

    qnew=q;
    U=eye(bs);



    for iter=1:2
        [U2,p]=chol(qnew'*M*qnew);
        if p>0
            U2=eye(bs);
        end

        qnew=qnew/U2;
        U=U2*U;

        if p>0

            exitcode=-3;

            if norm(qnew'*M*qnew)<smallNorm^2,exitcode=-1;end
            qnew=zeros(size(q));
            U=zeros(bs);
            newbs=p-1;
        elseif norm(U)<smallNorm

            exitcode=-1;
        elseif cond(U)>maxCondition

            exitcode=-2;
            newbs=nnz(maxCondition*svd(U)>max(svd(U)));
        end

        if cond(U2)<reorthTol||exitcode<0
            break
        end
    end

    newbs=1+mod(newbs-1,bs);

end



function[omega,f,qk,Mqk,Aku,Bku,r,g]=...
    partialReorthSweep(k,bs,omega,...
    qk,Mqk,r,M,Q,MQ,QRsmall,QRcond,reorthTol,opts)








    omega(k+1,1:k+1)=opts.omegaEps;



    f=[];
    Bku=eye(bs);

    if opts.PROqk





        [qk1,f1]=partialReorth(qk,Q,MQ,opts.PROtwice);
        if opts.updateBk



            [qk1,Bku1,ec]=MQR(qk1,M,QRsmall,QRcond,reorthTol);
        else
            ec=1;
        end

        if ec>=0
            f=f1;
            qk=qk1;
            Mqk=M*qk;
            omega(k,1:k)=opts.omegaEps;
        end

        if ec==0
            Bku=Bku1;
            r=r/Bku;
        else
            if opts.debug>0
                disp(getString(message('MATLAB:lanczos:ProFailed')));
                fprintf('\n');
            end
        end
    end




    [r,g]=partialReorth(r,Q,MQ,opts.PROtwice);


    Aku=Mqk'*r;
    r=r-qk*Aku;

end



function[qnew,f]=partialReorth(q,Q,MQ,dotwice)


    bs=size(q,2);
    k=size(Q,2)/bs;
    qnew=q;

    f=MQ'*qnew;qnew=qnew-Q*f;
    f2=MQ'*qnew;qnew=qnew-Q*f2;
    f=f+f2;

    if dotwice
        for j=1:k
            qj=Q(:,(j-1)*bs+1:j*bs);
            Mqj=MQ(:,(j-1)*bs+1:j*bs);
            fj=Mqj'*qnew;
            f((j-1)*bs+1:j*bs,:)=f((j-1)*bs+1:j*bs,:)+fj;
            qnew=qnew-qj*fj;
        end
    end
end



function[qnew,alpha]=selectiveReorth(q,Mq,X)


    k=size(X,2);
    qnew=q;
    alpha=zeros(k,size(q,2));
    for j=1:k
        fj=X(:,j)'*Mq;
        alpha(j,:)=fj;
        qnew=qnew-X(:,j)*fj;
    end
end



function[Alpha,tau,r]=selectiveR(Alpha,k,bs,soVec,M,rin,tau,opts)






    tauMustReorth=tau(:,k+1)>opts.tauTol|tau(:,k)>opts.tauTol;

    r=[];

    if any(tauMustReorth)
        Alpha(:,(k-1)*bs+1:k*bs)=zeros(size(soVec,2),bs);
        r=rin;
        for j=1:size(soVec,2)
            if tauMustReorth(j)
                [r,ff]=selectiveReorth(r,M*r,soVec(:,j));
                Alpha(j,(k-1)*bs+1:k*bs)=ff;
                tau(j,k+1)=opts.tauEps;
            end
        end
    end
end



function tau=updateTau(tau,Tup,Bkp1,shift,soVec,soVal,soRB,Alpha)























    zscale=abs(soRB(:,1).*(soVal-soRB(:,2))./(soVal-shift));
    invshift=1./(soVal-shift);
    shiftgap=shift-soRB(:,2);

    bs=size(Bkp1,1);
    k=size(Tup,1)/bs;

    for j=1:size(soVec,2)


        Ttau=repelem(tau(j,1:k)',bs).*(Tup-invshift(j)*eye(size(Tup)));
        Trec=Ttau(:,1:end-bs);
        Trhs=Ttau(:,end-bs+1:end)/Bkp1;
        Trec2=Trec(bs+1:end,:);
        Trhs2=Trhs(bs+1:end,:);





        lsopts.UT=true;
        [ww1,~]=linsolve(Trec2,Trhs2,lsopts);
        ww=[-ww1;inv(Bkp1)];


        Tiw=Trhs-Trec*ww1;
        tau(j,k+1)=0;
        for jj=1:k
            tau(j,k+1)=tau(j,k+1)+norm(Tiw((jj-1)*bs+1:jj*bs,:));
        end


        Tiw2=[ww+shiftgap(j)*Tup*ww;shiftgap(j)*eye(bs)];
        tau(j,k+1)=tau(j,k+1)+zscale(j)*norm(Tiw2);


        if~isempty(Alpha)
            aw=Alpha(j,:)*ww(1:size(Alpha,2),:);
            tau(j,k+1)=tau(j,k+1)+norm(aw);
        end
    end

end



function[TT,omega]=updateOmega(TT,omega,Ak,Bk,Bkp1,k,epsStart)

















    TT(k,k)=norm(Ak);
    if k>1
        TT(k-1,k)=norm(Bk);
        TT(k,k-1)=norm(Bk);
    end
    if k==1
        omega(k,k)=epsStart;
    else
        omega(k+1,1:k-1)=...
        (omega(k,:)*TT(:,1:k-1)+TT(k,:)*omega(:,1:k-1))/min(svd(Bkp1));
    end
    omega(k+1,k:k+1)=epsStart;

end



function[Vk,Dk]=refineu(T,TE,tol,niter)





    [V,D]=eig(T);
    D=diag(D);


    rk=TE*V;
    rktol=eps(max(abs(D)))*size(T,1);

    Vk=V;
    Dk=D;

    for k=1:niter
        if norm(rk,'inf')<rktol
            break
        end
        VRk=Vk'*rk;

        DD=Dk'-Dk;

        W=VRk./DD;
        W(abs(VRk)>=tol.*abs(DD))=0;

        Vk=Vk+Vk*W;
        Dk=Dk+diag(VRk);

        rk=(T+TE)*Vk-Vk*diag(Dk);
    end

    Dk=diag(Dk);
end



function[V,D,res,restol,convInfo,exitcode,excessCost]=...
    endRecurrence(k,T,Tup,Bkp1,shift,range,opts,exitcode,need,needL,needR,...
    excessCost,TotalCostFcn)


    [V,D]=refineu(T,Tup-T,opts.omegaTol/opts.refineU,opts.refineU);
    res=vecnorm(Bkp1*V(end+1-size(Bkp1,1):end,:),2,1);
    shiftedD=shift+1./diag(D);




    restol=opts.convTol*max(abs(diag(D)));
    smallRes=res(:)<restol;
    outOfRange=(shiftedD>=range(2))|(shiftedD<range(1));
    converged=~outOfRange&smallRes;


    convInfo.converged=converged;
    convInfo.L=nnz(converged&diag(D)<0);
    convInfo.R=nnz(converged&diag(D)>=0);
    convInfo.outOfRangeL=nnz(smallRes&outOfRange&diag(D)<0);
    convInfo.outOfRangeR=nnz(smallRes&outOfRange&diag(D)>=0);


    res(outOfRange)=Inf;

    displayProgress(k,convInfo,res,D,shift,opts);


    if exitcode~=0



        return
    elseif nnz(converged)>=need

        exitcode=10;
    elseif convInfo.L>=needL

        exitcode=11;
    elseif convInfo.R>=needR

        exitcode=12;
    elseif k>=opts.minStep

        excessCost=estimateCosts(excessCost,k,res,restol,TotalCostFcn,opts);




        if excessCost>=opts.expConsecutive
            if opts.debug>1
                disp(getString(message('MATLAB:lanczos:TerminateCost')));
                fprintf('\n');
            end
            exitcode=99;
        end
    end

end



function[sentinelLeft,sentinelRight]=getSentinels(D,res,converged,shift)


    [D1,p]=sort(diag(D));
    nc=~converged(p);
    ncl=nc(:)&D1(:)<0;
    ncr=nc(:)&D1(:)>0;


    Dc=D1;
    resc=res(p);
    if any(nc)

        Dc=Dc([1:find(nc,1,'first')-1,find(nc,1,'last')+1:end]);
        resc=resc([1:find(nc,1,'first')-1,find(nc,1,'last')+1:end]);
    end

    [sentinelLeft,imin]=min(shift+1./Dc);
    [sentinelRight,imax]=max(shift+1./Dc);

    if~isempty(Dc)

        shiftedRes=abs(resc./(Dc.*(1+shift*Dc))');
        fudge=max(sqrt(eps),shiftedRes(imin));
        sentinelLeft=sentinelLeft-abs(fudge*sentinelLeft);
        fudge=max(sqrt(eps),shiftedRes(imax));
        sentinelRight=sentinelRight+abs(fudge*sentinelRight);



        fudge=sqrt(eps);
        ucsL=shift+1./min(D1(ncl));
        ucsR=shift+1./max(D1(ncr));
        ucsL=ucsL+abs(fudge*ucsL);
        ucsR=ucsR-abs(fudge*ucsR);
        sentinelLeft=max([sentinelLeft,ucsL]);
        sentinelRight=min([sentinelRight,ucsR]);


        fudge=sqrt(eps)*max(abs([sentinelLeft,sentinelRight]));
        gap=sentinelRight-sentinelLeft;
        sentinelLeft=sentinelLeft(gap>fudge);
        sentinelRight=sentinelRight(gap>fudge);
    end
end



function shift=shiftScale(K,M)

    Kdiag=abs(diag(K));
    Mdiag=abs(diag(M));
    ind=find(Mdiag./Kdiag<1e4);
    shift=1./(numel(ind)*sum(Mdiag(ind)./Kdiag(ind)));
    if~isfinite(shift)
        shift=1;
    end




end



function TotalCostFcn=CreateCostFcn(n,nnzM,nnzL,bs,maxfront,...
    nIter,nPRO)



    FactTime=(5e-11)*nnzL*maxfront;
    FBTime=max((-1.6e-7)*nnzL+(1.7e-8)*n*maxfront+(3e-9)*nnzL*bs,0);
    MrTime=(1.5e-9)*bs*nnzM;





    sumEigTime=@(k)((8e-11)*bs^3+(4e-11)*nIter*bs^3)*(1/4)*(k.*(k+1)).^2;
    sumProTime=@(k)(1.3e-8)*n*bs*(1/2)*(k.*(k+1));

    TotalCostFcn=@(k)FactTime+k*FBTime+(2+1/nPRO)*k*MrTime+...
    (1/nPRO)*sumProTime(k)+sumEigTime(k);
end



function excessCost=estimateCosts(excessCost,k,res,restol,CostFcn,opts)




    convSteps=(0:opts.expLookahead);
    convRate=(opts.expConvRate.^convSteps);



    newConverged=sum(res'<restol*convRate);


    NextCost=CostFcn(k+convSteps)./newConverged;

    CostNow=NextCost(1);
    FutureCost=NextCost(2:end);
    [futuremin,ii]=min(FutureCost);
    if futuremin>CostNow

        excessCost=excessCost+1;
        ii=0;
    else
        excessCost=0;
    end

    if opts.debug>1
        disp(getString(message('MATLAB:lanczos:CostBanner',length(NextCost))));
        for j=1:length(NextCost)
            if j==ii+1
                fprintf('**  %d %16.8e\n',convSteps(j),NextCost(j));
            else
                fprintf('    %d %16.8e\n',convSteps(j),NextCost(j));
            end
        end
        fprintf('\n');
    end

end
