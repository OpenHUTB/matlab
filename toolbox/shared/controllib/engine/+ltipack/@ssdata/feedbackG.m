function[D1,SingularFlag]=feedbackG(D1,D2,indu1,indy1,indu2,indy2,sign1,sign2)





















    if isfinite(D1)&&isfinite(D2)

        D1=localFoldLoopDelays(D1,indu1,indy1);
        D2=localFoldLoopDelays(D2,indu2,indy2);


        nx1=size(D1.a,1);
        nx2=size(D2.a,1);
        [rs1,cs1]=size(D1.d);
        [rs2,cs2]=size(D2.d);
        nfd1=length(D1.Delay.Internal);
        nfd2=length(D2.Delay.Internal);




        e=ltipack.util.blkdiagE(D1.e,D2.e,nx1,nx2);
        a=ltipack.util.blkdiag(D1.a,D2.a);
        b=ltipack.util.blkdiag(D1.b,D2.b);
        c=ltipack.util.blkdiag(D1.c,D2.c);
        d=ltipack.util.blkdiag(D1.d,D2.d);
        ix=[indy1(:);rs1+indy2(:)];
        jx=[cs1+indu2(:);indu1(:)];
        bF=b(:,jx);cF=c(ix,:);xF=d(:,jx);yF=d(ix,:);
        M=[sign2*eye(numel(indy1)),-d(indy1,indu1);...
        -d(rs1+indy2,cs1+indu2),sign1*eye(numel(indy2))];










        [D1.a,D1.b,D1.c,D1.d,D1.e,nALG,SingularFlag]=...
        localElimFS(a,b,c,d,e,bF,cF,xF,yF,M);
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
            D1.c=D1.c(yperm,:);
            D1.d=D1.d(yperm,uperm);
        end


        if~(isempty(D1.StateName)&&isempty(D2.StateName))
            D1.StateName=[ltipack.fullstring(D1.StateName,nx1);...
            ltipack.fullstring(D2.StateName,nx2);strings(nALG,1)];
        end
        if~(isempty(D1.StatePath)&&isempty(D2.StatePath))
            D1.StatePath=[ltipack.fullstring(D1.StatePath,nx1);...
            ltipack.fullstring(D2.StatePath,nx2);strings(nALG,1)];
        end
        if~(isempty(D1.StateUnit)&&isempty(D2.StateUnit))
            D1.StateUnit=[ltipack.fullstring(D1.StateUnit,nx1);...
            ltipack.fullstring(D2.StateUnit,nx2);strings(nALG,1)];
        end
    else

        D1=createGain(D1,NaN(iosize(D1)+iosize(D2)));
        SingularFlag=false;
    end



    function[a,b,c,d,e,nALG,SingularFlag]=localElimFS(a,b,c,d,e,bF,cF,xF,yF,M)









        nx=size(a,1);
        nyu=size(M,1);

        if nx==0

            d=d+xF*matlab.internal.math.nowarn.mldivide(M,yF);
            if all(isfinite(d),'all')
                SingularFlag=false;
            else
                SingularFlag=true;
                d=NaN(size(d));
            end
            nALG=0;
        else


            MAXCOND=1/sqrt(eps);
            KEEP=false(nyu,1);
            [p,q,r]=dmperm(M);
            for ct=1:numel(r)-1
                if r(ct+1)>r(ct)+1
                    ix=r(ct):r(ct+1)-1;
                    if localNearSingular(M(p(ix),q(ix)),MAXCOND)
                        KEEP(ix)=true;
                    end
                end
            end
            ikeep=find(KEEP);
            ielim=find(~KEEP);
            nALG=numel(ikeep);
            SingularFlag=(nALG>0);


            if nALG>0
                e=ltipack.util.blkdiagE(e,zeros(nALG),nx,nALG);
            end
            ABCD=[a,bF,b;cF,-M,yF;c,xF,d];
            [nz,nw]=size(d);
            i1=1:nx+nyu+nz;
            i2=nx+p(ielim);i1(i2)=[];
            j1=1:nx+nyu+nw;
            j2=nx+q(ielim);j1(j2)=[];
            ABCD=ABCD(i1,j1)-ABCD(i1,j2)*...
            matlab.internal.math.nowarn.mldivide(ABCD(i2,j2),ABCD(i2,j1));
            nx=nx+nALG;
            a=ABCD(1:nx,1:nx);
            b=ABCD(1:nx,nx+1:nx+nw);
            c=ABCD(nx+1:nx+nz,1:nx);
            d=ABCD(nx+1:nx+nz,nx+1:nx+nw);
        end


        function boo=localNearSingular(M,MAXCOND)

            [~,M]=balance(M);
            iM=matlab.internal.math.nowarn.inv(M);
            if all(isfinite(iM),'all')


                n=size(M,1);
                A=abs(M);B=abs(iM);
                v=repmat(1/sqrt(n),[n,1]);
                for ct=1:5
                    w=A*(B*v);
                    lambda=norm(w);
                    v=w/lambda;
                end
                boo=(lambda>MAXCOND);

            else
                boo=true;
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