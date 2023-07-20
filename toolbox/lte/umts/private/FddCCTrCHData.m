








function transportblocks=FddCCTrCHData(CCTrCH,TotFrames,varargin)
    if nargin==3
        vstr=varargin{1};
    else
        vstr='';
    end

    if~isstruct(CCTrCH)||(numel(CCTrCH)~=1)
        error('umts:error','CCTrCH must be single element structure.')
    end

    ttis=[CCTrCH.TrCH.TTI];
    validateUMTSParameter('TTI',ttis);

    ntrch=numel(ttis);

    maxTTI=max(ttis);
    nMaxTTI=ceil(TotFrames/maxTTI*10);


    transportblocks=cell(1,ntrch);
    for ch=1:ntrch

        trsrc=vectorDataSource(CCTrCH.TrCH(ch).DataSource);

        nTTI=maxTTI*nMaxTTI/CCTrCH.TrCH(ch).TTI;
        for t=1:nTTI
            actDyPart=CCTrCH.TrCH(ch).ActiveDynamicPart;
            validateUMTSParameter('ActiveDynamicPart',actDyPart);
            dyPart=CCTrCH.TrCH(ch).DynamicPart;
            if actDyPart>numel(dyPart)
                error('umts:error','ActiveDynamicPart must be <= %d',numel(dyPart));
            end





            validateUMTSParameter([vstr,'BlockSize'],dyPart(actDyPart).BlockSize);
            validateUMTSParameter([vstr,'BlockSetSize'],dyPart(actDyPart).BlockSetSize);
            if dyPart(actDyPart).BlockSize&&dyPart(actDyPart).BlockSetSize
                transportblocks{1,ch}{1,t}=trsrc.getPacket(dyPart(actDyPart).BlockSize);
            else

                blocks=dyPart(actDyPart).BlockSize~=dyPart(actDyPart).BlockSetSize;
                transportblocks{1,ch}{1,t}=ones(0,blocks);
            end
        end
    end
end