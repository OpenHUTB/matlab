function[gridset,msg,waveResources]=computeResourceGridPRB(wgc)


    [waveResources,csetInfo,msg]=computeChannelREIndices(wgc);

    [channelGrids,csetGrids]=markBWPGrids(wgc,waveResources,csetInfo);


    for bp=1:length(channelGrids)
        gridset(bp).ResourceGridPRB=channelGrids{bp};%#ok<AGROW>
        if isa(wgc,"nrDLCarrierConfig")
            gridset(bp).CORESETGridPRB=csetGrids{bp};%#ok<AGROW>
        end
    end

end


function[waveResources,csetInfo,msg]=computeChannelREIndices(wgc)

    import nr5g.internal.wavegen.*;


    validateConfig(wgc);


    waveResources=[];
    csetInfo=[];
    msg='';


    bwps=wgc.BandwidthParts;
    carriers=wgc.SCSCarriers;
    nCellID=wgc.NCellID;
    numSubframes=wgc.NumSubframes;

    isDownlink=isa(wgc,'nrDLCarrierConfig');
    if isDownlink

        ssb=wgc.SSBurst;
        pdschs=wgc.PDSCH;
        coresets=wgc.CORESET;
        searchSpaces=wgc.SearchSpaces;
        pdcchs=wgc.PDCCH;
        csirss=wgc.CSIRS;


        ssbstruct=mapSSBObj2Struct(ssb,carriers);
        resSSB=ssburstResources(ssbstruct,carriers,bwps);


        pdcchsInfo=getPDCCHIndices(nCellID,numSubframes,carriers,bwps,coresets,searchSpaces,pdcchs);


        [pdcchReservedPRB,pdcchReservedRE]=getPDCCHReservedResources(numSubframes,carriers,bwps,pdcchs,pdcchsInfo,pdschs);


        [csirsInfo,csirsReservedRE]=getCSIRSIndices(nCellID,numSubframes,carriers,bwps,csirss,pdschs);


        reservedRE=cellfun(@(x,y)cat(1,x,y),pdcchReservedRE,csirsReservedRE,'UniformOutput',false);


        [pdschInfo,msg]=getPXSCHIndices(wgc,resSSB,pdcchReservedPRB,reservedRE,msg);




        waveResources.PDSCH=pdschInfo;
        waveResources.PDCCH=pdcchsInfo;
        waveResources.CSIRS=csirsInfo;


        csetInfo=getCORESETIndices(numSubframes,bwps,coresets,searchSpaces,pdcchs);

    else

        pucchs=wgc.PUCCH;
        srss=wgc.SRS;


        [pucchInfo,msg]=getPUCCHIndices(nCellID,numSubframes,bwps,pucchs,msg);


        [puschInfo,msg]=getPXSCHIndices(wgc,[],[],[],msg);


        srsInfo=getSRSIndices(nCellID,numSubframes,bwps,srss);




        waveResources.PUSCH=puschInfo;
        waveResources.PUCCH=pucchInfo;
        waveResources.SRS=srsInfo;

    end

end





function[chinfo,reservedRE]=getCSIRSIndices(nCellID,numSubframes,carriers,bwps,csirss,pdschs)

    import nr5g.internal.wavegen.*;

    carrierscs=cellfun(@(x)x.SubcarrierSpacing,carriers);
    maxNumSlots=numSubframes*(max(carrierscs)/15);
    reservedRE=cell(numel(pdschs),maxNumSlots);

    numCSIRS=numel(csirss);
    chinfo=unitInfoStruct(csirss,numCSIRS);
    for nsig=1:numCSIRS


        if~csirss{nsig}.Enable
            continue;
        end


        sig=csirss{nsig};


        [bwp,bwpIdx]=getBWPByID(bwps,sig.BandwidthPartID);
        carrierwg=getSCSCarrierFromBWP(carriers,bwp);


        allocatedSlots=getSlotAllocation(bwp,sig,numSubframes);


        csirs=getCSIRSObject(sig);
        carrier=getCarrierCfgObject(carrierwg,nCellID,bwp.CyclicPrefix);


        [csirsIndices,reservedCSIRS]=getSingleCSIRSIndices(carrier,bwp,csirs,allocatedSlots);


        chinfo(nsig).Name=['CSI-RS',num2str(nsig)];
        if~isempty(csirsIndices)
            chinfo(nsig).Resources=struct('NSlot',num2cell(allocatedSlots),...
            'SignalIndices',csirsIndices);
        end


        for s=allocatedSlots
            reservedRE=getCSIRSReservedRE(reservedRE,bwp,pdschs,reservedCSIRS{s+1},s);
        end

    end

