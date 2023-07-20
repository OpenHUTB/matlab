function passfit=makepassivecore(fit,S,varargin)



























    narginchk(2,4)
    nargoutchk(0,1)
    validateattributes(fit,{'rfmodel.rational'},{'square'})
    validateattributes(S,{'sparameters'},{'scalar'})
    if size(fit,1)~=S.NumPorts
        error(message('rf:rfmodel:rational:makepassive:SizeMismatch',...
        size(fit,1),S.NumPorts))
    end

    if nargin>2
        p=inputParser;
        p.CaseSensitive=false;
        p.addParameter('Display','off');
        p.parse(varargin{:});
        verbose=strcmpi(p.Results.Display,'on');
    else
        verbose=false;
    end

    [maxSVFreq,maxSV,peakFreqs,peakValues]=normPeaks(fit);
    iter=0;
    if verbose
        fprintf('\nITER\t H-INFTY NORM\tFREQUENCY\t\tERRDB\t\tCONSTRAINTS\n')
        fprintf('%d\t\t%s\t%s\t%g\n',...
        iter,formatMaxSV(maxSV),formatFreq(maxSVFreq),errdb(fit,S))
    end

    passfit=copy(fit);
    if 0<maxSV&&maxSV<=1


        return
    end

    [sss.A,sss.B,sss.C,sss.D,sharedPoles]=abcd(fit);
    if~sharedPoles
        error(message('rf:rfmodel:rational:makepassive:NotSharedPoles',...
        size(fit,1)))
    end
    if condest(sss.A)/sqrt(size(sss.A,1))>1e15
        error(message('rf:rfmodel:rational:makepassive:IllConditionedPoles'))
    end

    coelho=prepareForPassivityEnforcement(S,sss);
    ns=size(sss.A,1);
    np=size(sss.D,1);

    sssScaled.A=sss.A/coelho.fscale;
    At=sssScaled.A.';
    sssScaled.B=sss.B/coelho.Bscale;
    if all(sss.C(:)==0)&&all(sss.D(:)==0)
        xTildeBest=0.5*coelho.twiceUtG;
        xbest=coelho.Psdecomp\reshape(xTildeBest,[],np);
        matx=reshape(xbest,ns+np,np);
        sssScaled.C=matx(1:ns,:).';
        sssScaled.D=matx(ns+(1:np),:).';

        sss.C=coelho.Cscale*sssScaled.C;
        sss.D=sssScaled.D;
        updateFit(passfit,sss);
        [maxSVFreq,maxSV,peakFreqs,peakValues]=normPeaks(passfit);
        if verbose
            fprintf('%d\t\t%s\t%s\t%g\n',...
            iter,formatMaxSV(maxSV),formatFreq(maxSVFreq),errdb(passfit,S))
        end
    else
        sssScaled.C=sss.C/coelho.Cscale;
        sssScaled.D=sss.D;
    end

    freqconstraint=[0;inf];
    Inp=eye(np);
    while maxSV>1&&iter<20
        idx=find(peakValues>1);
        if length(idx)>20
            [~,idxDescending]=sort(peakValues,'descend');
            idx=idxDescending(1:20);
        end
        freqconstraint=[freqconstraint;peakFreqs(idx)/coelho.fscale;];%#ok<*AGROW>
        freqconstraint=unique(freqconstraint);
        nc=length(freqconstraint);
        for k=1:nc
            [Mk,Ms{k}]=ABtoM(sssScaled,freqconstraint(k),coelho,At);
            Mtildek=TvecMat(np,np)*conj(Mk);
            Omega{k}=formOmegaAndK(Mk,Mtildek);
        end
        Mmat=sparse(cell2mat(Ms.'));
        clear('Ms')

        matx=[sssScaled.C.';sssScaled.D.'];
        xstart=matx(:)/(1.01*maxSV);
        xTilde=reshape(coelho.Ps*reshape(xstart,[],np),[],1);


        ofx=LeastSquaresErrorOfXTilde(xTilde,coelho);
        bfx=0;
        xtrs=reshape(xTilde,[],np);
        allH=Mmat*xtrs;
        for k=1:nc
            H=allH((1:np)+(k-1)*np,:);
            svH=svd(H);
            eigE=[1-svH;1+svH];
            logdetE=sum(log(eigE));
            bfx=bfx-logdetE;
        end

        mu=ofx/bfx;
        for outerIter=1:20
            oldDirec=[];
            oldNegGrad=[];
            funAtIter=zeros(100,1);
            for innerIter=1:100
                infeasible=false;
                [ofx,gradfx]=LeastSquaresErrorOfXTilde(xTilde,coelho);
                fx=ofx;
                zgx=gradfx;
                xtrs=reshape(xTilde,[],np);
                allH=Mmat*xtrs;
                for k=1:nc
                    H=allH((1:np)+(k-1)*np,:);
                    svH=svd(H);
                    eigE=[1-svH;1+svH];
                    if min(eigE)<0
                        infeasible=true;
                        break;
                    end
                    logdetE=sum(log(eigE));
                    E=[Inp,H';H,Inp];
                    s=warning('off','MATLAB:nearlySingularMatrix');
                    invEt=inv(E).';
                    diffLogDet=invEt(:).';
                    warning(s)
                    gradLogDetwrtx=real(diffLogDet*Omega{k});
                    zgx=zgx-mu*gradLogDetwrtx;
                    fx=fx-mu*logdetE;
                end
                if infeasible
                    break;
                end
                candDirec=-zgx.';
                bpr=findNewDirec(candDirec,oldNegGrad);
                oldNegGrad=candDirec;
                if bpr==0
                    direc=candDirec;
                else
                    direc=candDirec+bpr*oldDirec;
                end
                h0mat=Mmat*reshape(xTilde,[],np);
                h1mat=Mmat*reshape(direc,[],np);
                h0=cell(nc,1);
                h1=cell(nc,1);
                tmax=1e30;
                zz=zeros(np);
                ee=eye(np);
                for k=1:nc
                    h0{k}=h0mat((1:np)+(k-1)*np,:);
                    h1{k}=h1mat((1:np)+(k-1)*np,:);






                    eh0=[ee,h0{k};h0{k}',ee];
                    eh1=[zz,h1{k};h1{k}',zz];
                    warnstate=warning('OFF','MATLAB:nearlySingularMatrix');
                    gev=-1./real(eig(eh0\eh1));
                    warning(warnstate);
                    gevpos=gev(gev>0);
                    assert(~isempty(gevpos));
                    tmax=min(tmax,min(gevpos));
                end
                fun=@(t)Objective(t,xTilde,direc,coelho,nc,h0,h1,mu);

                assert(tmax~=1e30);
                [tbest,funbest]=findMin(fun,tmax);
                funAtIter(innerIter)=funbest;
                if tbest==0||...
                    (innerIter>5&&...
                    funAtIter(innerIter-5)-funbest<1e-4*funbest+eps)
                    break
                end
                xTilde=xTilde+tbest*direc;
                oldDirec=direc;
            end
            mu=mu/10;
            if mu<1e-7
                break;
            end
        end

        xbest=coelho.Psdecomp\reshape(xTilde,[],np);
        matx=reshape(xbest,ns+np,np);
        sssScaled.C=matx(1:ns,:).';
        sssScaled.D=matx(ns+(1:np),:).';

        sss.C=coelho.Cscale*sssScaled.C;
        sss.D=sssScaled.D;
        updateFit(passfit,sss);
        [maxSVFreq,maxSV,peakFreqs,peakValues]=normPeaks(passfit);
        iter=iter+1;
        if verbose
            fprintf('%d\t\t%s\t%s\t%-8g\t%d\n',...
            iter,formatMaxSV(maxSV),formatFreq(maxSVFreq),errdb(passfit,S),nc)
        end
    end
    if maxSV>1
        scale=1./((1+sqrt(eps))*maxSV);
        for k=1:numel(passfit)
            passfit(k).C=passfit(k).C*scale;
            passfit(k).D=passfit(k).D*scale;
        end
        [maxSVFreq,maxSV]=normPeaks(passfit);
        if verbose
            fprintf('%d\t\t%s\t%s\t%8g\t%d\n',...
            iter+1,formatMaxSV(maxSV),formatFreq(maxSVFreq),errdb(passfit,S),nc)
        end
    end
    if verbose
        fprintf('\n')
    end
    assert(all([fit(:).A]==[passfit(:).A],'all'))
    assert(all([fit(:).B]==[passfit(:).B],"all"))
end

function err=errdb(fit,S)
    resp=freqresp(fit,S.Frequencies);
    if isvector(resp)
        resp=reshape(resp,1,1,[]);
    end
    numer=sum(abs(resp-S.Parameters).^2,3);
    denom=sum(abs(S.Parameters).^2,3);
    rat=numer./denom;
    errMat=10*log10(rat);
    errMat(~isfinite(errMat))=-1e30;
    err=max(errMat(:));
end

function Tmn=TvecMat(m,n)
    d=m*n;
    i=1:d;
    rI=reshape(i,m,n)';
    Tmn=sparse(d,d);
    Tmn(i+(rI(:)'-1)*d)=1;
end

function Omega=formOmegaAndK(M,Mtilde)
    nx=size(M,2);
    npsq=size(M,1);
    np=floor(sqrt(npsq)+0.5);
    assert(npsq==np*np)
    assert(isequal(size(Mtilde),size(M)))
    Omega=sparse(4*npsq,nx);
    oiv=zeros(npsq,1);
    otiv=zeros(npsq,1);
    for j=1:np
        for i=1:np
            mi=(j-1)*np+i;
            oiv(mi)=(j-1)*2*np+np+i;
            otiv(mi)=2*npsq+(j-1)*2*np+i;
        end
    end
    Omega(oiv,:)=M;
    Omega(otiv,:)=Mtilde;
end

function[err,gEv,xTildeBest]=LeastSquaresErrorOfXTilde(xTilde,coelho)
    err=coelho.const+xTilde.'*(xTilde-coelho.twiceUtG);
    if nargout>=2
        gEv=(2*xTilde-coelho.twiceUtG).';
    end
    if nargout>=3
        xTildeBest=0.5*coelho.twiceUtG;
    end
end

function[tbest,fbest]=findMin(f,maxStep)
    a=0;
    fa=f(a);
    assert(~isnan(fa))
    c=0.999999*maxStep;
    fc=f(c);
    b=0.5*(a+c);
    fb=f(b);
    while fb>fa||fb>fc
        if fb>fc
            b=0.5*(b+c);
        else
            b=0.5*(a+b);
        end
        fb=f(b);
    end
    [tbest,fbest]=rfmodel.rational.rfmin(a,b,c,f,1e-6);
end

function zx=Objective(t,x0,zgxt,coelho,nc,h0,h1,mu)
    x=x0+t*zgxt;
    zx=LeastSquaresErrorOfXTilde(x,coelho);
    for k=1:nc
        H=h0{k}+t*h1{k};
        svH=svd(H);
        eigE=[1-svH;1+svH];
        if mu~=0&&min(eigE)<0
            zx=NaN;
            return
        end
        zx=zx-mu*sum(log(eigE));
    end
end

function bpr=findNewDirec(g,og)
    if isempty(og)
        bpr=0;
    else
        bpr=max(0,g'*(g-og)/(og'*og));
    end
end

function[Q,R]=rrqr(Anz,nz,basetol,sizeA)


    [Unz,Snz,Vnz]=svd(Anz,'econ');
    tol=max(sizeA)*basetol*(Snz(1,1));
    r=diag(Snz)>tol;
    Q=Unz(:,r);
    Rnz=Snz(r,r)*Vnz(:,r)';
    R=zeros(size(Rnz,1),sizeA(2));
    R(:,nz)=Rnz;
end

function coelho=prepareForPassivityEnforcement(S,sss)

    coelho.Bscale=max(abs(sss.B(:)));
    if isempty(coelho.Bscale)
        coelho.Bscale=1;
        coelho.Cscale=1;
        coelho.fscale=1;
    else
        coelho.Cscale=max(abs(sss.C(:)));
        if coelho.Cscale==0
            coelho.fscale=S.Frequencies(end);
            coelho.Cscale=coelho.fscale/coelho.Bscale;
        else
            coelho.fscale=coelho.Bscale*coelho.Cscale;
        end
    end
    A=sss.A/coelho.fscale;
    B=sss.B/coelho.Bscale;
    m=S.NumPorts;
    N=length(S.Frequencies);
    svec=S.Frequencies/coelho.fscale*2i*pi;
    Gpq=zeros(m,m,2*N);
    for p=1:m
        for q=1:m
            Gpq(p,q,1:N)=squeeze(real(S.Parameters(p,q,:)));
            Gpq(p,q,(1:N)+N)=squeeze(imag(S.Parameters(p,q,:)));
        end
    end
    IA=speye(size(sss.A));
    BoA=cell(N,1);
    for k=1:N
        BoA{k}=(IA*svec(k)-A)\B;
    end
    nzpattern=BoA{1}~=0;
    clear('A')
    clear('IA')
    clear('B')
    sizeFq=[2*N,size(sss.B,1)+m];
    for q=1:m
        nz=[find(nzpattern(:,q));size(sss.B,1)+q];
        Fqnz=zeros(2*N,length(nz));
        for k=1:N
            bz=full(BoA{k}(nzpattern(:,q),q));
            Jsk=[bz;1].';
            Fqnz(k,:)=real(Jsk);
            Fqnz(k+N,:)=imag(Jsk);
        end
        [Qq{q},Rq{q}]=rrqr(Fqnz,nz,eps,sizeFq);
        Rq{q}=sparse(Rq{q});
        clear('Fqnz')
        Qx{q}=(eye(size(Qq{q},1))-Qq{q}*Qq{q}.');
    end
    clear('BoA')
    for p=1:m
        for q=1:m
            Gtemp=squeeze(Gpq(p,q,:));
            dsq(p,q)=Gtemp.'*Qx{q}*Gtemp;
            QtG{p,q}=Qq{q}.'*Gtemp;
        end
    end
    clear('Qx')
    clear('Qq')


    Rd=[];
    Gd=[];
    Gdmat=[];
    for i=1:m
        Gdi=[];
        for j=1:m
            Gdi=[Gdi;QtG{i,j}];
        end
        Gd=[Gd;Gdi];
        Gdmat=[Gdmat,Gdi];
        Rd=[Rd;Rq{i}];
        Rq{i}=[];
    end
    clear('Rq');
    [Qm,Rm,em]=qr(Rd,0);
    if min(abs(full(diag(Rm))))==0
        [Qm,Sm,Vm]=svd(full(Rd),0);
        Rm=Sm*Vm';
        em=1:size(Rm,1);
    end
    clear('Rd');
    tempmat=Qm.'*Gdmat;
    clear('Qm');
    clear('Gdmat');
    coelho.twiceUtG=2*tempmat(:);
    clear('tempmat');
    coelho.const=sum(dsq(:))+Gd.'*Gd;

    coelho.Ps(:,em)=Rm;
    coelho.Psdecomp=decomposition(coelho.Ps);

end

function[M,Ms]=ABtoM(sss,f,coelho,At)
    ns=size(sss.A,1);
    np=size(sss.D,1);
    ID=eye(np);
    IA=speye(ns);
    if isinf(f)
        Jtilde=zeros(size(sss.B.'));
    else
        Jtilde=sss.B.'/(-2i*pi*f*IA-At);
    end
    Ms=[Jtilde,ID]/coelho.Psdecomp;
    M=kron(speye(np),Ms);
end

function U=rdf2cdf(T)

    n=size(T,2);
    Udiags=zeros(n,3);
    m=n;
    Gt=[1i,1;-1,-1i]/sqrt(2);
    while m>1
        sd=T(m,m-1);
        if sd==0
            Udiags(m,2)=1;
            nextm=m-1;
        else
            Udiags(m-1,2)=Gt(1,1);
            Udiags(m-1,1)=Gt(2,1);
            Udiags(m,3)=Gt(1,2);
            Udiags(m,2)=Gt(2,2);
            nextm=m-2;
        end
        m=nextm;
    end
    if m==1
        Udiags(m,2)=1;
    end
    U=spdiags(Udiags,[-1,0,1],n,n);
end

function updateFit(fit,sss)
    VA=rdf2cdf(sss.A);
    Bc=VA\sss.B;
    Cc=sss.C*VA;
    Bct=Bc.';

    np=size(fit,1);
    onpsq=ones(np,1);
    kBct=kron(Bct,onpsq);
    residues=(kBct.*kron(onpsq,Cc)).';


    logicalCc=ones(size(sss.C));

    logicalResidues=(kBct.*kron(onpsq,logicalCc)).';

    for k=1:numel(fit)
        fit(k).D=sss.D(k);
        idx=logicalResidues(:,k)~=0;
        fit(k).C=residues(idx,k);
    end
end

function str=formatFreq(f)
    [freq,~,u]=engunits(f);
    if isempty(u)
        str=sprintf('%-8g  Hz',freq);
    else
        str=sprintf('%-8g %sHz',freq,u);
    end
end

function str=formatMaxSV(x)
    if x>=2||x==1||x==0
        str=sprintf('%13g',x);
    elseif x<1
        str=sprintf('1 - %.3e',1-x);
    else
        str=sprintf('1 + %.3e',x-1);
    end
end
