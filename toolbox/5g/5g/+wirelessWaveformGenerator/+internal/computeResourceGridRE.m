function[reGrid,msg]=computeResourceGridRE(waveconfig,channel,selectedRow,chplevel)
    wid='nr5g:nrPXSCH:DMRSParametersNoSymbols';
    w=warning('query',wid);
    cleanup=onCleanup(@()warning(w.state,wid));
    warning('off',wid);

    msg='';

    channelName=channel(isletter(channel));
    ch=waveconfig.(channelName){selectedRow};
    bpIndex=ch.BandwidthPartID;
    carriers=waveconfig.SCSCarriers;
    bwp=waveconfig.BandwidthParts;
    if contains(channelName,'CSIRS')
        carrierIndex=nr5g.internal.wavegen.getCarrierIDByBWPID(carriers,bwp,ch.BandwidthPartID);
        carrier=nr5g.internal.wavegen.getCarrierCfgObject(carriers{carrierIndex},waveconfig.NCellID,bwp{bpIndex}.CyclicPrefix);
    else
        carrier=nr5g.internal.wavegen.getCarrierCfgObject(bwp{bpIndex},waveconfig.NCellID);
    end


    symbperslot=12+2*strcmpi(bwp{bpIndex}.CyclicPrefix,'normal');
    reGrid=zeros(12,symbperslot);


    try
        if contains(channelName,{'PDSCH','PUSCH'})&&ch.Enable&&~isempty(ch.PRBSet)&&~isempty(ch.SlotAllocation)&&~isempty(ch.SymbolAllocation)&&ch.SymbolAllocation(2)>0

            if contains(channelName,'PD')
                isDownlink=true;
                indFcn=@nrPDSCHIndices;
                dmrsFcn=@nrPDSCHDMRSIndices;
                ptrsFcn=@nrPDSCHPTRSIndices;
            else
                isDownlink=false;
                indFcn=@nrPUSCHIndices;
                dmrsFcn=@nrPUSCHDMRSIndices;
                ptrsFcn=@nrPUSCHPTRSIndices;
            end


            pxsch=nr5g.internal.wavegen.getPXSCHObject(ch,carrier.SymbolsPerSlot,{},[],isDownlink);
            pxsch.PRBSet=0;


            indices=indFcn(carrier,pxsch,"IndexStyle","subscript");
            dmrsIndices=dmrsFcn(carrier,pxsch,"IndexStyle","subscript");
            ptrsIndices=ptrsFcn(carrier,pxsch,"IndexStyle","subscript");
            if~isempty(indices)&&isempty(dmrsIndices)
                msg=getString(message(wid,channelName));
            end


            reGrid=populateREGrid(reGrid,indices,chplevel.(channelName));
            reGrid=populateREGrid(reGrid,dmrsIndices,chplevel.([channelName,'_DMRS']));
            reGrid=populateREGrid(reGrid,ptrsIndices,chplevel.([channelName,'_PTRS']));

        elseif contains(channelName,'PDCCH')&&ch.Enable&&~isempty(ch.SlotAllocation)


            pdcch=nr5g.internal.wavegen.getPDCCHObject(ch,bwp{bpIndex},waveconfig.CORESET,waveconfig.SearchSpaces,0);
            pdcch.SearchSpace.SlotPeriodAndOffset(2)=0;


            [indices,~,dmrsIndices]=nrPDCCHResources(carrier,pdcch,"IndexStyle","subscript");


            reGrid=populateREGrid(reGrid,indices,chplevel.PDCCH);
            reGrid=populateREGrid(reGrid,dmrsIndices,chplevel.PDCCH_DMRS);

        elseif contains(channelName,'PUCCH')&&ch.Enable&&~isempty(ch.PRBSet)&&~isempty(ch.SlotAllocation)&&...
            ~isempty(ch.SymbolAllocation)&&ch.SymbolAllocation(2)>0


            c=class(ch);
            formatPUCCH=str2double(extract(c,digitsPattern));
            pucch=nr5g.internal.wavegen.getPUCCHObject(ch,formatPUCCH,carrier.SymbolsPerSlot,selectedRow);
            pucch.PRBSet=0;


            indices=nrPUCCHIndices(carrier,pucch,"IndexStyle","subscript");
            dmrsIndices=nrPUCCHDMRSIndices(carrier,pucch,"IndexStyle","subscript");


            reGrid=populateREGrid(reGrid,indices,chplevel.PUCCH);
            reGrid=populateREGrid(reGrid,dmrsIndices,chplevel.PUCCH_DMRS);

        elseif contains(channelName,'CSIRS')&&ch.Enable


            csirs=nr5g.internal.wavegen.getCSIRSObject(ch);
            if isnumeric(csirs.CSIRSPeriod)
                csirs.CSIRSPeriod='on';
            end


            indices=nrCSIRSIndices(carrier,csirs,"IndexStyle","subscript");
            indices(indices(:,3)>1,:)=[];


            nreBWP=bwp{bpIndex}.NSizeBWP*12;
            bwpRBOffset=bwp{bpIndex}.NStartBWP-carrier.NStartGrid;
            offsetSubc=indices(:,1)-bwpRBOffset*12;
            bwpIndices=[offsetSubc,indices(:,2),indices(:,3)];
            ind2rmv=bwpIndices(:,1)<=0|bwpIndices(:,1)>nreBWP;
            bwpIndices(ind2rmv,:)=[];


            reGrid=populateREGrid(reGrid,bwpIndices,chplevel.CSIRS);

        elseif contains(channelName,'SRS')&&ch.Enable&&~isempty(ch.SlotAllocation)


            ch.SlotAllocation=0;
            srs=nr5g.internal.wavegen.getSRSObject(ch);


            indices=nrSRSIndices(carrier,srs{1},"IndexStyle","subscript");


            reGrid=populateREGrid(reGrid,indices,chplevel.SRS);
        end
    catch ME
        msg=ME.message;
    end

end

function grid=populateREGrid(grid,ind,chplevel)

    if~isempty(ind)
        ind=double(ind);
        rbNum=floor((ind(1)-1)/12);
        ind(:,1)=ind(:,1)-rbNum*12;
        ind((ind(:,1)>12|ind(:,1)<1),:)=[];
        ind=sub2ind(size(grid),ind(:,1),ind(:,2));
        grid(ind)=chplevel;
    end
end
