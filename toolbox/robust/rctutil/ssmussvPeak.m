function[bnds,UBcert,LBcert]=ssmussvPeak(ProblemType,a,b,c,d,Ts,blkData,varargin)

    if isreal(a)&&isreal(b)&&isreal(c)&&isreal(d)

        [bnds,UBcert,LBcert]=localComputePeak(ProblemType,a,b,c,d,Ts,blkData,varargin{:});
    else
        [bnds1,UBcert1,LBcert1]=localComputePeak(ProblemType,conj(a),conj(b),conj(c),conj(d),Ts,...
        blkData,varargin{:});
        for ct=1:numel(UBcert1)
            UBcert1(ct).w=-UBcert1(ct).w;
        end
        for ct=1:numel(LBcert1)
            LBcert1(ct).w=-LBcert1(ct).w;
            LBcert1(ct).Delta=conj(LBcert1(ct).Delta);
        end

        [bnds2,UBcert2,LBcert2]=localComputePeak(ProblemType,a,b,c,d,Ts,blkData,varargin{:});

        bnds=max(bnds1,bnds2);
        UBcert=cat(1,UBcert1,UBcert2);
        LBcert=cat(1,LBcert1,LBcert2);
        [~,iub]=max([UBcert.gUB]);
        [~,ilb]=max([LBcert.LB]);
        ikeep=unique([iub,ilb]);
        UBcert=UBcert(ikeep,:);LBcert=LBcert(ikeep,:);
    end


    function[bnds,UBcert,LBcert]=localComputePeak(ProblemType,a,b,c,d,Ts,...
        blkData,userMuOpt,Focus,UBmax)

        nin=nargin;

        if nin<8
            userMuOpt='';
        end
        if nin<9||isempty(Focus)
            Focus=[0,pi/Ts];
        end
        if nin<10
            gUBmax=0;
            foundInfUB=false;
        else
            gUBmax=UBmax.gUB;
            foundInfUB=isinf(UBmax.ptUB);
        end

        blk=blkData.simpleblk;
        DTFlag=Ts~=0;
        if DTFlag
            DTtime=Ts;
            [a,b,c,d]=ssdata(d2c(ss(a,b,c,d,Ts),'Tustin'));
            NearInf=(Focus*Ts>(1-100*eps)*pi);
            if NearInf(1)
                error(message('Robust:analysis:InvalidFocus'))
            end
            Focus=(2/Ts)*tan(min(Focus*Ts,pi)/2);
            if NearInf(2)

                Focus(2)=Inf;
            end
            Ts=0;
        end
        [a,b,c,d]=statescaleEngine(a,b,c,d,blk);
        dynRange=rctutil.getDynamicRange(eig(a));
        peakOnly=true;
        V=ssmussvTolerances(userMuOpt,gUBmax,dynRange,Focus,peakOnly);

        if isequal(blk,[-1,0])
            [UBcert,LBcert]=special1b1MU(a,b,c,d,Ts,[],V,Focus);
            [~,imax]=max([UBcert.gUB]);
            WorstUB=UBcert(imax);WorstUB_LB=LBcert(imax);
            [~,imax]=max([LBcert.LB]);
            WorstLB=LBcert(imax);WorstLB_UB=UBcert(imax);
        else
            ShowProgess=~any(userMuOpt=='s');

            if foundInfUB

                UBcert=UBmax;
            else
                UBcert=struct('Interval',Focus,'gUB',Inf,'VLmi',[],...
                'ptUB',NaN,'w',NaN,'Jump',false);

                for ct=1:2
                    w=Focus(ct);
                    Gg=rctutil.freqresp(a,b,c,d,Ts,w);
                    [ptUB,DG]=constantDGub(Gg,blkData,V);
                    UBnew=struct('Interval',[w,w],'gUB',(1+V.etol)*ptUB,...
                    'VLmi',DG,'ptUB',ptUB,'w',w,'Jump',true);
                    UBcert=rctutil.insertUB(UBcert,UBnew);
                    V.gUBmax=max(V.gUBmax,UBnew.gUB);

                    foundInfUB=isinf(ptUB);
                    if foundInfUB
                        break
                    end
                end

                if ShowProgess
                    [~,LmatForW,~]=hp2dblt(rctutil.intervalmean(dynRange));
                    Linf=LmatForW(2,2)-LmatForW(2,1)/LmatForW(1,1)*LmatForW(1,2);
                    L0=LmatForW(2,2);
                    percentDone=0;
                    fprintf('Computing peak...  Percent completed: 0/100');
                end

                Missing=Focus;
                NCARVE=0;NLMI=0;
                while~(isempty(Missing)||foundInfUB)

                    if ShowProgess
                        percentDone=localShowProgressUB(LmatForW,L0,Linf,Missing,percentDone);
                    end
                    idx=1+rem(NCARVE,2)*(size(Missing,1)-1);
                    [UBcertC,NLMIC]=LMICarve(a,b,c,d,Ts,blkData,Missing(idx,:),V,Focus);
                    foundInfUB=isinf(UBcertC.ptUB);
                    UBcert=rctutil.insertUB(UBcert,UBcertC);
                    V.gUBmax=max(V.gUBmax,UBcertC.gUB);
                    Missing=rctutil.findMissingIntervals(UBcert);
                    NCARVE=NCARVE+1;
                    NLMI=NLMI+NLMIC;
                end
            end
            gUB=cat(1,UBcert.gUB);
            gUBmax=max(gUB);
            Jump=cat(1,UBcert.Jump);
            maxIdx=find(gUB==gUBmax&Jump,1);
            if isempty(maxIdx)
                maxIdx=find(gUB==gUBmax,1);
            end
            WorstUB=UBcert(maxIdx);

            WorstLB=struct('LB',-1);
            WorstUB_LB=[];
            LbUbRatio=0.99;

            if WorstLB.LB<LbUbRatio*gUBmax&&foundInfUB
                fixedBlkIdx=blkData.FVidx.fixedBlkIdx;
                FixedRows=blkData.FVidx.FixedRows;
                FixedCols=blkData.FVidx.FixedCols;
                fixedBlk=blkData.simpleblk(fixedBlkIdx,:);
                fixedBlkData=ssmussvSetUp(fixedBlk,'',[]);

                bFixed=b(:,FixedCols);
                cFixed=c(FixedRows,:);
                dFixed=d(FixedRows,FixedCols);
                FixedLB=coreLowerBound(a,bFixed,cFixed,dFixed,Ts,WorstUB.w,...
                fixedBlkData,userMuOpt,'ptwise',[],Focus);

                if FixedLB.LB<1
                    FixedLB=coreLowerBound(a,bFixed,cFixed,dFixed,Ts,WorstUB.Interval,...
                    fixedBlkData,userMuOpt,'state-space',1,Focus);

                end

                if FixedLB.LB>=1
                    Delta=zeros(blkData.cdimm,blkData.rdimm);
                    Delta(FixedCols,FixedRows)=FixedLB.Delta;
                    WorstLB=struct('w',FixedLB.w,'LB',inf,'Delta',Delta);
                end
            end

            if WorstLB.LB<LbUbRatio*gUBmax
                nUB=numel(gUB);
                [~,is]=sort(gUB,'descend');

                is=unique([1;nUB;maxIdx;is],'stable');
                if ShowProgess
                    percentDone=localShowProgressLB(0,percentDone);
                end
                for ct=1:nUB
                    UB=UBcert(is(ct));
                    w=UB.w;
                    if isnan(w)
                        w=rctutil.intervalmean(UB.Interval);
                    end
                    if ShowProgess
                        percentDone=localShowProgressLB(ct/nUB,percentDone);
                    end
                    if WorstLB.LB<LbUbRatio*UB.gUB&&(WorstLB.LB==0||blkData.allcomp.num>0)
                        WorstLB=localMaxLB(WorstLB,...
                        coreLowerBound(a,b,c,d,Ts,w,blkData,userMuOpt,'ptwise',[],Focus));
                    end
                    if WorstLB.LB<LbUbRatio*UB.gUB&&...
                        ((WorstLB.LB==0&&blkData.allreal.num>0)||blkData.allcomp.num==0)

                        WorstLB=localMaxLB(WorstLB,...
                        coreLowerBound(a,b,c,d,Ts,w,blkData,userMuOpt,'complexify',[],Focus));
                    end
                    if WorstLB.LB>LbUbRatio*gUBmax
                        break
                    end
                end
            end
            if~isempty(a)&&gUBmax<Inf&&WorstLB.LB<LbUbRatio*gUBmax&&diff(WorstUB.Interval)>0
                w=WorstUB.w*[.99,1.01];
                WorstLB=localMaxLB(WorstLB,...
                coreLowerBound(a,b,c,d,Ts,w,blkData,userMuOpt,'state-space',gUBmax,Focus));
            end

            if ShowProgess
                localShowProgressLB(1,percentDone);
                fprintf('\n')
            end
        end

        if WorstLB.LB<Inf

            switch ProblemType
            case 'robgain'

                WorstLB=localAdjustDelta(a,b,c,d,Ts,blk(end,:),WorstLB,Focus);
            case 'wcgain'
                WorstLB=localAdjustBound(a,b,c,d,Ts,blk(end,:),WorstLB,Focus);
            end
        end

        wLB=WorstLB.w;
        wUB=WorstUB.w;
        if wLB==wUB||abs(wLB-wUB)<max(V.AbsIntervalTol,(V.RelIntervalTol-1)*(wLB+wUB)/2)
            UBcert=WorstUB;LBcert=WorstLB;UBcert.w=wLB;
        else

            if isempty(WorstUB_LB)
                WorstUB_LB=coreLowerBound(a,b,c,d,Ts,WorstUB.w,blkData,userMuOpt,'ptwise',[],Focus);

                V.gUBmax=0;
                [ptUB,DG]=constantDGub(rctutil.freqresp(a,b,c,d,Ts,wLB),blkData,V);
                WorstLB_UB=struct('Interval',[wLB,wLB],'gUB',ptUB,'VLmi',DG,'ptUB',ptUB,'w',wLB,'Jump',false);
            end
            UBcert=cat(1,WorstUB,WorstLB_UB);
            LBcert=cat(1,WorstUB_LB,WorstLB);
            [~,is]=sort([wUB;wLB]);
            UBcert=UBcert(is);LBcert=LBcert(is);
        end

        for ct=1:numel(LBcert)
            LBcert(ct)=rctutil.fixDelta0Inf(a,b,c,d,Ts,blkData,LBcert(ct),userMuOpt);
        end

        if DTFlag
            [UBcert,LBcert]=rctutil.fixFrequencyDC(UBcert,LBcert,DTtime);
        end
        bnds=[max([UBcert.gUB]),max([LBcert.LB])];




        function WorstLB=localAdjustDelta(a,b,c,d,Ts,PerfBlkSize,WorstLB,Focus)

            TOL=1e-3;
            [rs,cs]=size(d);
            nd=PerfBlkSize(1);
            ne=PerfBlkSize(2);
            nu=rs-ne;
            ny=cs-nd;
            DeltaVary=WorstLB.Delta(1:ny,1:nu);
            wCritical=WorstLB.w;
            tmp=lft(DeltaVary,[d,c;b,a]);
            sstmp=ltipack.ssdata(tmp(ne+1:end,nd+1:end),tmp(ne+1:end,1:nd),...
            tmp(1:ne,nd+1:end),tmp(1:ne,1:nd),[],Ts);
            gpeak=norminf(sstmp,1e-6,Focus,true);
            if gpeak>1+TOL

                FLB=0;FUB=1;gUB=gpeak;
                while FLB==0
                    F=0.95*FUB;
                    tmp=lft(F*DeltaVary,[d,c;b,a]);
                    sstmp=ltipack.ssdata(tmp(ne+1:end,nd+1:end),tmp(ne+1:end,1:nd),...
                    tmp(1:ne,nd+1:end),tmp(1:ne,1:nd),[],Ts);
                    [gpeak,fpeak]=norminf(sstmp,1e-6,Focus);
                    if gpeak>1+TOL
                        FUB=F;gUB=gpeak;
                    else
                        FLB=F;gLB=gpeak;wCritical=fpeak;break
                    end
                end

                Accel=true;
                while gLB<1-TOL&&FUB-FLB>1e-8
                    if Accel
                        F=FLB+(1-gLB)*(FUB-FLB)/(gUB-gLB);
                    else
                        F=(FLB+FUB)/2;
                    end
                    tmp=lft(F*DeltaVary,[d,c;b,a]);
                    sstmp=ltipack.ssdata(tmp(ne+1:end,nd+1:end),tmp(ne+1:end,1:nd),...
                    tmp(1:ne,nd+1:end),tmp(1:ne,1:nd),[],Ts);
                    [gpeak,fpeak]=norminf(sstmp,1e-6,Focus);
                    if gpeak>1+TOL
                        cRate=(F-FLB)/(FUB-FLB);FUB=F;gUB=gpeak;
                    else
                        cRate=(FUB-F)/(FUB-FLB);FLB=F;gLB=gpeak;
                        wCritical=fpeak;
                    end
                    if cRate>0.6

                        Accel=0;
                    end
                end
                DeltaVary=FLB*DeltaVary;
                WorstLB.w=wCritical;
                WorstLB.LB=1/norm(DeltaVary);
                WorstLB.Delta(1:ny,1:nu)=DeltaVary;
            end


            function WorstLB=localAdjustBound(a,b,c,d,Ts,PerfBlkSize,WorstLB,Focus)

                [rs,cs]=size(d);
                nd=PerfBlkSize(1);
                ne=PerfBlkSize(2);
                nu=rs-ne;
                ny=cs-nd;
                Delta=WorstLB.Delta(1:ny,1:nu);

                tmp=lft(Delta,[d,c;b,a]);
                if hasInfNaN(tmp)

                    WorstLB.w=Inf;
                    WorstLB.LB=Inf;
                else
                    sstmp=ltipack.ssdata(tmp(ne+1:end,nd+1:end),tmp(ne+1:end,1:nd),...
                    tmp(1:ne,nd+1:end),tmp(1:ne,1:nd),[],Ts);
                    [gpeak,fpeak]=norminf(sstmp,1e-6,Focus,true);
                    if~isnan(fpeak)
                        WorstLB.w=fpeak;
                    end
                    WorstLB.LB=gpeak;
                end


                function percentDoneNow=localShowProgressUB(LmatForW,L0,Linf,Missing,percentDone)

                    LM=0;
                    for kk=1:size(Missing,1)
                        mP=Missing(kk,:);
                        if mP(1)==0
                            LM=LM+angle(1/lft(1/(1j*mP(2)),LmatForW))-angle(Linf);
                        elseif isinf(mP(2))
                            LM=LM+angle(L0)-angle(1/lft(1/(1j*mP(1)),LmatForW));
                        else
                            LM=LM+angle(1/lft(1/(1j*mP(2)),LmatForW))-angle(1/lft(1/(1j*mP(1)),LmatForW));
                        end
                    end
                    percentDoneNow=ceil(80*(1-LM/pi));
                    if percentDoneNow>percentDone
                        fprintf(repmat('\b',[1,numel(int2str(percentDone))+4]))
                        fprintf('%d/100',percentDoneNow)
                    end


                    function percentDoneNow=localShowProgressLB(frac,percentDone)
                        percentDoneNow=80+ceil(20*frac);
                        if percentDoneNow>percentDone
                            fprintf(repmat('\b',[1,numel(int2str(percentDone))+4]))
                            fprintf('%d/100',percentDoneNow)
                        end


                        function LBcert=localMaxLB(LBcert,newLB)
                            if newLB.LB>LBcert.LB
                                LBcert=newLB;
                            end
