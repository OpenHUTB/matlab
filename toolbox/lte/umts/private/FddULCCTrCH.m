































function frames=FddULCCTrCH(varargin)

    CCTrCH=varargin{1};
    if numel(CCTrCH)~=1
        error('umts:error','The number of DPCH CCTrCH must be 1');
    end

    NDataPerFrame=varargin{2};

    TrBlks=varargin(3:end);


    ntrch=numel(CCTrCH.TrCH);

    validateUMTSParameter('TTI',[CCTrCH.TrCH.TTI]);


    NOfr=hGetULRateMatchingParams(CCTrCH.TrCH,NDataPerFrame);
    if any(NOfr<=0)
        error('umts:error','For the given DPCH CCTrCH configuration the rate matching stage cannot rate match to the Physical channel capacity');
    end




    nFramesGen=numel(TrBlks{1})*CCTrCH.TrCH(1).TTI/10;
    frames=zeros(NDataPerFrame,nFramesGen);
    trchIdx=cumsum(NOfr);
    startidx=1;
    for ch=1:ntrch
        CCTrCH.TrCH(ch).NO=NOfr(ch);
        trb=TrBlks{ch};
        rmdata=[];
        for t=1:numel(trb)

            rmdata=[rmdata;hULTrChGen(CCTrCH.TrCH(ch),trb{t})];%#ok<AGROW>
        end

        frames(startidx:trchIdx(ch),:)=reshape(rmdata,NOfr(ch),length(rmdata)/NOfr(ch));
        startidx=trchIdx(ch)+1;
    end
    frames=frames(:);

end

function rmatched=hULTrChGen(chconfig,data)
    actDyPart=chconfig.ActiveDynamicPart;
    validateUMTSParameter('ActiveDynamicPart',actDyPart);
    dyPart=chconfig.DynamicPart;
    if actDyPart>numel(dyPart)
        error('umts:error','ActiveDynamicPart must be <= %d',numel(dyPart));
    end
    crccoded=FddCRC(data,1,chconfig.CRC);
    convcoded=FddTrCHCoding(crccoded,chconfig.CodingType);
    fistinted=FddULFirstInterleaving(convcoded,chconfig.TTI);
    rmatched=FddULRateMatching(fistinted,chconfig.NO*chconfig.TTI/10,chconfig.CodingType,chconfig.TTI);
    if isrow(rmatched)

        rmatched=transpose(rmatched);
    end
end




function NOfr=hGetULRateMatchingParams(trCh,NDataPerFrame)

    ntrCh=numel(trCh);
    fintout=cell(1,ntrCh);
    Nij=zeros(1,ntrCh);
    RMattr=zeros(1,ntrCh);
    for t=1:ntrCh
        fintout{t}=hGetFstInterleavedTrCh(trCh(t));
        framesperTTI=trCh(t).TTI/10;
        Nij(t)=length(fintout{t})/(framesperTTI);
        RMattr(t)=trCh(t).RMA;
    end
    deltaNij=hRMvaluesfromRMattribute(NDataPerFrame,RMattr,Nij);

    NOfr=Nij+deltaNij;

end

function[fintout,trCh]=hGetFstInterleavedTrCh(trCh)
    datain=zeros(1,trCh.DynamicPart(1).BlockSize);
    crced=FddCRC(datain,1,trCh.CRC);
    chcoded=FddTrCHCoding(crced,trCh.CodingType);
    fintout=FddULFirstInterleaving(chcoded,trCh.TTI);

end

function deltaNij=hRMvaluesfromRMattribute(Ndata,RMattr,Nij)
    if(min(RMattr)<1||max(RMattr)>256)
        error('umts:error','The Rate Matching attribute (RMA) is invalid. Must be 1 to 256');
    end
    Zij=zeros(1,numel(RMattr));
    deltaNij=zeros(1,numel(RMattr));
    for ii=1:numel(RMattr)
        Zij(ii+1)=floor(sum(RMattr(1:ii).*Nij(1:ii))*Ndata/(sum(RMattr.*Nij)));
        deltaNij(ii)=Zij(ii+1)-Zij(ii)-Nij(ii);
    end
end