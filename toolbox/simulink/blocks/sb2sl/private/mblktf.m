function[a,b,c,d]=mblktf(num,den,ni)







    narginchk(2,3);
    if(nargin<3)
        ni=[];
    end
    if(isempty(ni))
        ni=1;
    end



    [m,nn]=size(num);
    if(min(m,nn)==1&&m>1)
        num=num.';
        nn=m;
    end
    [m,nd]=size(den);
    if(min(m,nd)>1)
        error(message('sb2sl_blks:mblkft:DenRowVec'));
    elseif(m>1)
        den=den.';
        nd=m;
    end



    inz=find(den~=0);
    den=den(inz(1):nd);
    nd=size(den,2);



    nc=ni*nd;
    mn=size(num,1);
    if(nn>nc)
        if(all(all(num(:,1:(nn-nc))))==0)
            num=num(:,(nn-nc+1):nn)./den(1);
        else
            error(message('sb2sl_blks:mblktf:LowerOrderDen'));
        end
    else



        num=[zeros(mn,nc-nn),num]./den(1);
    end



    if(nd==1)
        a=[];
        b=[];
        c=[];
        d=num;
    else
        den=den(2:nd)./den(1);



        k=1:ni:nc;
        aj=[-den;eye(nd-2,nd-1)];
        bj=eye(nd-1,1);
        for j=1:ni
            numj=num(:,k);
            k=k+1;
            dj=numj(:,1);
            cj=numj(:,2:nd)-numj(:,1)*den;
            if(j==1)
                a=aj;
                b=bj;
                c=cj;
                d=dj;
            else
                d=[d,dj];
                c=[c,cj];
                b=[b,zeros(size(a,1),size(bj,2));zeros(size(aj,1),size(b,2)),bj];
                a=[a,zeros(size(a,1),size(aj,2));zeros(size(aj,1),size(a,2)),aj];
            end
        end
        if(ni~=1)



            [atj,ctj,btj,~,k]=ctrbf(a',c',b');
            aj=atj';
            bj=btj';
            cj=ctj';
            sk=sum(k);
            [m,~]=size(a);
            if(sk~=m)
                k=(m-sk+1):m;
                a=aj(k,k);
                b=bj(k,:);
                c=cj(:,k);
            end
        end
    end
    return

    function[abar,bbar,cbar,t,k]=ctrbf(a,b,c,tol)







        [ra,~]=size(a);
        [~,cb]=size(b);



        ptjn1=eye(ra);
        ajn1=a;
        bjn1=b;
        rojn1=cb;
        deltajn1=0;
        sigmajn1=ra;
        k=zeros(1,ra);
        if(nargin==3)
            tol=ra*norm(a,1)*eps;
        end



        for jj=1:ra
            [uj,sj,~]=svd(bjn1);
            [rsj,~]=size(sj);
            p=rot90(eye(rsj),1);
            uj=uj*p;
            bb=uj'*bjn1;
            roj=rank(bb,tol);
            [rbb,~]=size(bb);
            sigmaj=rbb-roj;
            sigmajn1=sigmaj;
            k(jj)=roj;
            if(roj==0||sigmaj==0)
                break
            end
            abxy=uj'*ajn1*uj;
            aj=abxy(1:sigmaj,1:sigmaj);
            bj=abxy(1:sigmaj,sigmaj+1:sigmaj+roj);
            ajn1=aj;
            bjn1=bj;
            [ruj,cuj]=size(uj);
            ptj=ptjn1*[uj,zeros(ruj,deltajn1);...
            zeros(deltajn1,cuj),eye(deltajn1)];
            ptjn1=ptj;
            deltaj=deltajn1+roj;
            deltajn1=deltaj;
        end



        t=ptjn1';
        abar=t*a*t';
        bbar=t*b;
        cbar=c*t';
        return
