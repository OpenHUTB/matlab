function[PSI,dr,dc,FitOrder,PLOTS]=fitDG(clpg,blk,DGInfo,opt,PLOTS)
















    MaxOrd=opt.FitOrder;
    FULLDISP=strcmp(opt.Display,'full');
    FULLDG=opt.FullDG;

    nblk=size(blk,1);
    bdim=abs(blk);
    rp=find(blk(:,2)==0);
    bdim(rp,2)=bdim(rp,1);
    blkptr=cumsum([1,1;bdim]);
    [Mw,w,Ts]=frdata(clpg);
    [Mr,Mc,Nw]=size(Mw);
    FitOrder=[0,0];
    widx=DGInfo.FitRange;


    Drw=DGInfo.Dr;
    Dcw=DGInfo.Dc;
    if any(blk(:,1)<0)
        Gw=DGInfo.Gcr;
        gainSCL=zeros(Nw,1);
        for ct=1:Nw
            gainSCL(ct)=rctutil.getssv(Mw(:,:,ct),Drw(:,:,ct),Dcw(:,:,ct),[]);
        end
    else
        Gw=[];
    end
    uppermu=DGInfo.ub;
    muPeak=max(uppermu);
    mu2=muPeak^2;


    drw=zeros(Mr,1,Nw);
    dcw=zeros(Mc,1,Nw);
    for i=1:nblk

        ridx=blkptr(i,2):blkptr(i+1,2)-1;
        cidx=blkptr(i,1):blkptr(i+1,1)-1;
        for ct=1:Nw
            dr=sqrt(diag(Drw(ridx,ridx,ct)));
            dc=sqrt(diag(Dcw(cidx,cidx,ct)));
            drw(ridx,:,ct)=dr;dcw(cidx,:,ct)=dc;
            Drw(ridx,ridx,ct)=Drw(ridx,ridx,ct)./(dr*dr');
            Dcw(cidx,cidx,ct)=Dcw(cidx,cidx,ct)./(dc*dc');
            if blk(i,1)<0
                Gw(cidx,ridx,ct)=Gw(cidx,ridx,ct)./(dc*dr');
            end
        end
    end



    muWeight=sqrt(uppermu/muPeak);
    MaxGain=(1.001*muPeak^0.1)*uppermu.^0.9;


    A=[];B=[];C=[];D=zeros(Mr+Mc);
    Adr=[];Bdr=[];Cdr=[];Ddr=[];
    Adc=[];Bdc=[];Cdc=[];Ddc=[];
    for i=1:nblk

        ridx=blkptr(i,2):blkptr(i+1,2)-1;
        cidx=blkptr(i,1):blkptr(i+1,1)-1;
        RepeatedScalar=(blk(i,2)==0&&bdim(i,1)>1);
        GScaling=(blk(i,1)<0);
        dimR=bdim(i,2);dimC=bdim(i,1);
        IR=eye(dimR);IC=eye(dimC);
        if FULLDISP
            fprintf('Fitting scalings for block %d\n',i)
        end



        if i==nblk

            [Adr,Bdr,Cdr,Ddr]=ltipack.ssops('append',Adr,Bdr,Cdr,Ddr,[],...
            [],zeros(0,dimR),zeros(dimR,0),IR,[]);
            [Adc,Bdc,Cdc,Ddc]=ltipack.ssops('append',Adc,Bdc,Cdc,Ddc,[],...
            [],zeros(0,dimC),zeros(dimC,0),IC,[]);
            if FULLDISP
                fprintf('   D: order=0, score=0\n')
            end
        elseif RepeatedScalar











            di=drw(ridx,1,:);
            Di=Drw(ridx,ridx,:);
            if GScaling
                Gi=Gw(cidx,ridx,:);
            end
            for j=1:dimR
                mag=di(j,:);
                wt=muWeight./mag(:);
                [fit,score,ph]=localFitD(mag,MaxOrd(1),wt,true,...
                Ts,w,Mw,drw,dcw,Drw,Dcw,Gw,ridx(j),cidx(j),widx,MaxGain);
                [a,b,c,d]=ssdata(fit);
                [Adr,Bdr,Cdr,Ddr]=ltipack.ssops('append',Adr,Bdr,Cdr,Ddr,[],a,b,c,d,[]);
                [Adc,Bdc,Cdc,Ddc]=ltipack.ssops('append',Adc,Bdc,Cdc,Ddc,[],a,b,c,d,[]);
                if FULLDISP
                    fprintf('   D(%d,%d): order=%d, score=%.3g\n',j,j,size(a,1),score)
                end

                ix=[1:j-1,j+1:dimR];
                di(j,1,:)=di(j,1,:).*ph;
                Di(ix,j,:)=Di(ix,j,:).*conj(ph);
                Di(j,ix,:)=Di(j,ix,:).*ph;
                if GScaling
                    Gi(ix,j,:)=Gi(ix,j,:).*conj(ph);
                    Gi(j,ix,:)=Gi(j,ix,:).*ph;
                end
            end

            drw(ridx,1,:)=di;dcw(cidx,1,:)=di;
            Drw(ridx,ridx,:)=Di;Dcw(cidx,cidx,:)=Di;
            if GScaling
                Gw(cidx,ridx,:)=Gi;
            end
        else

            mag=drw(ridx(1),:);
            wt=muWeight./mag(:);
            [fit,score]=localFitD(mag,MaxOrd(1),wt,true,...
            Ts,w,Mw,drw,dcw,Drw,Dcw,Gw,ridx,cidx,widx,MaxGain);
            [a,b,c,d]=ssdata(fit);
            [Adr,Bdr,Cdr,Ddr]=ltipack.ssops('append',Adr,Bdr,Cdr,Ddr,[],...
            kron(IR,a),kron(IR,b),kron(IR,c),kron(IR,d),[]);
            [Adc,Bdc,Cdc,Ddc]=ltipack.ssops('append',Adc,Bdc,Cdc,Ddc,[],...
            kron(IC,a),kron(IC,b),kron(IC,c),kron(IC,d),[]);
            if FULLDISP
                fprintf('   D: order=%d, score=%.3g\n',size(a,1),score)
            end
        end




        if(RepeatedScalar&&FULLDG(1))||GScaling
            m=dimR+dimC;
            AQ=[];BQ=zeros(0,m);CQ=zeros(m,0);DQ=blkdiag(IR,-mu2*IC);


            if RepeatedScalar&&FULLDG(1)
                wt=muWeight;
                for j=2:dimR
                    for k=1:j-1
                        [fit,score]=localFitD(Drw(ridx(k),ridx(j),:),MaxOrd(1),wt,false,...
                        Ts,w,Mw,drw,dcw,Drw,Dcw,Gw,ridx([k,j]),cidx([k,j]),widx,MaxGain);
                        [a,b,c,d]=localAntiDiag(fit,fit');
                        FitOrder(1)=FitOrder(1)+size(a,1);
                        [AQ,BQ,CQ,DQ]=localInsert(AQ,BQ,CQ,DQ,a,b,c,d,[k,j],[k,j]);
                        [AQ,BQ,CQ,DQ]=localInsert(AQ,BQ,CQ,DQ,...
                        a,muPeak*b,-muPeak*c,-mu2*d,dimR+[k,j],dimR+[k,j]);
                        if FULLDISP
                            fprintf('   D(%d,%d): order=%d, score=%.3g\n',k,j,order(fit),score)
                        end
                    end
                end
            end


            if GScaling
                wt=gainSCL;

                Ag=[];Bg=[];Cg=[];Dg=[];
                for j=1:dimR
                    [fit,score]=localFitG(1i*Gw(cidx(j),ridx(j),:),MaxOrd(2),wt,true,...
                    Ts,w,Mw,drw,dcw,Drw,Dcw,Gw,ridx(j),cidx(j),widx,MaxGain);
                    [a,b,c,d]=ssdata(fit);
                    [Ag,Bg,Cg,Dg]=ltipack.ssops('append',Ag,Bg,Cg,Dg,[],a,b,c,d,[]);
                    if FULLDISP
                        if dimR==1
                            fprintf('  jG: order=%d, score=%.3g\n',size(a,1),score)
                        else
                            fprintf('  jG(%d,%d): order=%d, score=%.3g\n',j,j,size(a,1),score)
                        end
                    end
                end
                [AQ,BQ,CQ,DQ]=localInsert(AQ,BQ,CQ,DQ,Ag,Bg,Cg,Dg,dimR+1:dimR+dimC,1:dimR);

                [AQ,BQ,CQ,DQ]=localInsert(AQ,BQ,CQ,DQ,Ag,Bg,-Cg,-Dg,1:dimR,dimR+1:dimR+dimC);
                FitOrder(2)=FitOrder(2)+size(Ag,1);

                if FULLDG(2)
                    for j=2:dimR
                        for k=1:j-1
                            [fit,score]=localFitG(1i*Gw(cidx(k),ridx(j),:),MaxOrd(2),wt,false,...
                            Ts,w,Mw,drw,dcw,Drw,Dcw,Gw,ridx([j,k]),cidx([k,j]),widx,MaxGain);
                            [a,b,c,d]=localAntiDiag(fit,-fit');


                            [AQ,BQ,CQ,DQ]=localInsert(AQ,BQ,CQ,DQ,a,b,c,d,dimR+[k,j],[k,j]);

                            [AQ,BQ,CQ,DQ]=localInsert(AQ,BQ,CQ,DQ,a,b,-c,-d,[k,j],dimR+[k,j]);
                            FitOrder(2)=FitOrder(2)+size(a,1);
                            if FULLDISP
                                fprintf('  jG(%d,%d): order=%d, score=%.3g\n',k,j,order(fit),score)
                            end
                        end
                    end
                end
            end


            [AF,BF,CF,DF]=localSpecFact(AQ,BQ,CQ,DQ,Ts,GScaling);
            [A,B,C,D]=localInsert(A,B,C,D,AF,BF,CF,DF,[ridx,Mr+cidx],[ridx,Mr+cidx]);
        else

            D(ridx,ridx)=IR;
            D(Mr+cidx,Mr+cidx)=muPeak*IC;
        end
    end


    dr=ss(Adr,Bdr,Cdr,Ddr,Ts);
    dc=ss(Adc,Bdc,Cdc,Ddc,Ts);
    PSI=ss(A,B,C,D,Ts);
    FitOrder(1)=FitOrder(1)+size(Adr,1)+size(Adc,1);
















    if FULLDISP

        h=PLOTS.DG;
        if isempty(h)||~isValid(h)
            PLOTS.DG=rctutil.DGView(blk,dr,PSI,drw,Drw,Gw,w,widx,PLOTS.BlockNames,FULLDG);
        else
            h.updateData(blk,PLOTS.BlockNames,dr,PSI,drw,Drw,Gw,w,widx)
            h.updateView()
        end
    end


    function[bestFit,bestScore,ph]=localFitD(data,MaxOrd,wt,diagFlag,...
        Ts,w,Mw,drw,dcw,Drw,Dcw,Gw,ridx,cidx,widx,MaxGain)


        Nw=numel(w);
        if isempty(Gw)
            Gw=zeros(0,0,Nw);
        end


        imin=widx(1);imax=widx(2);
        wfit=w(imin:imax);
        data=data(imin:imax);
        wt=wt(imin:imax);


        if diagFlag

            data=genphase(data,wfit,Ts);
            ord=ceil(MaxOrd/2);
        else
            ord=ceil(MaxOrd/3);
        end


        gain=zeros(Nw,1);
        bestScore=inf;
        bestFit=[];
        while ord>=0&&ord<=MaxOrd

            fit=fitRationalD(data,wfit,Ts,ord,wt,diagFlag);


            if~isproper(fit)
                scoreFromFit=1e3;
            elseif diagFlag


                fitw=abs(freqresp(fit,w));
                for ct=1:Nw
                    dr=drw(:,:,ct);dc=dcw(:,:,ct);
                    dr(ridx)=fitw(ct);dc(cidx)=fitw(ct);
                    MS=dr.*Mw(:,:,ct)./dc.';
                    gain(ct)=rctutil.getssv(MS,Drw(:,:,ct),Dcw(:,:,ct),Gw(:,:,ct));
                end

                scoreFromFit=max(gain./MaxGain);
            else


                fitw=freqresp(fit,[0;w;pi/Ts]);
                Dr=Drw(:,:,1);
                Dr(ridx(1),ridx(2))=fitw(1);Dr(ridx(2),ridx(1))=conj(fitw(1));
                [~,p0]=chol(Dr);
                Dr=Drw(:,:,Nw);
                Dr(ridx(1),ridx(2))=fitw(Nw+2);Dr(ridx(2),ridx(1))=conj(fitw(Nw+2));
                [~,pInf]=chol(Dr);
                if p0>0||pInf>0
                    scoreFromFit=1e3;
                else
                    for ct=1:Nw
                        MS=drw(:,:,ct).*Mw(:,:,ct)./dcw(:,:,ct).';
                        Dr=Drw(:,:,ct);Dc=Dcw(:,:,ct);
                        aux=fitw(ct+1);
                        Dr(ridx(1),ridx(2))=aux;Dc(cidx(1),cidx(2))=aux;
                        Dr(ridx(2),ridx(1))=conj(aux);Dc(cidx(2),cidx(1))=conj(aux);
                        gain(ct)=rctutil.getssv(MS,Dr,Dc,Gw(:,:,ct));
                    end

                    scoreFromFit=max(gain./MaxGain);
                end
            end



            STOP=isfinite(bestScore)&&xor(scoreFromFit>1,bestScore>1);
            if scoreFromFit<max(1,0.999*bestScore)
                bestScore=scoreFromFit;
                bestFit=fit;

            end
            if STOP
                break
            elseif scoreFromFit>1
                ord=ord+1;
            else
                ord=ord-1;
            end
        end
        if nargout>2

            h=freqresp(bestFit,w);
            ph=h./abs(h);
        end








        function[bestFit,bestScore]=localFitG(data,MaxOrd,wt,diagFlag,...
            Ts,w,Mw,drw,dcw,Drw,Dcw,Gw,ridx,cidx,widx,MaxGain)




            imin=widx(1);imax=widx(2);
            wfit=w(imin:imax);
            data=data(imin:imax);
            wt=wt(imin:imax);


            Nw=numel(w);
            gain=zeros(Nw,1);
            bestScore=inf;
            bestFit=[];
            if diagFlag
                MaxOrd=floor(MaxOrd/2);
            end
            ord=ceil(MaxOrd/2);
            while ord>=0&&ord<=MaxOrd
                try
                    jgfit=fitRationalG(data,wfit,Ts,ord,wt,diagFlag);
                catch

                    jgfit=zpk(0,'Ts',Ts);
                end


                gfitw=freqresp(jgfit,w)/1i;
                for ct=1:Nw
                    MS=drw(:,:,ct).*Mw(:,:,ct)./dcw(:,:,ct).';
                    G=Gw(:,:,ct);
                    if diagFlag
                        G(cidx,ridx)=gfitw(ct);
                    else
                        G(cidx(1),ridx(1))=gfitw(ct);
                        G(cidx(2),ridx(2))=conj(gfitw(ct));
                    end
                    gain(ct)=rctutil.getssv(MS,Drw(:,:,ct),Dcw(:,:,ct),G);
                end

                scoreFromFit=min(max(gain./MaxGain),1e3);







                STOP=isfinite(bestScore)&&xor(scoreFromFit>1,bestScore>1);
                if scoreFromFit<max(1,0.999*bestScore)
                    bestScore=scoreFromFit;
                    bestFit=jgfit;
                end
                if STOP
                    break
                elseif scoreFromFit>1
                    ord=ord+1;
                else
                    ord=ord-1;
                end
            end


            function[A,B,C,D]=localInsert(A,B,C,D,a,b,c,d,i,j)

                [p,m]=size(D);
                n=size(a,1);
                D(i,j)=D(i,j)+d;
                A=blkdiag(A,a);
                aux=zeros(n,m);aux(:,j)=b;B=[B;aux];
                aux=zeros(p,n);aux(i,:)=c;C=[C,aux];

                function[A,B,C,D]=localAntiDiag(sys1,sys2)

                    [a1,b1,c1,d1]=ssdata(sys1);
                    [a2,b2,c2,d2]=ssdata(sys2);
                    A=ltipack.util.blkdiag(a1,a2);
                    B=ltipack.util.blkdiag(b1,b2,'anti');
                    C=ltipack.util.blkdiag(c1,c2);
                    D=ltipack.util.blkdiag(d1,d2,'anti');


                    function[AF,BF,CF,DF]=localSpecFact(AQ,BQ,CQ,DQ,Ts,GScaling)

                        try
                            [~,W1,W2,F]=ltipack.getSectorData(ss(AQ,BQ,CQ,DQ,Ts),[]);
                            [AF,BF,CF,DF]=ssdata([W1,W2]'*F);
                        catch
                            m=size(DQ,1);
                            d=diag(DQ);
                            Mr=sum(d>0);
                            AF=[];BF=zeros(0,m);CF=zeros(m,0);DF=diag(sqrt(abs(d)));
                            if GScaling

                                try %#ok<TRYNC>
                                    [A,B,C]=smreal(AQ,BQ(:,Mr+1:m),CQ(1:Mr,:),[]);
                                    jG=ss(A,B,C,DQ(1:Mr,Mr+1:m),Ts);
                                    [~,W1,W2,F]=ltipack.getSectorData([diag(d(1:Mr)),jG;jG',diag(d(Mr+1:m))],[]);
                                    [AF,BF,CF,DF]=ssdata([W1,W2]'*F);
                                end
                            end
                        end