end




function[indices,reservedRE]=getSingleCSIRSIndices(carrier,bwp,csirs,allocatedSlots)

    nrb=bwp.NSizeBWP;
    bwpGridSize=[12*nrb,carrier.SymbolsPerSlot,csirs.NumCSIRSPorts];
    bwpRBOffset=bwp.NStartBWP-carrier.NStartGrid;


    numSlots=numel(allocatedSlots);
    indices=repmat({uint32(zeros(0,1))},1,numSlots);
    reservedRE=cell(1,numSlots);
    for s=1:numSlots

        slot=allocatedSlots(s);
        carrier.NSlot=slot;


        csirsInd=nrCSIRSIndices(carrier,csirs,'IndexStyle','subscript');


        offsetSubc=csirsInd(:,1)-bwpRBOffset*12;
        bwpCSIRSInd=[offsetSubc,csirsInd(:,2),csirsInd(:,3)];

        ind2rmv=bwpCSIRSInd(:,1)<=0|bwpCSIRSInd(:,1)>bwpGridSize(1);
        bwpCSIRSInd(ind2rmv,:)=[];

        csirsInd=sub2ind(bwpGridSize,bwpCSIRSInd(:,1),bwpCSIRSInd(:,2),bwpCSIRSInd(:,3));

        indices{s}=uint32(csirsInd);


        reservedRE{slot+1}=double(csirsInd);

    end

end


function reservedREs=getCSIRSReservedRE(reservedREs,bwp,pdsch,csirsInd,slot)



    for nch=1:numel(pdsch)
        dch=pdsch{nch};
        if dch.Enable
            if(dch.BandwidthPartID==bwp.BandwidthPartID)

                reservedREs{nch,slot+1}=[reservedREs{nch,slot+1};csirsInd-1];
            end
        end
    end

end





function chinfo=getPDCCHIndices(nCellID,numSubframes,carriers,bwps,coresets,searchspaces,pdcchs)

    import nr5g.internal.wavegen.*;

    numPDCCH=numel(pdcchs);
    chinfo=unitInfoStruct(pdcchs,numPDCCH);
    for nch=1:numPDCCH


        if~pdcchs{nch}.Enable
            continue;
        end


        ch=pdcchs{nch};


        [bwp,bwpIdx]=getBWPByID(bwps,ch.BandwidthPartID);
        carrierwg=getSCSCarrierFromBWP(carriers,bwp);


        slots=getSlotAllocation(bwp,ch,numSubframes);


        carrier=getCarrierCfgObject(carrierwg,nCellID,bwp.CyclicPrefix);

        [pdcch,ss]=getPDCCHObject(ch,bwp,coresets,searchspaces,0);


        if ch.RNTI>0&&ch.RNTI<=65519&&strcmp(ss.SearchSpaceType,'ue')
            n_RNTI=ch.RNTI;
        else
            n_RNTI=0;
        end
        pdcch.RNTI=n_RNTI;


        [channelInd,dmrsInd,allocSlots]=...
        getSinglePDCCHIndices(carrier,ss,pdcch,slots);


        chinfo(nch).Name=['PDCCH',num2str(nch)];
        if~isempty(channelInd)
            chinfo(nch).Resources=struct('NSlot',num2cell(allocSlots),...
            'ChannelIndices',channelInd,...
            'DMRSIndices',dmrsInd);
        end

    end

end




