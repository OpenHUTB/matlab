function WorstLB=coreLowerBound(A,B,C,D,Ts,wData,...
    blkData,userMuOpt,useMethod,appMuScale,Focus)




    if nargin<11
        Focus=[0,inf];
    end

    if strcmp(useMethod,'ptwise')||strcmp(useMethod,'complexify')
        if all(size(wData)==[1,2])
            wP=rctutil.intervalmean(wData);
        else
            wP=wData(1);
        end
    elseif strcmp(useMethod,'state-space')
        if isscalar(wData)||wData(1)==wData(2)
            useMethod='ptwise';
            wP=wData(1);
        else
            wP=rctutil.intervalmean(wData);
        end
    end
    blk=blkData.simpleblk;
    RNG=RandStream('twister','seed',0);

    [ny,nu]=size(D);
    switch useMethod
    case 'complexify'
        Gg=rctutil.freqresp(A,B,C,D,Ts,wP);
        [cGg,cblk,cFixedBlkIdx]=LOCALmakecblk(Gg,blkData);
        [~,nuC]=size(cGg);
        cblkData=rctutil.mkBlkData(cblk,cFixedBlkIdx);
        mValue=LOCALgoptvl(userMuOpt,'m',0,0);
        [lbA(1),wDeltaCA(:,:,1)]=mmupiter(cGg,cblkData);
        for i=mValue:-1:1
            bVec=complex(RNG.randn(nuC,1),RNG.randn(nuC,1));bVec=bVec/norm(bVec);
            wVec=complex(RNG.randn(nuC,1),RNG.randn(nuC,1));wVec=wVec/norm(wVec);
            [lbA(1+i),wDeltaCA(:,:,1+i)]=mmupiter(cGg,cblkData,bVec,wVec);
        end
        [~,idx]=max(lbA);
        tmpDelta=wDeltaCA(1:nu,1:ny,idx);
        nDelta=norm(tmpDelta);
        if nDelta==0
            lb=0;
        else
            lb=1/nDelta;
        end
    case 'ptwise'

        Gg=rctutil.freqresp(A,B,C,D,Ts,wP);
        if any(blk(:,1)>0)
            mValue=LOCALgoptvl(userMuOpt,'m',0,0);
            [lbA(1),tmpDeltaA(:,:,1)]=mmupiter(Gg,blkData);
            for i=mValue:-1:1
                bVec=complex(RNG.randn(nu,1),RNG.randn(nu,1));bVec=bVec/norm(bVec);
                wVec=complex(RNG.randn(nu,1),RNG.randn(nu,1));wVec=wVec/norm(wVec);
                [lbA(1+i),tmpDeltaA(:,:,1+i)]=mmupiter(Gg,blkData,bVec,wVec);
            end
            [lb,idx]=max(lbA);
            tmpDelta=tmpDeltaA(:,:,idx);
        elseif isequal(blk,[-1,0;-1,0])

            [lb,tmpDelta]=rctutil.special2by2MU(Gg);
        else


            [lb,tmpDelta]=fixRealMu(Gg,blk);
            gValue=LOCALgoptvl(userMuOpt,'g',1,1);
            thismuOpt=['fg',int2str(gValue)];
            [bnds,mui]=mussv(Gg,blk,thismuOpt);
            if bnds(2)>lb
                lb=bnds(2);
                tmpDelta=mussvunwrap(mui);
            end
        end
    case 'state-space'
        nx=size(A,1);


        if isinf(wData(2))&&wData(1)>0
            fac=1/2/wData(1);
            N=[0,sqrt(fac);sqrt(fac),fac];
        elseif isinf(wData(2))&&wData(1)==0
            wLeft=[0,1];
            LBound1=coreLowerBound(A,B,C,D,Ts,wLeft,blkData,userMuOpt,...
            useMethod,appMuScale,Focus);
            wRight=[1,inf];
            LBound2=coreLowerBound(A,B,C,D,Ts,wRight,blkData,userMuOpt,...
            useMethod,appMuScale,Focus);
            if LBound2.LB>LBound1.LB
                WorstLB=LBound2;
            else
                WorstLB=LBound1;
            end
            return
        else

            wbar=(wData(1)+wData(2))/2;
            alpha=wData(2)-wbar;

            N=[-alpha,sqrt(alpha);1j*sqrt(alpha),1/1j]/wbar;
        end
        Nnx=kron(N,eye(nx));


        Mnorm=lft(Nnx,[A,B;C,D],nx,nx);
        fblk=[-nx,0;blk];
        if any(blk(:,1)>0)
            fblk(1,:)=abs(fblk(1,:));
            newFixedBlockIdx=[1,1+blkData.FVidx.fixedBlkIdx];
            newBlkData=rctutil.mkBlkData(fblk,newFixedBlockIdx);
            [cMnorm,cblk,cFixedBlkIdx]=LOCALmakecblk(Mnorm,newBlkData);
            cblk(1,1)=-cblk(1,1);
            cblkData=rctutil.mkBlkData(cblk,cFixedBlkIdx);
            [~,wDeltaC]=mmupiter(cMnorm,cblkData);
            wDelta=wDeltaC(1:(nx+nu),1:(nx+ny));
            tmpDelta=wDelta(nx+1:end,nx+1:end);
            nDelta=norm(tmpDelta);
            if nDelta==0
                lb=0;
            else
                lb=1/nDelta;
            end
        else

            userMuOpt(userMuOpt=='a')='';
            if~any(userMuOpt=='g')
                userMuOpt=['g4',userMuOpt];
            end
            ssMUopt=[userMuOpt,'f'];

            Mscl=Mnorm;
            Mscl(nx+1:end,:)=Mnorm(nx+1:end,:)/sqrt(appMuScale);
            Mscl(:,nx+1:end)=Mscl(:,nx+1:end)/sqrt(appMuScale);
            [bnds,muInfo]=mussv(Mscl,fblk,ssMUopt);
            wDelta=mussvunwrap(muInfo);
            tmpDelta=wDelta(nx+1:end,nx+1:end)/appMuScale;
            lb=bnds(2)*appMuScale;
        end

        wP=imag(1/lft(wDelta(1),N));

    end

    if lb==0
        WorstLB=struct('w',wP,'LB',0,'Delta',rctutil.dummyDelta(blk));
    else
        WorstLB=struct('w',wP,'LB',lb,'Delta',tmpDelta);
        if~strcmp(useMethod,'ptwise')



            WorstLB=rctutil.causeLowDamping(A,B,C,D,WorstLB,blkData);
        end
        if~isempty(blkData.FVidx.fixedBlkIdx)

            WorstLB=localCheckFixedStability(A,B,C,D,WorstLB,blkData);
        end
    end
    wFreq=abs(WorstLB.w);
    if wFreq<Focus(1)||wFreq>Focus(2)
        wFreq=sign(WorstLB.w)*min(Focus(2),max(wFreq,Focus(1)));
        WorstLB=struct('w',wFreq,'LB',0,'Delta',rctutil.dummyDelta(blk));
    end


    function[cGg,cblk,cFixedBlkIdx]=LOCALmakecblk(Gg,blkData)

        [ny,nu]=size(Gg);
        alphaC=0.01;
        blk=blkData.simpleblk;
        fixedBlkIdx=blkData.FVidx.fixedBlkIdx;
        nblk=size(blk,1);

        allreal=blkData.allreal;
        realr=allreal.allrows;
        realc=allreal.allcols;
        realblk=allreal.realblk;
        [~,ir]=intersect(allreal.origloc,fixedBlkIdx);
        realFixedBlkIdx=nblk+ir;
        cblk=[blk;abs(realblk)];
        cFixedBlkIdx=[fixedBlkIdx(:);realFixedBlkIdx];


        Iny=eye(ny);
        Lmat=[Iny;sqrt(alphaC)*Iny(realr,:)];
        Inu=eye(nu);
        Rmat=[Inu,sqrt(alphaC)*Inu(:,realc)];
        cGg=Lmat*Gg*Rmat;


        function val=LOCALgoptvl(opt,tag,defval,nfval)



            val=nfval;
            if any(opt==tag(1))
                loc=find(opt==tag(1));
                if length(opt)>loc

                    tmp=[(opt(loc+1:end)>=48)&(opt(loc+1:end)<=57),0];
                    idx=find(tmp==0,1)-1;
                    val=str2double(opt(loc+1:loc+idx));
                    if isnan(val)
                        val=defval;
                    end
                else
                    val=defval;
                end
            end


            function[lb,Delta]=fixRealMu(Gg,blk)
                SolTOL=1e-12;
                szG=size(Gg,1);
                nblk=size(blk,1);

                alpha=sqrt(0.001);
                cblk=[blk;abs(blk)];
                cblkData=rctutil.mkBlkData(cblk);
                L=[eye(szG);alpha*eye(szG)];
                [~,DeltaC]=mmupiter(L*Gg*L',cblkData);
                DeltaTMP=DeltaC(1:szG,1:szG);

                rPM=[];
                for i=1:nblk
                    rPM=[rPM,repmat(i,[1,-blk(i,1)])];
                end
                PM=diag(rPM);
                lb=0;
                CNTMAX=3*nblk;

                for i=1:CNTMAX
                    [partial,evl]=LOCALpartialEigDelta(Gg,DeltaTMP,PM);
                    appPert=pinv([real(partial);imag(partial)])*([1;0]-[real(evl);imag(evl)]);
                    Delta=DeltaTMP+diag(appPert(rPM));
                    if min(abs(1-eig(Gg*Delta)))<SolTOL
                        lb=1/norm(Delta);
                        break
                    else
                        DeltaTMP=Delta;
                    end
                end
                if lb==0
                    Delta=[];
                end

                function[partial,evl]=LOCALpartialEigDelta(M,Delta,PatternMask)
                    nx=max(PatternMask(:));
                    MD=M*Delta;
                    [rev,evl,lev]=eig(MD);
                    [~,eidx]=min(abs(1-diag(evl)));
                    sVec=lev(:,eidx);
                    vVec=rev(:,eidx);
                    svIP=sVec'*vVec;
                    partial=zeros(1,nx);
                    for i=1:nx
                        MDdot=M*(PatternMask==i);
                        partial(i)=(sVec'*MDdot*vVec)/svIP;
                    end
                    evl=evl(eidx,eidx);


                    function LBcert=localCheckFixedStability(A,B,C,D,LBcert,blkData)




                        ny=size(D,1);
                        VaryRows=blkData.FVidx.VaryRows;
                        VaryCols=blkData.FVidx.VaryCols;
                        DeltaF=LBcert.Delta;
                        DeltaF(VaryCols,VaryRows)=0;
                        clp=eig(A+B*DeltaF*((eye(ny)-D*DeltaF)\C));
                        if any(real(clp)>=0)




                            tStable=0;tUnstable=1;clpUnstable=clp;
                            while tUnstable-tStable>1e-8
                                t=(tStable+tUnstable)/2;
                                clp=eig(A+B*t*DeltaF*((eye(ny)-D*t*DeltaF)\C));
                                if all(real(clp)<0)
                                    tStable=t;
                                else
                                    tUnstable=t;clpUnstable=clp;
                                end
                            end
                            [~,imin]=min(abs(real(clpUnstable)));
                            LBcert.LB=Inf;
                            LBcert.w=abs(imag(clpUnstable(imin)));
                            LBcert.Delta=tUnstable*DeltaF;
                        end

