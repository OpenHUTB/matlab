


























function out=FddHSUPA(config)


    framestoTx=config.TotFrames;
    if config.HSUPA.EDCH.TTI==2
        framestoTx=config.TotFrames*5;
    end


    edchConfig=config.HSUPA.EDCH;
    edchConfig.TotFrames=config.TotFrames;
    edchConfig.Nmaxdpdch=config.Nmaxdpdch;
    edchConfig.RSNSequence=config.HSUPA.RSNSequence;
    validateUMTSParameter('RSNSequence',config.HSUPA);
    edchConfig.CodeCombination=config.HSUPA.CodeCombination;
    edchConfig.hsdschConfigured=config.HSUPA.HSDSCHConfigured;
    [edpdchsubframes,rsn]=FddEDCH(edchConfig);
    if~strcmpi(config.HSUPA.DataSource,'EDCH')

        edpdchsrc=vectorDataSource(config.HSUPA.DataSource);
        edpdchsubframes=edpdchsrc.getPacket(numel(edpdchsubframes));
    end
    if isequal(config.HSUPA.EDPDCHPower,-Inf)
        edpdchsubframes=[];
    end



    if~isequal(config.HSUPA.EDPCCHPower,-Inf)
        etfciSource=vectorDataSource(config.HSUPA.ETFCI);
        etfci=etfciSource.getPacket(framestoTx);
        happySource=vectorDataSource(config.HSUPA.HappyBit);
        happy=happySource.getPacket(framestoTx);
        if config.HSUPA.EDCH.TTI==10

            rsn=repmat(rsn,5,1);rsn=rsn(:);
            etfci=repmat(etfci,5,1);etfci=etfci(:);
            happy=repmat(happy,5,1);happy=happy(:);
        end
        edpcchsubframes=FddEDPCCHCoding(happy,rsn,etfci);
    else
        edpcchsubframes=[];
    end

    if~(isempty(edpdchsubframes)&&isempty(edpcchsubframes))
        edpchConfig=edchConfig;
        edpchConfig.ScramblingCode=config.ScramblingCode;
        edpchConfig.EDPDCHPower=config.HSUPA.EDPDCHPower;
        edpchConfig.EDPCCHPower=config.HSUPA.EDPCCHPower;
        out=FddEDPCH(edpchConfig,edpdchsubframes,edpcchsubframes);
    end

end