function[channelIndices,dmrsIndices,allocatedSlots]=getSinglePDCCHIndices(carrier,ss,pdcch,allocSlots)



    startSymbs=ss.StartSymbolWithinSlot;
    symbolsPerSlot=carrier.SymbolsPerSlot;
    potentialAllocSym=reshape(symbolsPerSlot*allocSlots+startSymbs',1,[]);




    allocSlotIndices=0:numel(potentialAllocSym)-1;



    allocatedSymbols=potentialAllocSym(1+allocSlotIndices);
    allocatedSlots=fix(allocatedSymbols/symbolsPerSlot);


    numAllocatedSlots=length(allocatedSlots);
    channelIndices=repmat({uint32(zeros(0,1))},1,numAllocatedSlots);
    dmrsIndices=repmat({uint32(zeros(0,1))},1,numAllocatedSlots);
    for slotIdx=1:numAllocatedSlots

        nslot=allocatedSlots(slotIdx);
        carrier.NSlot=nslot;


        [slotREInd,~,slotDMRSInd]=nrPDCCHResources(carrier,pdcch,'IndexOrientation','bwp');

        channelIndices{slotIdx}=slotREInd;
        dmrsIndices{slotIdx}=slotDMRSInd;

    end

end



function[reservedPRB,reservedRE]=getPDCCHReservedResources(numSubframes,carriers,bwps,pdcchs,pdcchsInfo,pdschs)


    carrierscs=cellfun(@(x)x.SubcarrierSpacing,carriers);
    maxNumSlots=numSubframes*(max(carrierscs)/15);
    reservedRE=cell(numel(pdschs),maxNumSlots);



    numPDSCH=numel(pdschs);
    reservedPRB=cell(1,numPDSCH);
    for nch=1:numel(pdcchs)


        if~pdcchs{nch}.Enable
            continue;
        end



        pdcch=pdcchs{nch};
        pdcchInfo=pdcchsInfo(nch);




        for d=1:numPDSCH
            pdsch=pdschs{d};



            if(pdsch.RNTI==pdcch.RNTI)&&(pdsch.BandwidthPartID==pdcch.BandwidthPartID)


                [bwp,bwpIdx]=getBWPByID(bwps,pdsch.BandwidthPartID);
                symbolsPerSlot=12+2*strcmpi(bwp.CyclicPrefix,'normal');



                pdcchResources=pdcchInfo.Resources;
                pdcchAllocSlots=[pdcchResources.NSlot];



                for slotIdx=1:length(pdcchAllocSlots)


                    NSlot=pdcchAllocSlots(slotIdx);


                    pdcchInd=pdcchResources(slotIdx).ChannelIndices;



                    thisRsv=nrPDSCHReservedConfig;
                    thisRsv.PRBSet=unique(mod(floor(double(pdcchInd-1)/12),bwp.NSizeBWP));
                    thisRsv.SymbolSet=NSlot*symbolsPerSlot+unique(floor(double(pdcchInd-1)/12/bwp.NSizeBWP));
                    thisRsv.Period=[];



                    reservedPRB{d}=[reservedPRB{d},{thisRsv}];



                    reservedRE{d,1+NSlot}=pdcchResources(slotIdx).DMRSIndices-1;

                end
            end
        end
    end

end



function csetInfo=getCORESETIndices(numSubframes,bwps,coresets,searchSpaces,pdcchs)

    import nr5g.internal.wavegen.*;

    ssCORESETIDs=getSinglePropValuesFromCellWithObjects(searchSpaces,'CORESETID');
    pdcchSearchSpaceIDs=getSinglePropValuesFromCellWithObjects(pdcchs,'SearchSpaceID');
    csetInfo=[];
    for csidx=1:length(coresets)


        cs=coresets{csidx};
        ssidxs=find(ssCORESETIDs==cs.CORESETID);


        bwpIDs=[];
        for ssidx=ssidxs
            ss=searchSpaces{ssidx};
            for pdcchidx=find(pdcchSearchSpaceIDs==ss.SearchSpaceID)
                pdcch=pdcchs{pdcchidx};
                bwpIDs=[bwpIDs,pdcch.BandwidthPartID];%#ok<AGROW>
            end
        end
        bwpIDs=unique(bwpIDs);


        for bwpID=bwpIDs


            [bwp,bwpIdx]=getBWPByID(bwps,bwpID);
            if(isempty(bwp))

                continue;
            end


            prb=nr5g.internal.pdcch.getCORESETPRB(cs,bwp.NStartBWP);
            prb(prb>=bwp.NSizeBWP)=[];

            symPerSlot=symbolsPerSlot(bwp);


            for ssidx=ssidxs

                ss=searchSpaces{ssidx};
                symbols=getCORESETSymbols(numSubframes,bwp,cs,ss);

                slots=unique(fix(symbols/symPerSlot));
                symbols=mod(symbols,symPerSlot);

                Indices=reshape(reshape(prb(:)'*12+(1:12)',[],1)+bwp.NSizeBWP*12*reshape(symbols',1,[]),1,[]);

                info=struct();
                info.BwpIdx=bwpIdx;
                info.BwpConfig=bwp;
                info.NSlot=slots;
                info.Indices=Indices;
                csetInfo=[csetInfo,info];%#ok<AGROW>

            end

        end

    end
end





function[chinfo,msg]=getPXSCHIndices(wgc,resSSB,resPDCCH,reservedRE,msg)

    import nr5g.internal.wavegen.*;




    wid='nr5g:nrPXSCH:DMRSParametersNoSymbols';
    w=warning('query',wid);
    cleanup=onCleanup(@()warning(w.state,wid));
    warning('off',wid);

    nCellID=wgc.NCellID;
    numSubframes=wgc.NumSubframes;
    carriers=wgc.SCSCarriers;
    bwps=wgc.BandwidthParts;
    isDownlink=isa(wgc,"nrDLCarrierConfig");

    if isDownlink
        pxschs=wgc.PDSCH;
        coresets=wgc.CORESET;
        searchSpaces=wgc.SearchSpaces;
        chName='PDSCH';
    else
        pxschs=wgc.PUSCH;
        chName='PUSCH';
    end

    numPXSCH=numel(pxschs);
    chinfo=unitInfoStruct(pxschs,numPXSCH);
    for nch=1:numPXSCH


        if~pxschs{nch}.Enable
            continue;
        end


        ch=pxschs{nch};


        [bwp,bwpIdx]=getBWPByID(bwps,ch.BandwidthPartID);
        [carrierwg,cidx]=getSCSCarrierFromBWP(carriers,bwp);


        validatePRBSet(bwp,ch,nch);
        msg=validateSymbolAllocation(msg,bwp,ch,nch);


        allocatedSlots=getSlotAllocation(bwp,ch,numSubframes);


        carrier=getCarrierCfgObject(bwp,nCellID);

        if isDownlink
            pdsch=getPXSCHObject(ch,carrier.SymbolsPerSlot,ch.ReservedPRB,[],isDownlink);


            resCSET=getReservedCORESETPRB(bwp,ch,nch,coresets,searchSpaces,numSubframes);



            pdsch.ReservedPRB=[resSSB(bwpIdx),resPDCCH{nch},resCSET,pdsch.ReservedPRB];


            [channelInd,dmrsInd,ptrsInd]=getSinglePXSCHIndices(carrier,pdsch,reservedRE(nch,:),allocatedSlots);
        else
            pusch=getPXSCHObject(ch,carrier.SymbolsPerSlot,{},[],isDownlink);


            [channelInd,dmrsInd,ptrsInd]=getSinglePXSCHIndices(carrier,pusch,[],allocatedSlots);
        end


        chinfo(nch).Name=[chName,num2str(nch)];
        if~isempty(channelInd)
            chinfo(nch).Resources=struct('NSlot',num2cell(allocatedSlots),...
            'ChannelIndices',channelInd,...
            'DMRSIndices',dmrsInd,...
            'PTRSIndices',ptrsInd);



            if~isempty(channelInd{1})&&isempty(dmrsInd{1})
                msg=getString(message(wid,chName));
            end
        end


    end

end



function[channelIndices,dmrsIndices,ptrsIndices]=getSinglePXSCHIndices(carrier,pxsch,reservedREs,allocatedSlots)

    import nr5g.internal.wavegen.*;

    anyReserveRE=~isempty(reservedREs);
    numSlots=length(allocatedSlots);

    channelIndices=repmat({uint32(zeros(0,1))},1,numSlots);
    dmrsIndices=repmat({uint32(zeros(0,1))},1,numSlots);
    ptrsIndices=repmat({uint32(zeros(0,1))},1,numSlots);

    for slotIdx=1:numSlots
        slot=allocatedSlots(slotIdx);
        carrier.NSlot=slot;

        if anyReserveRE

            pxsch.ReservedRE=reservedREs{slot+1};
        end


        [chInd,dmrsInd,~,ptrsInd]=PXSCHResources(carrier,pxsch);


        channelIndices{slotIdx}=uint32(chInd);
        dmrsIndices{slotIdx}=uint32(dmrsInd);
        ptrsIndices{slotIdx}=uint32(ptrsInd);

    end

end


function reservedPRB=getReservedCORESETPRB(bwp,pdsch,nch,coresets,searchSpaces,numSubframes)

    import nr5g.internal.wavegen.*;



    csetIdList=getSinglePropValuesFromCellWithObjects(coresets,'CORESETID','double');
    reservedPRB={};
    for csetID=pdsch.ReservedCORESET





        cs=coresets{csetIdList==csetID};
        for idx=1:length(searchSpaces)
            if cs.CORESETID~=searchSpaces{idx}.CORESETID
                continue;
            end
            searchSpace=searchSpaces{idx};


            rmallocatedsymbols=getCORESETSymbols(numSubframes,bwp,cs,searchSpace);


            allocatedPRB=nr5g.internal.pdcch.getCORESETPRB(cs,bwp.NStartBWP);


            coder.internal.errorIf(max(allocatedPRB)>=bwp.NSizeBWP,...
            'nr5g:nrWaveformGenerator:InvalidReservedCORESETInBWP',nch,cs.CORESETID,max(allocatedPRB),bwp.NSizeBWP,pdsch.BandwidthPartID);


            thisRsv=nrPDSCHReservedConfig;
            thisRsv.PRBSet=allocatedPRB;
            thisRsv.SymbolSet=rmallocatedsymbols(:);
            thisRsv.Period=[];
            reservedPRB{end+1}=thisRsv;%#ok<AGROW>
        end
    end

end





function[chinfo,msg]=getPUCCHIndices(nCellID,numSubframes,bwps,pucchs,msg)

    import nr5g.internal.wavegen.*;

    numPUCCH=numel(pucchs);
    chinfo=unitInfoStruct(pucchs,numPUCCH);
    for nch=1:numPUCCH


        ch=pucchs{nch};
        [bwp,bwpIdx]=getBWPByID(bwps,ch.BandwidthPartID);


        if~ch.Enable||isempty(ch.PRBSet)||isempty(ch.SlotAllocation)||...
            isempty(ch.SymbolAllocation)||ch.SymbolAllocation(2)==0
            continue;
        end


        validatePRBSet(bwp,ch,nch);
        msg=validateSymbolAllocation(msg,bwp,ch,nch);



        slots=getSlotAllocation(bwp,ch,numSubframes);


        carrier=getCarrierCfgObject(bwp,nCellID);


        formatPUCCH=str2double(erase(class(ch),{'nrWavegenPUCCH','Config'}));
        symPerSlot=symbolsPerSlot(bwp);
        pucch=getPUCCHObject(ch,formatPUCCH,symPerSlot,nch);


        [channelInd,dmrsInd]=getSinglePUCCHIndices(carrier,pucch,slots);


        chinfo(nch).Name=['PUCCH',num2str(nch)];
        if~isempty(channelInd)
            chinfo(nch).Resources=struct('NSlot',num2cell(slots),...
            'ChannelIndices',channelInd,...
            'DMRSIndices',dmrsInd);
        end


    end

end



function[channelIndices,dmrsIndices]=getSinglePUCCHIndices(carrier,pucch,allocatedSlots)


    numAllocSlots=length(allocatedSlots);
    channelIndices=repmat({uint32(zeros(0,1))},1,numAllocSlots);
    dmrsIndices=repmat({uint32(zeros(0,1))},1,numAllocSlots);
    for slotIdx=1:numAllocSlots
        slot=allocatedSlots(slotIdx);
        carrier.NSlot=slot;


        pucchInd=nrPUCCHIndices(carrier,pucch);
        dmrsInd=nrPUCCHDMRSIndices(carrier,pucch);


        channelIndices{slotIdx}=pucchInd;
        dmrsIndices{slotIdx}=dmrsInd;
    end

end





function chinfo=getSRSIndices(nCellID,numSubframes,bwps,srss)

    import nr5g.internal.wavegen.*;

    numSRS=numel(srss);
    chinfo=unitInfoStruct(srss,numSRS);
    for nsig=1:numSRS


        sig=srss{nsig};

        if~sig.Enable
            continue;
        end

        [bwp,bwpIdx]=getBWPByID(bwps,sig.BandwidthPartID);



        allocatedSlots=getSlotAllocation(bwp,sig,numSubframes);


        srs=getSRSObject(sig);


        carrier=getCarrierCfgObject(bwp,nCellID);

        numAllocSlots=length(allocatedSlots);
        indices=repmat({uint32(zeros(0,1))},1,numAllocSlots);
        for slotIdx=1:numAllocSlots

            slot=allocatedSlots(slotIdx);
            carrier.NSlot=slot;

            if isempty(sig.Period)
                srsIdx=1;
            else
                srsIdx=find(mod(slot,sig.Period)==sig.SlotAllocation,1);
            end


            indices{slotIdx}=nrSRSIndices(carrier,srs{srsIdx});

        end


        chinfo(nsig).Name=['SRS',num2str(nsig)];
        if~isempty(indices)
            chinfo(nsig).Resources=struct('NSlot',num2cell(allocatedSlots),...
            'SignalIndices',indices);
        end

    end

end


function slots=getSlotAllocation(bwp,ch,numSubframes)

    if isa(ch,'nrWavegenCSIRSConfig')


        [Trs,Toff]=nr5g.internal.getRSPeriodicityAndOffset(ch.CSIRSPeriod);
        numSlots=numSubframes*bwp.SubcarrierSpacing/15;
        slots=Toff:Trs:(numSlots-1);

    else



        slots=nr5g.internal.wavegen.expandbyperiod(ch.SlotAllocation,ch.Period,numSubframes,bwp.SubcarrierSpacing);

    end

end

function validatePRBSet(bwp,ch,nch)
    coder.internal.errorIf(any(ch.PRBSet>=bwp.NSizeBWP,'all'),...
    'nr5g:nrWaveformGenerator:InvalidPRBSetInBWP',max(ch.PRBSet,[],'all'),'PDSCH',nch,bwp.NSizeBWP,ch.BandwidthPartID);
end

function msg=validateSymbolAllocation(msg,bwp,ch,nch)


    symbperslot=nr5g.internal.wavegen.symbolsPerSlot(bwp);
    allocSymbs=ch.SymbolAllocation(1):(ch.SymbolAllocation(1)+ch.SymbolAllocation(2)-1);
    slotsymbs=allocSymbs(allocSymbs<symbperslot);
    if length(slotsymbs)~=length(allocSymbs)
        chtype=erase(erase(class(ch),{'nr','Wavegen','Config'}),digitsPattern);
        msg=getString(message('nr5g:nrWaveformGenerator:InvalidSymbolAllocation',chtype,nch,ch.BandwidthPartID,symbperslot-1));
    end

end


function[carrier,idx]=getSCSCarrierFromBWP(carriers,bwp)

    carriers=[carriers{:}];
    bwpscs=bwp.SubcarrierSpacing;
    idx=find([carriers(:).SubcarrierSpacing]==bwpscs);
    carrier=carriers(idx);

end


function[bwp,bwpIdx]=getBWPByID(bwps,bwpID)

    bwps=[bwps{:}];
    bwpIdx=find([bwps(:).BandwidthPartID]==bwpID);
    bwp=bwps(bwpIdx);

end



function[channelGrids,csetGrids]=markBWPGrids(wgc,waveRes,csetInfo)

    import nr5g.internal.wavegen.*;

    numSubframes=wgc.NumSubframes;
    bwps=wgc.BandwidthParts;


    [channelGrids,csetGrids]=createEmptyBWPGrids(bwps,numSubframes);


    chplevel=wirelessWaveformGenerator.internal.channelPowerLevelsMap();


    bwpLevel=chplevel("BWP");
    for bp=1:length(channelGrids)
        channelGrids{bp}(channelGrids{bp}==0)=bwpLevel;
    end



    [waveRes,channelNames,channelIdx]=flattenWaveResources(waveRes);
    for c=1:length(waveRes)

        chName=channelNames{c};
        nch=channelIdx(c);
        channels=wgc.(chName);

        if isempty(channels)||~channels{nch}.Enable
            continue;
        end
        ch=channels{nch};


        [bwp,bwpIdx]=getBWPByID(bwps,ch.BandwidthPartID);
        symPerSlot=symbolsPerSlot(bwp);
        numSymbols=numSubframes*symPerSlot*bwp.SubcarrierSpacing/15;


        powLevel=chplevel(chName);


        resources=waveRes{c}.Resources;
        for s=1:length(resources)

            nslot=double(resources(s).NSlot);



            indices=getResourceIndices(resources(s));
            rblind=ceil(double(indices)/12);
            [k,l,~]=ind2sub([bwp.NSizeBWP,symPerSlot],rblind);
            l=l+nslot*symPerSlot;
            rblind=sub2ind([bwp.NSizeBWP,numSymbols],k,l);


            channelGrids{bwpIdx}(rblind)=powLevel;

        end

    end


    csetPowerLevel=chplevel("nrCORESETConfig");
    for c=1:length(csetInfo)



        bwpIdx=csetInfo(c).BwpIdx;
        bwp=csetInfo(c).BwpConfig;
        symPerSlot=symbolsPerSlot(bwp);
        numSymbols=numSubframes*symPerSlot*bwp.SubcarrierSpacing/15;


        m=round(max(csetGrids{bwpIdx}(:))/csetPowerLevel)+1;


        csetind=csetInfo(c).Indices;
        rblind=ceil(double(csetind)/12);
        [k,l]=ind2sub([bwp.NSizeBWP,symPerSlot],rblind);



        slots=csetInfo(c).NSlot;
        for s=1:length(slots)

            nslot=slots(s);


            ls=l+nslot*symPerSlot;
            rblind=sub2ind([bwp.NSizeBWP,numSymbols],k,ls);






            csetGrids{bwpIdx}(rblind)=csetGrids{bwpIdx}(rblind)+(m*csetPowerLevel);

        end

    end

end


function[channelGrids,csetGrids]=createEmptyBWPGrids(bwps,numSubframes)

    import nr5g.internal.wavegen.*;

    numBWPs=numel(bwps);
    channelGrids=cell(1,numBWPs);
    csetGrids=cell(1,numBWPs);
    for idx=1:numBWPs
        bwp=bwps{idx};
        symPerSlot=symbolsPerSlot(bwp);
        mu=fix(bwp.SubcarrierSpacing/15);
        channelGrids{idx}=zeros(bwp.NSizeBWP,numSubframes*symPerSlot*mu);
        csetGrids{idx}=zeros(bwp.NSizeBWP,numSubframes*symPerSlot*mu);
    end

end



function[fWaveRes,chNames,chIdx]=flattenWaveResources(waveResources)

    fnames=fieldnames(waveResources);
    fWaveRes={};
    chNames={};
    chIdx=zeros(1,0);
    numChTypes=numel(fnames);
    for f=1:numChTypes
        chRes=num2cell(waveResources.(fnames{f}));
        fWaveRes=[fWaveRes,chRes];%#ok<AGROW>
        numChs=length(chRes);
        chNames=[chNames,repmat(fnames(f),1,numChs)];%#ok<AGROW>
        chIdx=[chIdx,1:numChs];%#ok<AGROW>
    end

end


function Indices=getResourceIndices(resource)

    fnames=fieldnames(resource)';
    indFieldNames=fnames(contains(fnames,'Indices'));

    Indices=[];
    for fn=indFieldNames
        Indices=[Indices;resource.(fn{1})(:)];%#ok<AGROW> 
    end

end


function out=unitInfoStruct(ch,n)

    out=struct('Name',[],'Resources',[]);
    if isempty(ch)
        out=repmat(out,1,0);
        return;
    end

    ch=ch{1};
    isSignal=any(cellfun(@(x)isa(ch,x),{'nrWavegenCSIRSConfig','nrWavegenSRSConfig'}));


    fnames={'NSlot'};
    if isSignal
        fnames=[fnames,'SignalIndices'];
    else
        fnames=[fnames,'ChannelIndices'];
        if~isa(ch,'nrWavegenPUCCH0Config')
            fnames=[fnames,'DMRSIndices'];
        end
        if any(cellfun(@(x)isa(ch,x),{'nrWavegenPDSCHConfig','nrWavegenPUSCHConfig'}))
            fnames=[fnames,'PTRSIndices'];
        end
    end


    out.Name='';
    for f=1:length(fnames)
        out.Resources.(fnames{f})=uint32(zeros(0,1));
    end

    out=repmat(out,1,n);

end