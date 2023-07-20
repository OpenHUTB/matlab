function[D1,SingularFlag]=feedbackG(D1,D2,indu1,indy1,indu2,indy2,sign1,sign2)




















    SingularFlag=false;

    if isfinite(D1)&&isfinite(D2)

        D1=localFoldLoopDelays(D1,indu1,indy1);
        D2=localFoldLoopDelays(D2,indu2,indy2);


        nq1=size(D1.k,1);
        nq2=size(D2.k,1);
        [rs1,cs1]=size(D1.d);
        [rs2,cs2]=size(D2.d);
        nfd1=length(D1.Delay.Internal);
        nfd2=length(D2.Delay.Internal);
        ny2u1=numel(indy2);ny1u2=numel(indy1);
        nq=nq1+nq2;






        if nq1>0||nq2>0


            [ke,me]=localMinCutAnalysis(D1,D2,indu1,indy1,indu2,indy2);
        else

            ke=1:numel(indu1);
            me=1:numel(indy1);
        end



        m=ltipack.util.blkdiagE(D1.m,D2.m,nq1,nq2);
        c=ltipack.util.blkdiag(D1.c,D2.c);
        k=ltipack.util.blkdiag(D1.k,D2.k);
        b=ltipack.util.blkdiag(D1.b,D2.b);
        f=ltipack.util.blkdiag(D1.f,D2.f);
        g=ltipack.util.blkdiag(D1.g,D2.g);
        d=ltipack.util.blkdiag(D1.d,D2.d);







        ix=[indy1(:);rs1+indy2(:)];
        jx=[cs1+indu2(:);indu1(:)];
        bF=b(:,jx);fF=f(ix,:);gF=g(ix,:);
        xF=d(:,jx);yF=d(ix,:);
        M=[(-sign2)*speye(ny1u2),d(indy1,indu1);...
        d(rs1+indy2,cs1+indu2),(-sign1)*speye(ny2u1)];



        ne=numel(ke)+numel(me);
        if ne>0
            idel=[me,ny1u2+ke];
            ikeep=1:ny1u2+ny2u1;ikeep(:,idel)=[];nkeep=numel(ikeep);
            aux=matlab.internal.math.nowarn.mldivide(...
            M(idel,idel),[fF(idel,:),gF(idel,:),M(idel,ikeep),yF(idel,:)]);

            bF2=bF(:,idel);fF2=aux(:,1:nq);gF2=aux(:,nq+1:2*nq);
            xF2=xF(:,idel);yF2=aux(:,2*nq+nkeep+1:end);
            M12=M(ikeep,idel);M21=aux(:,2*nq+1:2*nq+nkeep);
            d=d-xF2*yF2;
            if~all(isfinite(d),'all')

                D1=createGain(D1,NaN(iosize(D1)+iosize(D2)));
                return
            end
            bF=bF(:,ikeep)-bF2*M21;
            fF=fF(ikeep,:)-M12*fF2;
            gF=gF(ikeep,:)-M12*gF2;
            M=M(ikeep,ikeep)-M12*M21;
            b=b-bF2*yF2;
            f=f-xF2*fF2;
            g=g-xF2*gF2;
            xF=xF(:,ikeep)-xF2*M21;
            yF=yF(ikeep,:)-M12*yF2;
        end


        nALG=size(M,1);
        D1.k=[k,-bF;fF,M];
        D1.c=[[c;gF],sparse(nq+nALG,nALG)];
        D1.b=[b;-yF];
        D1.f=[f,xF];
        D1.g=[g,sparse(rs1+rs2,nALG)];
        D1.d=d;
        if nALG>0
            if isequal(m,[])
                D1.m=sparse(1:nq,1:nq,1,nq+nALG,nq+nALG);
            else
                D1.m=ltipack.util.blkdiag(m,sparse(nALG,nALG));
            end
            D1.StateInfo=[D1.StateInfo;D2.StateInfo;struct('Type',3,'Name',"",'Size',nALG)];
        else
            D1.m=m;
            D1.StateInfo=[D1.StateInfo;D2.StateInfo];
        end
        D1.Scaled=false;


        D1.Delay.Input=[D1.Delay.Input;D2.Delay.Input];
        D1.Delay.Output=[D1.Delay.Output;D2.Delay.Output];
        D1.Delay.Internal=[D1.Delay.Internal;D2.Delay.Internal];
        if nfd1>0


            nu1=cs1-nfd1;ny1=rs1-nfd1;
            nu2=cs2-nfd2;ny2=rs2-nfd2;
            uperm=[1:nu1,cs1+1:cs1+nu2,nu1+1:cs1,cs1+nu2+1:cs1+cs2];
            yperm=[1:ny1,rs1+1:rs1+ny2,ny1+1:rs1,rs1+ny2+1:rs1+rs2];
            D1.b=D1.b(:,uperm);
            D1.f=D1.f(yperm,:);
            D1.g=D1.g(yperm,:);
            D1.d=D1.d(yperm,uperm);
        end


        D1.SolverConfig=ltioptions.sparss.reconcile(D1.SolverConfig,D2.SolverConfig);
    else

        [ny1,nu1]=size(D1.d);
        [ny2,nu2]=size(D2.d);
        D1=createGain(D1,NaN(ny1+ny2,nu1+nu2));
    end



    function[ke,me]=localMinCutAnalysis(D1,D2,indu1,indy1,indu2,indy2)















        b1=any(D1.b(:,indu1),1);
        fg1=any(D1.f(indy1,:),2)|any(D1.g(indy1,:),2);
        d1=spones(D1.d(indy1,indu1));
        b2=any(D2.b(:,indu2),1);
        fg2=any(D2.f(indy2,:),2)|any(D2.g(indy2,:),2);
        d2=spones(D2.d(indy2,indu2));
        if any(b1)||any(b2)





            nk=numel(indu1);nm=numel(indy1);
            [i1,j1]=find([sparse(0),b1;fg1,d1]);
            [i2,j2]=find([sparse(0),b2;fg2,d2]);
            nv=2*(nk+nm+2);
            i=[(2:nk+1)';i1+(nk+1);(nk+nm+4:nk+2*nm+3)';i2+(nv-nk-1)];
            j=[(nv-nk+1:nv)';j1;(nk+3:nk+nm+2)';j2+(nk+nm+2)];
            w=[ones(nk,1);Inf(size(i1));ones(nm,1);Inf(size(i2))];

            i=[i;1;nk+nm+3;nv+2;nv+2];
            j=[j;nv+1;nv+1;nk+2;nv-nk];
            w=[w;Inf(4,1)];


            [~,~,cs,ct]=maxflow(digraph(j,i,w),nv+1,nv+2);

            icut=i(ismember(j,cs)&ismember(i,ct));
            ki=icut(icut<=nk+1,:)-1;
            mi=icut(icut>nk+1,:)-(nk+nm+3);
            ke=1:nk;ke(:,ki)=[];
            me=1:nm;me(:,mi)=[];
        else


            ke=1:numel(indu1);me=1:numel(indy1);
        end


        function D=localFoldLoopDelays(D,indu,indy)

            Delay=D.Delay;
            Din=zeros(size(Delay.Input));
            Din(indu)=Delay.Input(indu);
            Dout=zeros(size(Delay.Output));
            Dout(indy)=Delay.Output(indy);
            if any(Din)||any(Dout)
                D=utFoldDelay(D,Din,Dout);
            end