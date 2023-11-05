function[SYSDATA,SPECDATA,tInfo]=...
    getTuningData(T,SoftReqs,HardReqs,TunedModels,WarnFcn)

    [nz,nw,nsys]=size(T);
    Reqs=[SoftReqs(:);HardReqs(:)];
    nreqs=numel(Reqs);
    nsoft=numel(SoftReqs);
    Ts=T.Ts;
    if Ts==-1
        error(message('Control:tuning:TuningReq19'))
    end
    if nargin<4
        TunedModels=1:nsys;
    end
    nsysTuned=numel(TunedModels);


    nspec=0;
    for ct=1:nreqs
        R=Reqs(ct);
        if isa(R,'varyingGoal')
            localCheckVaryingGoal(R,nsys,T.SamplingGrid)
            nspec=nspec+nsysTuned;
        elseif isa(R,'TuningGoal.SystemLevel')
            if isequaln(R.Models,NaN)
                R.Models=1:nsys;
                nspec=nspec+nsysTuned;
            else
                R.Models=R.Models(R.Models<=nsys);
                nspec=nspec+numel(R.Models);
            end
            Reqs(ct)=R;
        else

            nspec=nspec+1;
        end
    end
    if nspec==0
        error(message('Control:tuning:systune43'))
    end









    FixedInteg=struct('Check',[],'Active',[],'Shift',[],...
    'U1',[],'U2',[],'V1',[],'V2',[],'A11',[],'A22',[]);
    SYSDATA(1:nsys,1)=struct(...
    'Active',false,'A',[],'B',[],'C',[],'D',[],'iL',[],...
    'nxB',[],'nwB',[],'nzB',[],'TunedBlocks',[],...
    'nxU',[],'nwU',[],'nzU',[],'UncertainBlocks',[],'iDelta',[],...
    'xPerf',[],'Ep',[],'Up',[],'Vp',[],...
    'xStab',[],'Es',[],'Us',[],'Vs',[],...
    'FixedInteg',FixedInteg,'Uf',[],'Vf',[],...
    'Acl',[],'Bcl',[],'Ccl',[],'Dcl',[],...
    'LFTData',[],'Scaling',[],'sInfo',[]);




    DS=struct('Static',false,'Dynamic',0);
    SPECDATA(1:nspec,1)=struct(...
    'Type',[],'Soft',[],'Stabilize',true,'Uncertain',false,...
    'Goal',[],'Model',[],'Input',[],'Output',[],'Config',[],...
    'Band',[],'WL',[],'WR',[],'Transform',[],'DScaling',DS,...
    'Sector',[],'Spectral',[],...
    'fStab',-Inf,'fRad',-Inf,'fObj',-Inf,'fWeight',1,...
    'E',zeros(0,1),'U',[],'V',[],...
    'xPerf',[],'Acl',[],'Bcl',[],'Ccl',[],'Dcl',[],'Ucl',[],...
    'PeakFreq',[],'HamEigs',[],'RY',[],'Flag',[]);







    Data=T.Data_;
    CplxUFlag=false;
    for ct=1:nsysTuned
        iM=TunedModels(ct);


        D=normalizeBlocks(Data(iM));
        B=D.Blocks;
        isAnalysis=logicalfun(@(blk)isa(blk,'AnalysisPoint'),B);
        isTuned=logicalfun(@isParametric,B);
        isUncty=logicalfun(@(blk)isa(blk,'ureal'),B);
        CplxUFlag=CplxUFlag|any(logicalfun(@isUncertain,B)&~isUncty);
        if~any(isTuned)
            error(message('Control:tuning:hinfstruct8'))
        end
        iA=find(isAnalysis);
        [~,bpermA]=sort(getBlockName(B(iA)));
        iU=find(isUncty);
        [~,bpermU]=sort(getBlockName(B(iU)));
        iT=find(isTuned);
        [~,bpermT]=sort(getBlockName(B(iT)));
        iN=find(~(isAnalysis|isUncty|isTuned));
        bperm=[iA(bpermA);iU(bpermU);iT(bpermT);iN];

        [rperm,cperm]=getRowColPerm(B,bperm);
        D.IC=ioperm(D.IC,[1:nz,nz+cperm],[1:nw,nw+rperm]);
        D.Blocks=B(bperm);

        nFold=numel(iN);
        if nFold>0
            D=foldBlocks(D,[false(numel(B)-nFold,1);true(nFold,1)]);
        end
        Data(iM)=D;
    end
    T.Data_=Data;
    if CplxUFlag
        WarnFcn(message('Control:tuning:systune27'))
    end


    BlockSet=getBlocks(T);
    BN=fieldnames(BlockSet);
    BV=struct2cell(BlockSet);
    isP=cellfun(@isParametric,BV);
    isU=cellfun(@isUncertain,BV);


    TunedBlocks=struct('Data',BV(isP,:),...
    'nx',[],'nu',[],'ny',[],'np',[],'npf',[],...
    'As',[],'Bs',[],'Cs',[],'D0',[],'Dsf',[]);
    TunedBlockNames=BN(isP);

    UBlocks=struct('Data',BV(isU,:),...
    'nx',0,'nu',1,'ny',1,'np',1,'npf',1);
    UBlockNames=BN(isU);



    isAP=~(isP|isU);
    AnalysisBlocks=struct('Data',BV(isAP,:),...
    'nch',[],'ich',[],'chID',[]);
    AnalysisBlockNames=BN(isAP);


    nAnalysis=numel(AnalysisBlocks);
    OpenAP=false;
    ich=0;
    for ct=1:nAnalysis
        blk=AnalysisBlocks(ct).Data;
        OpenAP=OpenAP||any(blk.Open);
        [nch,~]=iosize(blk);
        AnalysisBlocks(ct).nch=nch;
        AnalysisBlocks(ct).ich=(ich+1:ich+nch).';
        AnalysisBlocks(ct).chID=blk.Location;
        ich=ich+nch;
    end
    if OpenAP


        WarnFcn(message('Control:tuning:Tuning1'))
    end
    nL=sum([AnalysisBlocks.nch]);
    LoopConfigs=false(nL,0);


    p0=zeros(0,1);pMin=zeros(0,1);pMax=zeros(0,1);
    iFree=zeros(0,1);iBlock=zeros(0,1);
    ip=0;ix=0;
    for ct=1:numel(TunedBlocks)
        blk=TunedBlocks(ct).Data;
        [ny,nu]=iosize(blk);
        p=getp(blk);
        [pL,pU]=getpMinMax(blk);
        if any(pL>=pU)
            error(message('Control:tuning:Tuning4',blk.Name))
        end
        np=length(p);
        indf=find(isfree(blk));
        npf=length(indf);
        TunedBlocks(ct).nx=numState(blk);
        TunedBlocks(ct).nu=nu;
        TunedBlocks(ct).ny=ny;
        TunedBlocks(ct).np=np;
        TunedBlocks(ct).npf=npf;

        [TunedBlocks(ct).As,TunedBlocks(ct).Bs,TunedBlocks(ct).Cs,...
        TunedBlocks(ct).D0,TunedBlocks(ct).Dsf]=sInfo(blk);

        p0=[p0;p];%#ok<*AGROW>
        pMin=[pMin;pL];
        pMax=[pMax;pU];

        iFree=[iFree;ip+indf];
        iBlock(ix+1:ix+npf,:)=ct;
        ip=ip+np;ix=ix+npf;
    end









    nxL=zeros(nL,1);
    nsL=zeros(nL,1);
    ISSGraph=eye(nL);



    DL0=struct('a',[],'b',zeros(0,nL+nz),'c',zeros(nL+nz,0),'d',eye(nL+nz),'Poles',zeros(0,1));
    DR0=struct('a',[],'b',zeros(0,nL+nw),'c',zeros(nL+nw,0),'d',eye(nL+nw),'Poles',zeros(0,1));
    tInfo=struct(...
    'nw',nw,'nz',nz,'nL',nL,...
    'p0',[],'pMin',[],'pMax',[],...
    'iFree',[],'iBlock',[],...
    'TunedBlocks',TunedBlocks,...
    'UncertainBlocks',UBlocks,...
    'SwitchBlocks',AnalysisBlocks,...
    'LoopConfigs',[],...
    'LoopScalings',[],'DL',DL0,'DR',DR0,...
    'SpecEvalOrder',[],'Ts',Ts,'TU',T.TimeUnit);


    for ct=1:nsysTuned
        iM=TunedModels(ct);

        [ABInfo,UBInfo,TBInfo]=SYSTUNE_BlockInfo(Data(iM).Blocks,...
        AnalysisBlockNames,UBlockNames,TunedBlockNames);

        Nr=cat(1,ABInfo.NRepeat);
        if any(Nr>1)
            error(message('Control:tuning:Tuning2'))
        end
        SYSDATA(iM).iL=cat(1,AnalysisBlocks(Nr>0).ich);

        nr=cat(1,UBInfo.NRepeat);
        for k=1:numel(UBInfo)
            UBInfo(k).Offset(:)=0;
        end
        SYSDATA(iM).nxU=sum(nr.*cat(1,UBlocks.nx));
        SYSDATA(iM).nwU=sum(nr.*cat(1,UBlocks.ny));
        SYSDATA(iM).nzU=sum(nr.*cat(1,UBlocks.nu));
        SYSDATA(iM).UncertainBlocks=UBInfo;

        nr=cat(1,TBInfo.NRepeat);
        SYSDATA(iM).nxB=sum(nr.*cat(1,TunedBlocks.nx));
        SYSDATA(iM).nwB=sum(nr.*cat(1,TunedBlocks.ny));
        SYSDATA(iM).nzB=sum(nr.*cat(1,TunedBlocks.nu));
        SYSDATA(iM).TunedBlocks=TBInfo;
    end







    uNames=T.InputName;
    yNames=T.OutputName;
    if~(localCheckSignalList(uNames)&&localCheckSignalList(yNames))
        error(message('Control:tuning:Tuning5'))
    end
    aNames=cat(1,cell(0,1),AnalysisBlocks.chID);
    if~localCheckSignalList(aNames)
        error(message('Control:tuning:Tuning6'))
    end


    isActive=false(nsys,1);
    nspec=0;S0=SPECDATA(1);
    for ct=1:nreqs
        R=Reqs(ct);
        if isa(R,'varyingGoal')

            for ctM=1:nsysTuned
                iM=TunedModels(ctM);
                S=S0;S.Goal=ct;S.Soft=(ct<=nsoft);S.Model=iM;
                try
                    Rk=getGoal(R,'index',iM);
                catch ME
                    throw(ME)
                end
                if~isempty(Rk)
                    [S,LoopConfigs]=getSpecData(Rk,S,LoopConfigs,uNames,yNames,aNames,Ts);
                    if~(S.Type==3&&isempty(localCheckRelevance(iM,S.Input-nw,SYSDATA)))
                        isActive(iM,S.Config)=true;
                        nspec=nspec+1;SPECDATA(nspec)=S;
                    end
                end
            end
        else
            S=S0;S.Goal=ct;S.Soft=(ct<=nsoft);
            if isa(R,'TuningGoal.SystemLevel')
                [S,LoopConfigs]=getSpecData(R,S,LoopConfigs,uNames,yNames,aNames,Ts);

                iM=intersect(R.Models,TunedModels,'stable');
                if S.Type==3


                    iM=localCheckRelevance(iM,S.Input-nw,SYSDATA);
                end

                for ctS=1:numel(iM)
                    nspec=nspec+1;SPECDATA(nspec)=S;
                    SPECDATA(nspec).Model=iM(ctS);
                end

                isActive(iM,S.Config)=true;
            else

                nspec=nspec+1;SPECDATA(nspec)=getSpecData(R,S,TunedBlockNames);
            end
        end
    end
    if nspec==0
        error(message('Control:tuning:systune44'))
    end
    SPECDATA=SPECDATA(1:nspec);
    tInfo.SpecEvalOrder=1:nspec;
    tInfo.LoopConfigs=LoopConfigs;




    for ct=1:numel(SPECDATA)
        S=SPECDATA(ct);
        if S.Type==3

            iL=S.Input-nw;
            if S.DScaling.Static
                ISSGraph(iL,iL)=1;
            end
            nxL(iL)=max(nxL(iL),S.DScaling.Dynamic);
        end
    end
    [p,~,r,~]=dmperm(ISSGraph);
    for ct=1:numel(r)-1
        nsL(p(r(ct)+1:r(ct+1)-1))=1;
    end
    npL=nsL+2*nxL;
    snpL=sum(npL);
    p0=[p0;zeros(snpL,1)];
    pMin=[pMin;zeros(snpL,1)];
    pMax=[pMax;zeros(snpL,1)];
    if Ts==0
        InitPole=-1;
    else
        InitPole=exp(-Ts);
    end
    for ct=1:nL
        ns=nsL(ct);
        nx=nxL(ct);
        np=npL(ct);
        q=poly(InitPole(:,ones(nx,1)));
        ipx=ip+ns;
        p0(ipx+1:ip+np)=q([2:nx+1,2:nx+1]);

        pMin(ip+1:ipx,:)=-100;pMin(ipx+1:ip+np)=-Inf;
        pMax(ip+1:ipx,:)=100;pMax(ipx+1:ip+np)=Inf;
        iFree=[iFree;(ip+1:ip+np).'];
        iBlock(ix+1:ix+np,:)=-ct;
        ix=ix+np;
        ip=ip+np;
    end
    tInfo.p0=p0;
    tInfo.pMin=pMin;
    tInfo.pMax=pMax;
    tInfo.iFree=iFree;
    tInfo.iBlock=iBlock;
    tInfo.LoopScalings=struct('nc',1,'ns',num2cell(nsL),'nx',num2cell(nxL),'np',num2cell(npL));


























    SYSDATA=repmat(SYSDATA,[1,size(LoopConfigs,2)]);
    for ct=1:nsysTuned

        iM=TunedModels(ct);
        iConfig=find(isActive(iM,:));
        if isempty(iConfig)
            continue
        end

        IC=Data(iM).IC;
        if~isempty(IC.e)
            [isP,IC]=isproper(IC,true);
            if~isP
                error(message('Control:tuning:Tuning3'))
            end
        end
        nxP=size(IC.a,1);

        iL=SYSDATA(iM,1).iL;
        nch=numel(iL);

        [Aus,Bus,Cus,Dus]=localUStruct(SYSDATA(iM,1),tInfo);
        nxU=size(Aus,1);

        [Acs,Bcs,Ccs,Dcs]=localCStruct(SYSDATA(iM,1),tInfo);
        nxC=size(Acs,1);

        for ctc=1:numel(iConfig)
            iSC=iConfig(ctc);
            LSC=diag(LoopConfigs(iL,iSC));

            SYSDATA(iM,iSC).Active=true;
            SYSDATA(iM,iSC).sInfo=localCLStruct(...
            IC,LSC,Aus,Bus,Cus,Dus,Acs,Bcs,Ccs,Dcs);

            D=feedback(IC,createGain(IC,LSC),nw+1:nw+nch,nz+1:nz+nch,+1);
            SYSDATA(iM,iSC).A=D.a;
            SYSDATA(iM,iSC).B=D.b;
            SYSDATA(iM,iSC).C=D.c;
            SYSDATA(iM,iSC).D=D.d;
            if nch<nL

                SYSDATA(iM,iSC)=localInsertZeros(SYSDATA(iM,iSC),nw,nz,nL,iL');
            end

            SYSDATA(iM,iSC).Scaling=struct('sx',[],'px',[]);
            SYSDATA(iM,iSC).xStab=false(nxP+nxC+nxU,1);
            SYSDATA(iM,iSC).xPerf=false(nxP+nxC+nxU,1);
        end
    end


    for ct=1:nspec
        S=SPECDATA(ct);
        iM=S.Model;
        iC=S.Config;
        if iC>0


            SI=SYSDATA(iM,iC).sInfo;
            if isempty(S.Input)

                xPerf=true(SI.nx,1);
            else

                [~,~,~,~,xkeep]=smreal(SI.a,SI.b(:,S.Input),SI.c(S.Output,:),[]);
                xPerf=xkeep(1:SI.nx,:);
            end
            SPECDATA(ct).xPerf=find(xPerf);
            SYSDATA(iM,iC).xPerf=(SYSDATA(iM,iC).xPerf|xPerf);
            if S.Stabilize
                SYSDATA(iM,iC).xStab=(SYSDATA(iM,iC).xStab|xPerf);
            end

            if SYSDATA(iM,iC).nwU>0
                SPECDATA(ct).Uncertain=true;
            end
        end
    end


    for ct=1:numel(SYSDATA)
        if isActive(ct)
            SYSDATA(ct).xStab=find(SYSDATA(ct).xStab);
            SYSDATA(ct).xPerf=find(SYSDATA(ct).xPerf);
        end
    end



    function isys=localCheckRelevance(isys,iL,SYSDATA)

        nsys=numel(isys);
        isRelevant=false(nsys,1);
        for ct=1:nsys
            isRelevant(ct)=all(ismember(iL,SYSDATA(isys(ct)).iL));
        end
        isys=isys(isRelevant);

        function SYSDATA=localInsertZeros(SYSDATA,nw,nz,nL,iL)

            nch=numel(iL);
            nx=size(SYSDATA.A,1);
            ios=size(SYSDATA.D)+nL-nch;
            iu=[1:nw,nw+iL,nw+nL+1:ios(2)];
            iy=[1:nz,nz+iL,nz+nL+1:ios(1)];

            b=zeros(nx,ios(2));b(:,iu)=SYSDATA.B;SYSDATA.B=b;
            c=zeros(ios(1),nx);c(iy,:)=SYSDATA.C;SYSDATA.C=c;
            d=zeros(ios);d(iy,iu)=SYSDATA.D;SYSDATA.D=d;

            sInfo=SYSDATA.sInfo;
            nxs=size(sInfo.a,1);
            ios=[nz+nL,nw+nL];
            iu=[1:nw,nw+iL];
            iy=[1:nz,nz+iL];
            b=false(nxs,ios(2));b(:,iu)=sInfo.b;sInfo.b=b;
            c=false(ios(1),nxs);c(iy,:)=sInfo.c;sInfo.c=c;
            d=false(ios);d(iy,iu)=sInfo.d;sInfo.d=d;
            SYSDATA.sInfo=sInfo;

            function isOK=localCheckSignalList(NameList)

                NameList=NameList(~strcmp(NameList,''));
                isOK=(numel(unique(NameList))==numel(NameList));

                function[Acs,Bcs,Ccs,Dcs]=localCStruct(SYSDATA,tInfo)

                    nblk=length(tInfo.TunedBlocks);
                    nxB=SYSDATA.nxB;
                    nwB=SYSDATA.nwB;
                    nzB=SYSDATA.nzB;
                    Acs=false(nxB);
                    Bcs=false(nxB,nzB);
                    Ccs=false(nwB,nxB);
                    Dcs=false(nwB,nzB);
                    ix=0;iu=0;iy=0;
                    for j=1:nblk
                        nr=SYSDATA.TunedBlocks(j).NRepeat;
                        Offset=SYSDATA.TunedBlocks(j).Offset;
                        if nr>0
                            blk=tInfo.TunedBlocks(j);
                            nxj=size(blk.As,1);
                            [nyj,nuj]=size(blk.D0);
                            for ct=1:nr
                                Acs(ix+1:ix+nxj,ix+1:ix+nxj)=blk.As;
                                Bcs(ix+1:ix+nxj,iu+1:iu+nuj)=blk.Bs;
                                Ccs(iy+1:iy+nyj,ix+1:ix+nxj)=blk.Cs;

                                Dcs(iy+1:iy+nyj,iu+1:iu+nuj)=(blk.D0-Offset(:,:,ct)~=0)|blk.Dsf;
                                ix=ix+nxj;iu=iu+nuj;iy=iy+nyj;
                            end
                        end
                    end

                    function[Aus,Bus,Cus,Dus]=localUStruct(SYSDATA,tInfo)

                        nblk=length(tInfo.UncertainBlocks);
                        nxU=SYSDATA.nxU;
                        nwU=SYSDATA.nwU;
                        nzU=SYSDATA.nzU;
                        Aus=false(nxU);
                        Bus=false(nxU,nzU);
                        Cus=false(nwU,nxU);
                        Dus=false(nwU,nzU);
                        ix=0;iu=0;iy=0;
                        for j=1:nblk
                            nr=SYSDATA.UncertainBlocks(j).NRepeat;
                            if nr>0
                                blk=tInfo.UncertainBlocks(j);
                                nxj=blk.nx;nuj=blk.nu;nyj=blk.ny;
                                for ct=1:nr
                                    Aus(ix+1:ix+nxj,ix+1:ix+nxj)=true;
                                    Bus(ix+1:ix+nxj,iu+1:iu+nuj)=true;
                                    Cus(iy+1:iy+nyj,ix+1:ix+nxj)=true;
                                    Dus(iy+1:iy+nyj,iu+1:iu+nuj)=true;
                                    ix=ix+nxj;iu=iu+nuj;iy=iy+nyj;
                                end
                            end
                        end

                        function sInfo=localCLStruct(IC,APConfig,Au,Bu,Cu,Du,Ac,Bc,Cc,Dc)



                            A=(IC.a~=0);
                            B=(IC.b~=0);
                            C=(IC.c~=0);
                            D=(IC.d~=0);
                            nx=size(A,1);nxc=size(Ac,1);nxu=size(Au,1);
                            [nu,ny]=size(Dc);[nwu,nzu]=size(Du);
                            nL=size(APConfig,1);
                            [rs,cs]=size(D);
                            nw=cs-(nu+nwu+nL);nz=rs-(ny+nzu+nL);

                            ir=[nz+1:rs,1:nz,nz+1:nz+nL];
                            ic=[nw+1:cs,1:nw,nw+1:nw+nL];
                            B=B(:,ic);C=C(ir,:);D=D(ir,ic);
                            nws=nw+nL;nzs=nz+nL;








                            s1=nx+nxu+nxc;s2=s1+ny+nzu+nL;s3=s2+nu+nwu+nL;

                            ir=[1:nx,s1+1:s2,s3+1:s3+nzs];
                            ic=[1:nx,s2+1:s3+nws];
                            MS(ir,ic)=[A,B;C,D];

                            MS(s2+1:s2+nL,s1+1:s1+nL)=APConfig;

                            ir=[nx+1:nx+nxu,s2+nL+1:s2+nL+nwu];
                            ic=[nx+1:nx+nxu,s1+nL+1:s1+nL+nzu];
                            MS(ir,ic)=[Au,Bu;Cu,Du];

                            ir=[nx+nxu+1:nx+nxu+nxc,s2+nL+nwu+1:s3];
                            ic=[nx+nxu+1:nx+nxu+nxc,s1+nL+nzu+1:s2];
                            MS(ir,ic)=[Ac,Bc;Cc,Dc];

                            sInfo=struct('a',MS(1:s3,1:s3),'b',MS(1:s3,s3+1:s3+nws),...
                            'c',MS(s3+1:s3+nzs,1:s3),'d',MS(s3+1:s3+nzs,s3+1:s3+nws),...
                            'nx',nx+nxc+nxu);


                            function localCheckVaryingGoal(R,npts,SG)

                                ndp=prod(getSize(R));
                                if ndp~=npts
                                    error(message('Control:tuning:Tuning8',ndp,npts))
                                end

                                SGR=R.SamplingGrid;
                                if~(isequal(SGR,struct)||isequal(SG,struct)||isequal(SG,SGR))
                                    error(message('Control:tuning:Tuning9'))
                                end


