function[T,ChangedBlock]=zeroFeedthrough(...
    T,SoftReqs,HardReqs,SYSDATA,SPECDATA,tInfo)

    nf=numel(tInfo.iFree);
    x0=zeros(nf,1);

    TB=tInfo.TunedBlocks;
    nblk=numel(TB);
    ADB=cell(nblk,1);
    for k=1:nblk
        ADB{k}=false(TB(k).ny,TB(k).nu);
    end

    for ct=1:numel(SPECDATA)
        RD=SPECDATA(ct);
        if RD.Type==2

            SD=SYSDATA(RD.Model,RD.Config);
            [D,DS]=NSOptUtil.analyzeFeedthrough(SD,RD,tInfo,x0);
            if norm(D,1)>0
                Reqs=[SoftReqs(:);HardReqs(:)];
                error(message('Control:tuning:Tuning7',getID(Reqs(RD.Goal))))
            end
            nw=numel(RD.Input);nz=numel(RD.Output);
            ny=SD.nzB;nu=SD.nwB;
            nL=numel(SD.iL);nwU=SD.nwU;nzU=SD.nzU;
            nfb=ny+nu+nwU+nzU+2*nL;
            [~,~,~,~,isActive]=smreal(DS(nz+1:nz+nfb,nw+1:nw+nfb),...
            DS(nz+1:nz+nfb,1:nw),DS(1:nz,nw+1:nw+nfb),[]);

            ir=nz+nfb-nu;ic=nw+nL+nzU;
            DCS=DS(ir+1:ir+nu,ic+1:ic+ny);
            ADC=false(nu,ny);
            ix=nL+nzU;iactY=find(isActive(ix+1:ix+ny,:));
            ix=nfb-nu;iactU=find(isActive(ix+1:ix+nu,:));
            ADC(iactU,iactY)=DCS(iactU,iactY);

            iu=0;iy=0;
            for k=1:nblk
                [nuB,nyB]=size(ADB{k});
                for j=1:SD.TunedBlocks(k).NRepeat
                    ADB{k}=ADB{k}|ADC(iu+1:iu+nuB,iy+1:iy+nyB);
                    iu=iu+nuB;iy=iy+nyB;
                end
            end
        end
    end

    TunedBlocks=T.Blocks;
    ChangedBlock=false;
    for k=1:nblk
        if any(ADB{k}(:))
            blkData=TB(k).Data;
            TunedBlocks.(blkData.Name)=zeroThru(blkData,ADB{k});
            ChangedBlock=true;
        end
    end

    if ChangedBlock
        T.Blocks=TunedBlocks;
    end

