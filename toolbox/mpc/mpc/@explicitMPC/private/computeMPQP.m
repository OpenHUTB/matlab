function mpqpsol=computeMPQP(Q,F,c,G,W,S,thmin,thmax,verbose,tol)

    if nargin<9||isempty(verbose),
        verbose=1;
    end

    mpqpsol=struct('F',[],'G',[],'H',[],'K',[]);

    nr=0;

    [q,n]=size(G);
    m=numel(thmin);

    zerotol=tol.zerotol;
    removetol=tol.removetol;
    flattol=tol.flattol;
    normalizetol=tol.normalizetol;
    maxiterNNLS=tol.maxiterNNLS;
    maxiterQP=tol.maxiterQP;
    maxiterBS=tol.maxiterBS;
    polyreduction=tol.polyreduction;

    Hth=[eye(m);-eye(m)];
    Kth=[thmax;-thmin];
    nKth=numel(Kth);

    H=[G,-S;zeros(nKth,n),Hth];
    K=[W;Kth];
    [H,K]=polynormalize_nnls(H,K,normalizetol);
    if polyempty_nnls(H,K,zerotol,maxiterNNLS)
        ctrlMsgUtils.error('MPC:computation:EMPCMPQPError1');
    end
    [~,~,kept]=polyreduce_nnls(H,K,removetol,zerotol,maxiterNNLS,polyreduction);
    kept=kept(kept<=q);
    q=numel(kept);

    G=G(kept,:);
    W=W(kept);
    S=S(kept,:);

    Linv=chol(Q,'lower');
    Linv=Linv\eye(n);
    Qinv=Linv'*Linv;

    D=S+G*Qinv*F;
    d=W+G*Qinv*c;
    Hd=G*Qinv*G';
    EXPLORED=containers.Map('KeyType','char','ValueType','double');

    I0=get_initial;

    UNEXPLORED=struct('I',I0);

    switch verbose
    case 1
        fprintf('\n\nRegions found / unexplored: %8d/%8d',0,numel(UNEXPLORED));
    case 2
        hwait=waitbar(0);
    end

    [~,II]=create_region(I0,true);
    for h=1:numel(II),
        UNEXPLORED(end+1)=struct('I',II{h});
    end
    UNEXPLORED(1)=[];

    while~isempty(UNEXPLORED),
        I=UNEXPLORED(1).I;
        UNEXPLORED(1)=[];

        [fulldim,II]=create_region(I,false);
        if fulldim,
            for h=1:numel(II),
                UNEXPLORED(end+1)=struct('I',II{h});
            end
        end
    end

    switch verbose
    case 1
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%8d/%8d\n\n',nr,0);
    case 2
        close(hwait);
    end


    function I0=get_initial
        [H,K]=polynormalize_nnls([-G*Qinv*F-S;Hth],[W+G*Qinv*c;Kth],normalizetol);
        if~polyempty_nnls(H,K,zerotol,maxiterNNLS),

            I0=[];
        else
            thbar=(thmax+thmin)/2;
            Y=F'*Qinv*F+eye(m);

            iA=false(q+numel(Kth),1);
            QQ=[Q,F;F',Y];

            LLinv=chol(QQ,'lower');
            LLinv=LLinv\eye(n+m);
            QQinv=LLinv'*LLinv;
            ff=[c;thbar];

            numofcons=length(iA);
            numofvars=size(LLinv,1);
            [xth,yth,status]=qpkwik_double_mex(LLinv,QQinv,ff,-[G,-S;zeros(nKth,n),Hth],-[W;Kth],iA,int32(maxiterQP),int32(numofcons),int32(numofvars),int32(0),1e-6);

            switch status
            case 0
                ctrlMsgUtils.error('MPC:computation:EMPCMPQPError2');
            case-1
                ctrlMsgUtils.error('MPC:computation:EMPCMPQPError3');
            case-2
                ctrlMsgUtils.error('MPC:computation:EMPCMPQPError4');
            end

            x=xth(1:n);
            th=xth(n+1:n+m);
            I0=sort(find(G*x-W-S*th>=-zerotol));

            nR=rank(G(I0,:));

            if nR<numel(I0),
                [~,isort]=sort(-yth(I0));

                I1=[];

                GI1=zeros(0,n);
                j=0;
                i=1;
                while j<nR,
                    aux=G(I0(isort(i)),:);
                    if norm(aux,'inf')>=zerotol,
                        aux2=[GI1;aux];
                        aux3=rank(aux2,zerotol);
                        if aux3>j,
                            GI1=aux2;
                            I1=[I1;I0(isort(i))];
                            j=aux3;
                        end
                    end
                    i=i+1;
                end
                I0=sort(I1);
            end
        end
    end


    function[fulldim,II]=create_region(I,first)

        II=[];

        if isempty(I),
            aux='0';
        else
            aux=sprintf('%d ',I);
        end
        if isKey(EXPLORED,aux)

            fulldim=false;
            return
        else
            EXPLORED(aux)=true;
        end

        nI=numel(I);

        if nI==0,

            Fx=-Qinv*F;
            Gx=-Qinv*c;

            H=[-D;Hth];
            K=[d;Kth];

            [H,K]=polynormalize_nnls(H,K,normalizetol);
            empty=polyempty_nnls(H,K,zerotol,maxiterNNLS);
            if empty,
                fulldim=false;
                ip=(1:numel(K))';
            else
                [H,K,ip]=polyreduce_nnls(H,K,removetol,zerotol,maxiterNNLS,polyreduction);
                th0=polypoint_nnls(H,K,zerotol,maxiterNNLS);
                fulldim=polyfulldim_nnls(H,K,flattol,th0,zerotol,maxiterNNLS,maxiterBS);
            end

            if fulldim||first,
                iH=find(ip>q);
                nH=numel(iH);
                ip=ip(ip<=q);
                iHp=(1:numel(K)-nH)';
                id=[];
                iHd=[];

                II=get_neighbors(I,numel(K),ip,iHp,iH,id,iHd,false,[],[],[]);
            end

        else
            Iq=(1:q)';
            J=Iq;J(I)=[];

            GI=G(I,:);

            [QI,RI,EI]=qr(GI);

            nR=qr_rank(RI);

            if nR==nI,
                Fy=zeros(q,m);
                Gy=zeros(q,1);
                Fy(I,:)=-Hd(I,I)\D(I,:);
                Gy(I)=-Hd(I,I)\d(I,:);

                Fx=-Qinv*(F+GI'*Fy(I,:));
                Gx=-Qinv*(c+GI'*Gy(I,:));
                H=[-Fy(I,:);-Hd(J,I)*Fy(I,:)-D(J,:);Hth];
                K=[Gy(I);Hd(J,I)*Gy(I,:)+d(J,:);Kth];
                [H,K]=polynormalize_nnls(H,K,normalizetol);
                empty=polyempty_nnls(H,K,zerotol,maxiterNNLS);
                if empty,
                    fulldim=false;
                else
                    [H,K,kept]=polyreduce_nnls(H,K,removetol,zerotol,maxiterNNLS,polyreduction);
                    th0=polypoint_nnls(H,K,zerotol,maxiterNNLS);
                    fulldim=polyfulldim_nnls(H,K,flattol,th0,zerotol,maxiterNNLS,maxiterBS);
                end
                if fulldim||first,
                    iH=find(kept>q);
                    nH=numel(iH);

                    kept=kept(kept<=q);
                    ip=kept.*(kept>nI);
                    ip=J(ip(ip>0)-nI);

                    np=numel(ip);
                    iHp=(numel(K)-np-nH+1:numel(K)-nH)';

                    id=kept(kept<=nI);
                    id=I(id);
                    iHd=(1:numel(id))';
                    if~(any(sum(abs([Fy(I,:),Gy(I)]),2)<=zerotol)),
                        II=get_neighbors(I,numel(K),ip,iHp,iH,id,iHd,false,QI,RI,EI);
                    else
                        II=get_neighbors(I,numel(K),[],[],iH,[],[],true,QI,RI,EI);
                    end
                end
            else
                if rank([GI,-S(I,:),W(I)])>nR,

                    fulldim=false;
                else
                    iEI=inv(EI);
                    QtI=iEI*Qinv*iEI';
                    MI=-(RI(1:nR,:)*QtI*RI(1:nR,:)')\(QI(:,1:nR)');
                    K1=MI*D(I,:);
                    h1=MI*d(I,:);
                    Fx=-Qinv*(F+iEI'*RI(1:nR,:)'*K1);
                    Gx=-Qinv*(c+iEI'*RI(1:nR,:)'*h1);
                    AA=[G(J,:)*Fx-S(J,:),zeros(q-nI,nI-nR);
                    -QI(:,1:nR)*K1,-QI(:,nR+1:nI)];
                    bb=[W(J,:)-G(J,:)*Gx;QI(:,1:nR)*h1];

                    [AA,bb]=polynormalize_nnls(AA,bb,normalizetol);
                    empty=polyempty_nnls(AA,bb,zerotol,maxiterNNLS);
                    if empty,
                        fulldim=false;
                    else
                        [AA,bb]=polyreduce_nnls(AA,bb,removetol,zerotol,maxiterNNLS,polyreduction);
                        [H,K,empty]=polyproject_nnls(AA,bb,(m+1:m+nI-nR)');
                        if empty,
                            fulldim=false;

                        else
                            n1=numel(K);
                            [H,K,kept]=polyreduce_nnls([H;Hth],[K;Kth],removetol,zerotol,maxiterNNLS,polyreduction);
                            th0=polypoint_nnls(H,K,zerotol,maxiterNNLS);
                            fulldim=polyfulldim_nnls(H,K,flattol,th0,zerotol,maxiterNNLS,maxiterBS);
                            if fulldim||first,
                                iH=find(kept>n1);
                                II=get_neighbors(I,numel(K),[],[],iH,[],[],true,QI,RI,EI);
                            end
                        end
                    end
                end
            end
        end

        if fulldim||first,

            if fulldim,
                nr=nr+1;

                switch verbose
                case 1,
                    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%8d/%8d',nr,numel(UNEXPLORED));
                case 2
                    if nr/19==round(nr/19),
                        waitbar(nr/(nr+numel(UNEXPLORED)),hwait,sprintf('%8d regions found',nr));
                    end
                end

                mpqpsol(nr).F=Fx;
                mpqpsol(nr).G=Gx;
                mpqpsol(nr).H=H;
                mpqpsol(nr).K=K;
            end
        else

        end
    end


    function nR=qr_rank(R)

        if min(size(R))==1,
            dR=abs(R(1));
        else
            dR=abs(diag(R));
        end
        nR=sum(dR>max(size(R))*eps(max(dR)));
    end


    function II=get_neighbors(I,nK,ip,iHp,iH,id,iHd,ext,QI,RI,EI)
        II={};
        nII=0;
        n1=nK-numel(iH);
        nI=numel(I);

        normalized=false;

        for h=1:n1
            found=false;
            if any(iHp==h)&&~ext,
                if numel(I)==n,
                    ext=true;
                else
                    index=ip(iHp==h);

                    if isempty(RI),
                        Ii=index;
                        found=true;
                    else
                        [~,R2]=qrupdate([QI,zeros(nI,1);zeros(1,nI),1],[RI;zeros(1,n)],[zeros(nI,1);1],(G(index,:)*EI)');

                        nR2=qr_rank(R2);

                        if nR2==nI+1,
                            Ii=sort([I;index]);
                            found=true;
                        else
                            ext=true;
                        end
                    end
                end
            elseif any(iHd==h)&&~ext,
                index=id(iHd==h);
                Ii=sort(I);Ii(Ii==index)=[];
                found=true;
            end
            if ext,
                if~normalized,
                    for j=1:nK,
                        ni=norm(H(j,:));
                        H(j,:)=H(j,:)/ni;
                        K(j,:)=K(j,:)/ni;
                    end
                    epsil=1e-4;
                    normalized=true;
                end

                C=eye(nK);
                C(:,h)=[];
                [~,th]=computePartialNNLS(C,H,K,maxiterNNLS,zerotol);
                smin=min(K([1:h-1,h+1:nK])-H([1:h-1,h+1:nK],:)*th);
                smax=100;
                normH=ones(nK,1);normH(h)=0;

                while smax-smin>flattol,
                    s=(smax+smin)/2;
                    [sigma,th1]=computePartialNNLS(C,H,K-normH*s,maxiterNNLS,zerotol);
                    if norm(H*th1+C*sigma-K+normH*s)<=zerotol,
                        smin=s;
                        th=th1;
                    else
                        smax=s;
                    end
                end
                th=th+H(h,:)'*epsil;

                numofcons=size(G,1);
                numofvars=size(Linv,1);
                [xth,~,status]=qpkwik_double_mex(Linv,Qinv,F*th+c,-G,-(W+S*th),false(q,1),int32(maxiterQP),int32(numofcons),int32(numofvars),int32(0),1e-6);
                switch status
                case 0
                    ctrlMsgUtils.error('MPC:computation:EMPCMPQPError2');
                case-1

                case-2
                    ctrlMsgUtils.error('MPC:computation:EMPCMPQPError4');
                otherwise
                    Ii=sort(find(G*xth-W-S*th>=-zerotol));
                    found=true;
                end
            end
            if found,
                nII=nII+1;
                II{nII}=Ii;
            end
        end
    end
end
