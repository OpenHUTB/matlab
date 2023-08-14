function[fitA,fitC,fitD,errdbEnd,err,stats]=fitterImpl(freq,data,cols,args)




%#codegen
    cflag=isempty(coder.target);
    if~isempty(coder.target)
        dnz=1;
    end

    eigsThreshold=150;

    stats.nSurrogate=int32(1);
    stats.minAchievableError=-Inf;
    err=complex(zeros(size(data)));
    coder.varsize('err');

    fitA=cell(cols,1);
    fitC=cell(cols,1);
    fitD=zeros(cols,1);
    z=zeros(0,1);
    for k=1:cols
        fitA{k}=z;
        fitC{k}=z;
        fitD(k)=0;
    end

    plotflag=strcmpi(args.Display,'plot')||strcmpi(args.Display,'both');
    printflag=strcmpi(args.Display,'on')||strcmpi(args.Display,'both');

    nfreq=numel(freq);
    npmax=max(0,args.MaxPoles-1);
    npmaxposs=min(floor(1.2*npmax)+2,4*nfreq);
    errdb=zeros(1,npmaxposs);
    n_errdb=0;

    noiseFloorLinear=10^(args.NoiseFloor/20);
    if noiseFloorLinear<eps
        noiseFloorLinear=eps;
    end

    stats.ErrorMetric=args.ErrorMetric;

    if max(abs(data(:)))==0
        if printflag
            fprintf('Data identically zero.\n');
        end
        n_errdb=n_errdb+1;
        errdb(1,n_errdb)=-Inf;
        errdbEnd=errdb(1,n_errdb);
        return
    end

    if nfreq==1&&isreal(data(:))
        if printflag
            fprintf('Single frequency point with real data.\n');
        end
        if args.TendsToZero
            n_errdb=n_errdb+1;
            errdb(1,n_errdb)=0;
            dd=zeros(size(data));
        else
            n_errdb=n_errdb+1;
            errdb(1,n_errdb)=-Inf;
            dd=data;
        end
        for k=1:cols
            fitD(k)=dd(k);
        end
        errdbEnd=errdb(1,n_errdb);
        if~isempty(args.NumPoles)&&0~=args.NumPoles
            warning('Failed to get exact requested number of poles');
        end
        return
    end

    [freq,i]=unique(freq);
    if numel(freq)<nfreq&&cflag

        error(message('rf:rational:FrequenciesNotUnique'))
    end
    data=data(i,:);

    assert(issorted(freq));
    fscale=freq(end);
    freq=freq(:)/fscale;
    zff=(freq(1)==0);
    s=2i*pi*freq;
    ndata=cols;

    data(abs(data)<noiseFloorLinear)=0;
    normorigdata=vecnorm(data);
    normtodivide=normorigdata;
    normtodivide(normtodivide==0)=1;
    if cflag

        dataNormalized=data./normtodivide;
    else
        dataNormalized=bsxfun(@(x,y)x./y,data,normtodivide);
    end

    Vsurrogate=complex(zeros(ndata));
    achievableError=complex(zeros(size(data)));
    surrogate=dataNormalized;


    if args.ColumnReduce&&ndata>1
        K=[real(dataNormalized);imag(dataNormalized)];
        [uk,sk,vk]=svd(K,'econ');
        if cflag

            clear K
        end
        usk=uk*sk;
        if cflag

            clear uk
            clear sk
        end
        allSurrogates=complex(usk(1:end/2,:),usk(end/2+1:end,:));
        if cflag

            clear usk
        end
        nSurrogate=ndata;
        for i=1:ndata-1
            if cflag

                Vsurrogate=normorigdata.*vk(:,1:i).';
            else
                Vsurrogate=bsxfun(@(x,y)x.*y,normorigdata,vk(:,1:i).');
            end
            surrogate=allSurrogates(:,1:i);
            achievableError=data-surrogate*Vsurrogate;
            [minAchievableError,errcol]=rf.internal.rational.errcalc(achievableError,data,args.ErrorMetric,noiseFloorLinear);
            achievableError(:,isinf(errcol))=0;
            if minAchievableError<args.Tolerance-20
                nSurrogate=i;
                break
            end
        end
        if cflag

            clear vk
            clear allSurrogates
        end
    else
        nSurrogate=ndata;
    end

    if nSurrogate==ndata
        if cflag
            Vsurrogate=spdiags(normorigdata.',0,ndata,ndata);
        else
            Vsurrogate=diag(normorigdata);
        end
        surrogate=dataNormalized;
        achievableError=complex(zeros(size(data)));
    end

    stats.minAchievableError=rf.internal.rational.errcalc(achievableError,data,args.ErrorMetric,noiseFloorLinear);
    stats.nSurrogate=int32(nSurrogate);
    if printflag
        if nSurrogate==ndata
            fprintf('No reduction possible.\n');
        else
            fprintf('nSurrogate=%d; reduced to %.1f%%\n',nSurrogate,100*nSurrogate/ndata);
            fprintf('min achievable error=%g\n',stats.minAchievableError);
        end
    end

    monitored=(1:nfreq).';
    matched=zeros(1,nfreq);
    n_matched=0;
    C=[];
    coder.varsize('C');
    M=[];
    coder.varsize('M');
    MhM=[];
    coder.varsize('MhM');
    np=zeros(1,npmaxposs);
    MhMall=zeros(npmaxposs,npmaxposs);
    MhMindx=0;
    n_np=1;

    if args.TendsToZero
        resp=zeros(size(data));
    else
        mrd=mean(real(data));
        if cflag

            resp=mrd.*ones(size(data));
        else
            resp=bsxfun(@(x,y)x.*y,mrd,ones(size(data)));
        end
    end
    err=complex(resp-data);
    coder.varsize('err');
    errdbAAA=zeros(1,npmaxposs);
    errdbAAA(1,1)=rf.internal.rational.errcalc(err,data,args.ErrorMetric,noiseFloorLinear);
    n_errdbAAA=1;
    best_pol=complex(zeros(0,1));
    coder.varsize('best_pol');
    [best_d,cCA,~,errdbCRCA]=getResiduesAndResponse(data,s,best_pol,...
    args.Tolerance,args.TendsToZero,args.ErrorMetric,args.Causal,...
    noiseFloorLinear,args.NumPoles,args.MaxPoles);
    n_errdb=n_errdb+1;
    if isPoleCountOK(0,args)
        errdb(1,n_errdb)=errdbCRCA{1,1};
    else
        errdb(1,n_errdb)=Inf;
    end
    best_c=cCA{1,1};
    best_errdb=errdb(1,n_errdb);
    if printflag

        if isfinite(errdb(1,n_errdb))
            fprintf('init: np=%d errdbAAA=%g errdb=%g (np=0)\n',...
            np(1,n_np),errdbAAA(1,n_errdbAAA),errdbCRCA{1,1});
        else
            fprintf('init: np=%d errdbAA=%g [errdb=%g] (np=0)\n',...
            np(1,n_np),errdbAAA(1,n_errdbAAA),errdbCRCA{1,1});
        end
    end







    threshErr=[(40:-2.5:(args.Tolerance-25)).';-Inf];
    threshNext=1;

    if strcmpi(args.ErrorMetric,'Relative')
        dnz=rf.internal.rational.datanz(data,noiseFloorLinear);
        if nSurrogate==ndata
            relerrrecip=(1./dnz).';
        else
            temp=rf.internal.rational.datanz(surrogate,noiseFloorLinear);
            relerrrecip=(1./temp).';
        end
    end
    while true
        if n_np==1&&zff
            itoperr=1;
        else
            if strcmpi(args.ErrorMetric,'Default')
                abserr=abs(err);
            else
                abserr=abs(err)./dnz;
            end
            maxerrcol=max(abserr,[],2);
            [~,errcolsorted]=sort(maxerrcol,'descend');
            itoperr=errcolsorted(1);

...
...
...
...
...
...
...
...
...
...
        end
        itoperr(ismember(itoperr,matched))=[];%#ok<EMGRO> 
        if isempty(itoperr)
            if isempty(args.NumPoles)
                if printflag
                    fprintf('Largest error is at already matched point.\n');
                end
                break
            else
                for kk=2:length(errcolsorted)
                    if~ismember(errcolsorted(kk),matched)
                        itoperr=errcolsorted(kk);
                        break
                    end
                end
                if isempty(itoperr)
                    if printflag
                        fprintf('Largest error is at already matched point.\n');
                    end
                    break
                end
            end
        end
        matched(1,n_matched+1:n_matched+length(itoperr))=itoperr;
        n_matched=n_matched+length(itoperr);
        rowsM=int32(zeros(1,0));
        for k=1:length(itoperr)
            rowsM=[rowsM,(itoperr(k)-1)*nSurrogate+(1:nSurrogate),(itoperr(k)+nfreq-1)*nSurrogate+(1:nSurrogate)];%#ok<AGROW> 
            monitored(monitored==itoperr(k))=[];
        end
        rowsM=sort(rowsM);
        assert(all(sort([matched(1,1:n_matched),monitored'])==1:nfreq))

        f=surrogate(matched(1,1:n_matched),:);
        if zff
            fwc=complex(zeros(2*size(f,1)-1,size(f,2)));
            fwc(1,:)=real(f(1,:));
            fwc(2:2:end,:)=f(2:end,:);
            fwc(3:2:end,:)=conj(f(2:end,:));
        else
            fwc=complex(zeros(2*size(f,1),size(f,2)));
            fwc(1:2:end,:)=f;
            fwc(2:2:end,:)=conj(f);
        end


        [Lnew,Cnew,Dnew]=loewner(s,surrogate,monitored,itoperr,true);
        if strcmpi(args.ErrorMetric,'Relative')
            Lnew=Lnew.*relerrrecip(:);
            Dnew=Dnew.*relerrrecip(:);
        end
        if args.TendsToZero&&isempty(M)
            M=[real(Dnew);imag(Dnew)];
            MhM=M.'*M;
            MhMindx=size(M,2);
            MhMall(1:MhMindx,1:MhMindx)=MhM;
        end
        C=[C,Cnew];%#ok<AGROW> 
        rL=real(Lnew);
        iL=imag(Lnew);
        if n_np==1&&zff
            assert(size(Lnew,2)==1);
            Lpm=[rL;iL];
        else
            assert(mod(size(Lnew,2),2)==0)
            Lpm=[];
            for k=1:2:size(Lnew,2)
                rL1=rL(:,k);
                iL1=iL(:,k);
                rL2=rL(:,k+1);
                iL2=iL(:,k+1);
                Lpmk=[rL1+rL2,iL2-iL1;iL2+iL1,rL1-rL2];
                Lpm=[Lpm,Lpmk];%#ok<AGROW> 
            end
        end

        Lpmt=Lpm.';
        if isempty(M)
            ddt=zeros(size(Lpm,2),0);
        else
            Mk=M(rowsM,:);
            temp2=Mk.'*Mk;
            MhMall(1:MhMindx,1:MhMindx)=MhM-temp2;
            assert(max(rowsM)<=size(M,1));
            M(rowsM,:)=0;%#ok<EMGRO> 
            ddt=Lpmt*M;
        end
        LhL=Lpmt*Lpm;
        MhMindxnew=MhMindx+size(LhL,1);
        rr=MhMindx+1:MhMindxnew;
        MhMall(rr,1:MhMindx)=ddt;
        MhMall(1:MhMindx,rr)=ddt.';
        MhMall(rr,rr)=LhL;
        MhMindx=MhMindxnew;
        M=[M,Lpm];%#ok<AGROW> 
        MhM=MhMall(1:MhMindx,1:MhMindx);
        MR=justRofM(M,MhM);
        if size(MR,1)<=eigsThreshold||size(MR,1)<size(MR,2)||~cflag
            [~,~,MV]=svd(MR,'econ');
            wHtilde=MV(:,end);
        else

            warningstate(1)=warning('off','MATLAB:eigs:IllConditionedB');%#ok<EMVDF>
            warningstate(2)=warning('off','MATLAB:nearlySingularMatrix');%#ok<EMVDF>
            [wHtilde,~]=eigs(speye(size(MR)),MR,1,'largestabs','IsCholesky',true,'Display',false);
            warning(warningstate);
        end
        if args.TendsToZero
            wInf=wHtilde(1);
            wHtilde=wHtilde(2:end);
        else
            wInf=[];
        end
        nwHtilde=norm(wHtilde);
        wHtilde=wHtilde/nwHtilde;
        if args.TendsToZero
            wInf=wInf/nwHtilde;
        end
        [~,maxwHtilde]=max(abs(wHtilde));
        if wHtilde(maxwHtilde)<0
            wHtilde=-wHtilde;
            if args.TendsToZero
                wInf=-wInf;
            end
        end

        if zff
            if length(wHtilde)==1
                w=wHtilde(1);
                ww=w;
            else
                w=[wHtilde(1);wHtilde(2:2:end)+1i*wHtilde(3:2:end)];
                ww=[w(2:end).';w(2:end)'];
                ww=[w(1);ww(:)];
            end
        else
            w=wHtilde(1:2:end)+1i*wHtilde(2:2:end);
            ww=[w.';w'];
            ww=ww(:);
        end
        if args.TendsToZero
            Cww=C*ww+wInf;
        else
            Cww=C*ww;
        end
        if cflag
            wf=ww.*fwc;
        else

            wf=bsxfun(@(x,y)x.*y,ww,fwc);
        end
        Cwf=C*wf;
        if cflag
            rr=Cwf./Cww;
        else

            rr=bsxfun(@(x,y)x./y,Cwf,Cww);
        end
        temp=full((surrogate-rr)*Vsurrogate);
        err=temp(:,1:cols);
        err(matched(1,1:n_matched),:)=achievableError(matched(1,1:n_matched),:);
        n_errdbAAA=n_errdbAAA+1;
        errdbAAA(1,n_errdbAAA)=rf.internal.rational.errcalc(err,data,args.ErrorMetric,noiseFloorLinear);
        n_np=n_np+1;
        if args.TendsToZero
            np(1,n_np)=length(ww);
        else
            np(1,n_np)=length(ww)-1;
        end

        if(np(1,n_np)<=100||errdbAAA(1,n_errdbAAA)<threshErr(threshNext))&&...
            (isempty(args.NumPoles)||np(1,n_np)>=args.NumPoles)
            if np(1,n_np)>100
                while errdbAAA(1,n_errdbAAA)<threshErr(threshNext)
                    threshNext=threshNext+1;
                end
            end
            pol=getPoles(np(1,n_np),zff,matched(1,1:n_matched),s,ww,wInf,false,args);
            [d,cCA,polCA,errdbCRCA]=getResiduesAndResponse(data,s,pol,...
            args.Tolerance,args.TendsToZero,args.ErrorMetric,...
            args.Causal,noiseFloorLinear,args.NumPoles,args.MaxPoles);
            for ic=1:size(polCA,1)
                if isPoleCountOK(length(polCA{ic,1}),args)
                    n_errdb=n_errdb+1;
                    errdb(1,n_errdb)=errdbCRCA{ic,1};
                else
                    n_errdb=n_errdb+1;
                    errdb(1,n_errdb)=Inf;
                end
                if errdb(1,n_errdb)<best_errdb
                    best_errdb=errdb(1,n_errdb);
                    best_pol=polCA{ic,1};
                    best_d=d;
                    best_c=cCA{ic,1};
                end
                if printflag
                    if ic==1
                        if isfinite(errdb(1,n_errdb))
                            fprintf('np=%d errdbAAA=%g  errdb=%g (np=%d)\n',...
                            np(1,n_np),errdbAAA(1,n_errdbAAA),errdbCRCA{ic,1},length(polCA{ic,1}));
                        else
                            fprintf('np=%d errdbAAA=%g [errdb=%g] (np=%d)\n',...
                            np(1,n_np),errdbAAA(1,n_errdbAAA),errdbCRCA{ic,1},length(polCA{ic,1}));
                        end
                    else
                        if isfinite(errdb(1,n_errdb))
                            fprintf('                         errdb=%g (np=%d)\n',...
                            errdbCRCA{ic,1},length(polCA{ic,1}));
                        else
                            fprintf('                        [errdb=%g] (np=%d)\n',...
                            errdbCRCA{ic,1},length(polCA{ic,1}));
                        end
                    end
                end
                if best_errdb<=args.Tolerance
                    break
                end
            end
        else
            n_errdb=n_errdb+1;
            errdb(1,n_errdb)=Inf;
            if printflag
                fprintf('np=%d errdbAAA=%g\n',np(1,n_np),errdbAAA(1,n_errdbAAA));
            end
        end
        if plotflag
            resp=data+err;
            figure(1)
            ff=freq*fscale;
            preal=semilogx(ff,real(data),ff,real(resp),'-.',ff(matched(1,1:n_matched)),real(data(matched(1,1:n_matched),:)),'ro');
            title('Real part of data and response')
            xlabel('Frequency (Hz)')
            ylabel('Data and response')
            legend([preal(1),preal(1+cols),preal(end)],'Data','Response','Matched Points')
shg
            figure(2)
            pimag=semilogx(ff,imag(data),ff,imag(resp),'-.',ff(matched(1,1:n_matched)),imag(data(matched(1,1:n_matched),:)),'ro');
            title('Imaginary part of data and response')
            xlabel('Frequency (Hz)')
            ylabel('Data and response')
            legend([pimag(1),pimag(1+cols),pimag(end)],'Data','Response','Matched Points')
shg
            figure(3)
            semilogx(ff,abs(err));
            title('Error (difference between data and response)')
            xlabel('Frequency (Hz)')
            ylabel('Error')
            legend('Error')
shg
        end
        if length(monitored)==1
            if printflag
                fprintf('Only one unmatched point left.\n');
            end
            break
        end
        if errdb(1,n_errdb)<=args.Tolerance
            if printflag
                fprintf('Achieved specified tolerance.\n');
            end
            break
        end
        if errdbAAA(1,n_errdbAAA)<=args.Tolerance&&isfinite(errdb(1,n_errdb))&&...
            (np(1,n_np)>100&&errdbAAA(1,n_errdbAAA)-best_errdb<-20)
            if printflag
                fprintf('Fit after calculate residues too far from AAA prediction.\n');
            end
            break
        end
        if np(1,n_np)>=max(2*npmax,100)&&args.Causal
            if printflag
                fprintf('Order of AAA fit exceeds search limit.\n');
            end
            break
        end
        if np(1,n_np)>=max(npmax,100)&&~args.Causal
            if printflag
                fprintf('Order of AAA fit exceeds search limit (non-causal fit).\n');
            end
            break
        end
        if errdbAAA(1,n_errdbAAA)<-180
            if printflag
                fprintf('AAA algorithm has reached the limit of possible fits.\n');
            end
            break
        end
        if isempty(MR)&&np(1,n_np)>100
            if printflag
                fprintf('Ran into numerical difficulties (try setting TendsToZero to false)\n');
            end
            break
        end
        dMR=abs(diag(MR));
        if min(dMR)/max(dMR)<1e-20
            if printflag
                fprintf('Ran into ill-conditioned matrix (try setting NoiseFloor).\n');
            end
            break
        end
    end

    if cflag

        clear('M');
    end

    if~isempty(args.NumPoles)&&length(best_pol)~=args.NumPoles
        warning('Failed to get exact requested number of poles');
    end

    pol=best_pol;
    d=best_d;
    c=best_c;
    errdb(1,n_errdb)=best_errdb;
    errdbEnd=best_errdb;
    for k=1:cols
        fitA{k}=pol*fscale;
        fitC{k}=c(:,k)*fscale;
        fitD(k)=d(k);
    end
    if printflag
        fprintf('final: np=%d errdb=%g\n',length(pol),errdb(1,n_errdb))
    end

end

function result=isPoleCountOK(p,args)
    if~isempty(args.NumPoles)
        result=(p==args.NumPoles);
    else
        result=(p<=args.MaxPoles);
    end
end

function[L,C,v]=loewner(s,data,unsidx,supidx,zeroOutRows)
    cflag=isempty(coder.target);
    if s(supidx(1))==0
        la=[s(supidx(2:end)).';s(supidx(2:end))'];
        la=[s(supidx(1)),la(:).'];
        if length(supidx)>1
            x=data(supidx(2:end),:).';
            w=complex(zeros(size(x,1),2*size(x,2)));
            w(:,1:2:end)=x;
            w(:,2:2:end)=conj(x);
            w1=[data(supidx(1),:).',w];
            w=w1;
        else
            w=data(supidx(1),:).';
        end
    else
        la=[s(supidx).';s(supidx)'];
        la=la(:).';
        x=data(supidx,:).';
        w=complex(zeros(size(x,1),2*size(x,2)));
        w(:,1:2:end)=x;
        w(:,2:2:end)=conj(x);
    end
    if zeroOutRows
        mu=s;
        du=complex(zeros(size(data)));
        du(unsidx,:)=data(unsidx,:);
        du=du.';
        wrep=size(data,1);
    else
        mu=s(unsidx);
        du=data(unsidx,:).';
        wrep=length(unsidx);
    end
    v=du(:);

    if cflag
        C=1./(mu-la);
    else

        Crecip=bsxfun(@minus,mu,la);
        C=1./Crecip;
    end
    vrep=size(w,2);

    L=repmat(v,1,vrep);
    if zeroOutRows
        C(isinf(C))=0;

        wnz=zeros(wrep,1);
        wnz(unsidx,:)=1;
        numer2=kron(wnz,w);
    else
        numer2=repmat(w,wrep,1);
    end
    L=L-numer2;
    if cflag

        clear('numer2');
    end
    Crep=kron(C,ones(size(data,2),1));
    if cflag
        L=L.*Crep;
    else

        L=bsxfun(@(x,y)x.*y,L,Crep);
    end

end

function pol=getPoles(np,zff,matched,s,ww,wInf,printflag,args)
    cflag=isempty(coder.target);
    if np>0
        expectedInfEigenvalues=2;
        K=sparse([1,1;-1i,1i]/sqrt(2));
        mw=floor(length(ww)/2)+zff;
        if zff
            n=2*mw;
        else
            n=2*mw+1;
        end
        if~isempty(wInf)
            Esize=n+1;
        else
            Esize=n;
        end
        if isempty(wInf)
            Ediag=[0;ones(n-1,1)];
        else
            Ediag=[0;ones(n-1,1);0];
        end
        E=spdiags(Ediag,0,Esize,Esize);

        if zff
            ss=[s(matched(2:end)).';s(matched(2:end))'];
            ss=[s(1);ss(:)];
        else
            ss=[s(matched).';s(matched)'];
            ss=ss(:);
        end
        if isempty(wInf)
            A=sparse([ones(1,n-1),2:n,2:n],...
            [2:n,2:n,ones(1,n-1)],...
            [ww;ss;ones(n-1,1)]);
        else
            A=sparse([ones(1,n),2:n+1,2:n+1],...
            [2:n+1,2:n+1,ones(1,n)],...
            [[ww;wInf];[ss;-1];ones(n,1)]);
        end
        if zff
            Ta=kron(eye(mw-1),K);
            if cflag

                T=blkdiag(eye(2),Ta);
            else
                T=sparse(blkdiag(eye(2),full(Ta)));
            end
        else
            Ta=kron(eye(mw),K);
            if cflag

                T=blkdiag(1,Ta);
            else
                T=sparse(blkdiag(1,full(Ta)));
            end
        end
        if~isempty(wInf)
            if cflag

                T=blkdiag(T,1);
            else
                T=sparse(blkdiag(full(T),1));
            end
        end
        A1=real(T*A*T');
        if cflag

            dA1=decomposition(A1,'CheckCondition',false);
            doGeneralizedEigenvalue=isIllConditioned(dA1);
        else
            dA1=A1;
            doGeneralizedEigenvalue=false;
        end
        if~doGeneralizedEigenvalue
            J=dA1\E;
            J=full(J);
            if cflag
                ipol=eig(J);
            else
                ipol=eigWorkaround(J);
            end
            [~,iindx]=sort(abs(ipol),'descend');
            ipol=ipol(iindx);





            rratio=abs(ipol(end-expectedInfEigenvalues+1)/ipol(end-expectedInfEigenvalues));
            if rratio>1e-5&&cflag


                doGeneralizedEigenvalue=true;
            end
            ipol(end-expectedInfEigenvalues+1:end)=[];
            allpol=1./ipol;
        end
        if doGeneralizedEigenvalue
            A1f=full(A1);
            Ef=full(E);
            allpolGE=eig(A1f,Ef);
            allpol=allpolGE(isfinite(allpolGE));
            if zff
                allpol=allpol(allpol~=0);
            end
            if~cflag
                temp=allpol;
                allpol=conj(cplxpair(temp,1e-6));
            end
        end
        curnp=length(allpol);
        if printflag
            fprintf('Number of poles, np=%d\n',curnp);
        end
        if args.Causal
            if isempty(args.NumPoles)

                pol=allpol(real(allpol)<0);
                if printflag
                    fprintf('After removing unstable poles, np=%d\n',length(pol));
                end
            else

                pol=-abs(real(allpol))+1i*imag(allpol);
                if printflag
                    fprintf('After flipping unstable poles, np=%d\n',length(pol));
                end
            end
            if isfinite(args.QLimit)
                qpol=0.5*abs(pol)./(-real(pol));
                pol=pol(qpol<args.QLimit);
                if printflag
                    fprintf('After removing high-Q poles, np=%d\n',length(pol));
                end
            end
        else
            pol=allpol;
        end
    else
        pol=zeros(0,1);
    end
    if args.TendsToZero
        pol(imag(pol)==0&real(pol)<-200*pi)=[];
    else
        pol(abs(pol)>1e14)=[];
    end
    pol=conj(cplxpair(pol));
end

function[d,cCA,polCA,errdbCRCA]=getResiduesAndResponse(data,s,pol,tol,tendsToZero,...
    errorMetric,isCausal,noiseFloor,numPoles,maxPoles)
    polCA=cell(1,1);
    cCA=cell(1,1);
    errdbCRCA=cell(1,1);
    polCA{1,1}=pol;
    [~,d,cCA{1,1},resp]=rf.internal.rational.calculateResidues(data,s,pol,tendsToZero,errorMetric,noiseFloor);
    errCR=resp-data;
    errdbCRCA{1,1}=rf.internal.rational.errcalc(errCR,data,errorMetric,noiseFloor);



    doReduceOrder=isempty(coder.target);


    doReduceOrder=doReduceOrder&&isCausal;

    doReduceOrder=doReduceOrder&&length(pol)>=2;

    if isempty(numPoles)
        doReduceOrder=doReduceOrder&&((length(pol)>=2&&length(pol)<=10)||errdbCRCA{1,1}<tol);


        doReduceOrder=doReduceOrder&&length(pol)>=2&&length(pol)<=50;

    end

    if doReduceOrder
        [polCAred,cCAred,respRed]=reduceOrder(pol,cCA{1,1},d,s,numPoles,maxPoles);
        for k=1:length(polCAred)
            polCA{k+1,1}=polCAred{k};
            cCA{k+1,1}=cCAred{k};
            errCRm1=respRed{k}-data;
            errdbCRCA{k+1,1}=rf.internal.rational.errcalc(errCRm1,data,errorMetric,noiseFloor);
        end
        polCA=flipud(polCA);
        cCA=flipud(cCA);
        errdbCRCA=flipud(errdbCRCA);
    end

end

function ew=eigWorkaround(x)
    [Ur,Tr]=schur(x,'real');
    [~,Tc]=rsf2csf(Ur,Tr);
    ew=diag(Tc);
end

function Rout=justRofM(M,MhM)
    [Rout,flag]=chol(MhM);
    if flag~=0
        Rout=justR(M);
    end
end

function R=justR(A)
    if size(A,1)<size(A,2)
        [~,R]=qr(A,0);
    else
        X=qr(A);
        n=size(A,2);
        X=X(1:n,:);
        R=triu(X);
    end
end

function[polesOut,cOut,resp]=reduceOrder(poles,c,d,s,numPoles,maxPoles)






    nPoles=numel(poles);
    m=size(c,2);
    A=zeros(nPoles);
    B=zeros(nPoles,1);
    C=zeros(m,nPoles);
    r=1:nPoles;
    [VAr,DAr]=cdf2rdf(eye(nPoles),diag(poles));
    A(r,r)=real(DAr);
    B(r,1)=real(VAr\ones(length(r),1));
    C(:,r)=real(c.'*VAr);

    At=A.';
    P=sylvester(A,At,B*B.');
    Q=sylvester(At,A,C.'*C);
    [U,T]=schur(P*Q);
    dT=diag(T);
    [~,pA]=sort(dT,'descend');
    [~,rA]=sort(pA);
    [UA,~]=ordschur(U,T,rA);
    [~,pD]=sort(dT,'ascend');
    [~,rD]=sort(pD);
    [UD,~]=ordschur(U,T,rD);

    if isempty(numPoles)
        kRange=max(nPoles-maxPoles,1):nPoles-1;
    else
        kRange=nPoles-numPoles;
        if kRange<1
            polesOut=cell(0,1);
            cOut=cell(0,1);
            resp=cell(0,1);
            return
        end
    end
    kInd=1;
    for k=kRange

        VL=UA(:,k+1:nPoles);
        VR=UD(:,1:nPoles-k);

        E=VL.'*VR;
        [UE,SE,VE]=svd(E);
        X=diag(1./sqrt(diag(SE)));
        SL=VL*UE*X;
        SR=VR*VE*X;

        Ax=SL.'*A*SR;
        Bx=SL.'*B;
        Cx=C*SR;

        [VAx,DAx]=eig(Ax,'vector');


        ind=real(DAx)>0;
        if any(ind)
            DAx(ind)=-real(DAx(ind))+1i*imag(DAx(ind));

        end

        Br=VAx\Bx;
        Cr=Cx*VAx;
        cOuttemp=Br.*Cr.';

        polesOut{kInd}=conj(cplxpair(DAx));


        X=repmat(DAx,[1,length(polesOut{kInd})]);
        [~,closestIndex]=min(abs(X-polesOut{kInd}.'));
        cOut{kInd}=cOuttemp(closestIndex,:);


        realPoles=imag(polesOut{kInd})==0;
        cOut{kInd}(realPoles,:)=real(cOut{kInd}(realPoles,:));



        for ii=1:2:length(realPoles)
            if~realPoles(ii)
                creal=0.5*(real(cOut{kInd}(ii))+real(cOut{kInd}(ii+1)));
                cimag=0.5*(imag(cOut{kInd}(ii))-imag(cOut{kInd}(ii+1)));
                cOut{kInd}(ii)=creal+1i*cimag;
                cOut{kInd}(ii+1)=creal-1i*cimag;
            end
        end

        resp{kInd}=complex(repmat(d,length(s),1));
        if isempty(coder.target)
            y=1./(s-polesOut{kInd}.');
        else

            yrecip=bsxfun(@minus,s,polesOut{kInd}.');
            y=1./yrecip;
        end
        resp{kInd}=resp{kInd}+y*cOut{kInd};

        kInd=kInd+1;
    end

end


