function[a,b,c,e]=reduceEBCs(a,b,c,e)














    ns=size(a,1);


    while ns>0
        M=[b,e];
        [p,q,~,~,cc,rr]=dmperm(M);
        rho=rr(5)-rr(4);
        if rho==0
            break;
        end


        ix=p(rr(3):rr(5)-1);
        mu=rr(4)-rr(3);
        if mu>0
            [qL,~,~]=qr(M(ix,q(cc(4):cc(5)-1)));
            b(ix,:)=qL'*b(ix,:);a(ix,:)=qL'*a(ix,:);e(ix,:)=qL'*e(ix,:);
        end

        a2=a(ix(mu+1:mu+rho),:);
        jnz=find(any(a2,1));
        [qR,~]=qr(a2(:,jnz)');
        qR=qR(:,rho+1:end);
        jx=jnz(rho+1:end);
        c(:,jx)=c(:,jnz)*qR;a(:,jx)=a(:,jnz)*qR;e(:,jx)=e(:,jnz)*qR;


        ikeep=1:ns;ikeep(ix(mu+1:mu+rho))=[];
        jkeep=1:ns;jkeep(jnz(1:min(rho,end)))=[];jkeep=jkeep(1:ns-rho);
        a=a(ikeep,jkeep);e=e(ikeep,jkeep);b=b(ikeep,:);c=c(:,jkeep);
        ns=ns-rho;
    end



    while ns>0
        M=[c;e];
        [p,q,~,~,cc,rr]=dmperm(M);
        rho=cc(2)-cc(1);
        if rho==0
            break;
        end


        jx=q(cc(1):cc(3)-1);
        nu=cc(3)-cc(2);
        if nu>0
            [qR,~,~]=qr(M(p(rr(1):rr(2)-1),jx)');
            c(:,jx)=c(:,jx)*qR;a(:,jx)=a(:,jx)*qR;e(:,jx)=e(:,jx)*qR;
        end

        a2=a(:,jx(nu+1:nu+rho),:);
        inz=find(any(a2,2));
        [qL,~]=qr(a2(inz,:));
        qL=qL(:,rho+1:end);
        ix=inz(rho+1:end);
        b(ix,:)=qL'*b(inz,:);a(ix,:)=qL'*a(inz,:);e(ix,:)=qL'*e(inz,:);

        ikeep=1:ns;ikeep(inz(1:min(rho,end)))=[];ikeep=ikeep(1:ns-rho);
        jkeep=1:ns;jkeep(jx(nu+1:nu+rho))=[];
        a=a(ikeep,jkeep);e=e(ikeep,jkeep);b=b(ikeep,:);c=c(:,jkeep);
        ns=ns-rho;
    end
