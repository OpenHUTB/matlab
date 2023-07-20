function plotDLResourceGrid(ax,waveconfig,gridset,bpIndex)





    [chplevelmap,cscaling,cmap]=wirelessWaveformGenerator.internal.channelPowerLevelsMap();
    channelNames=["PDCCH","PDSCH","CORESET","SS_Burst","CSIRS"];
    for cn=channelNames
        chplevel.(cn)=chplevelmap(cn);
    end


    bwp=waveconfig.BandwidthParts{bpIndex};
    bpID=bwp.BandwidthPartID;
    carriers=waveconfig.SCSCarriers;
    carrierID=nr5g.internal.wavegen.getCarrierIDByBWPIndex(carriers,waveconfig.BandwidthParts,bpIndex);
    carrier=carriers{carrierID};


    bgrid=gridset(bpIndex).ResourceGridPRB;
    cgrid=zeros(carrier.NSizeGrid,size(bgrid,2));
    cgrid(bwp.NStartBWP-carrier.NStartGrid+...
    (1:size(bgrid,1)),:)=bgrid;


    bcrstgrid=gridset(bpIndex).CORESETGridPRB;
    crstgrid=zeros(carrier.NSizeGrid,size(bcrstgrid,2));
    crstgrid(waveconfig.BandwidthParts{bpIndex}.NStartBWP-carrier.NStartGrid+...
    (1:size(bcrstgrid,1)),:)=bcrstgrid;



    ssburst=nr5g.internal.wavegen.mapSSBObj2Struct(waveconfig.SSBurst,carriers);
    [~,ssbreserved]=nr5g.internal.wavegen.ssburstResources(ssburst,carriers,waveconfig.BandwidthParts);
    thisRsv=ssbreserved{bpIndex};
    if~isempty(thisRsv)
        symbperslot=nr5g.internal.wavegen.symbolsPerSlot(bwp);
        nsymbolsperhalfframe=thisRsv.Period*symbperslot;
        symbols=nr5g.internal.wavegen.expandbyperiod(thisRsv.SymbolSet,nsymbolsperhalfframe,size(cgrid,2));
        cgrid(thisRsv.PRBSet+1,symbols+1)=chplevel.SS_Burst;
    end




    tag='wirelessWaveformGenerator.internal.plotResourceGrid';
    img=findobj(ax,'Type','Image','Tag',tag);
    if isempty(img)
        img=image(ax,cscaling*cgrid,'Tag',tag);
    else
        img.CData=cscaling*cgrid;
    end
    maxX=size(cgrid,2)-1;
    maxY=size(cgrid,1)-1;
    img.XData=0:maxX;
    img.YData=0:maxY;
    axis(ax,'xy');
    if ax.XLim(2)~=(maxX+0.5)||ax.YLim(2)~=(maxY+0.5)

        ax.CameraUpVectorMode='manual';
        axis(ax,[-0.5,maxX+0.5,-0.5,maxY+0.5]);


        NSlots=bwp.SubcarrierSpacing/15*waveconfig.NumSubframes;


        slotFactor=ceil(NSlots/10);


        ax.XAxis.TickValues=-0.5:symbperslot*slotFactor:(maxX+0.5);
        ax.XAxis.TickLabels=(ax.XAxis.TickValues+0.5)/symbperslot;
    end

    title(ax,getString(message('nr5g:waveformGeneratorApp:RBGridTitle',bpID,bwp.SubcarrierSpacing)));
    leg=findobj(ax.Parent,'Tag','gridLegend');
    if isempty(leg)||~contains('CSI-RS',leg.String)

        xlabel(ax,getString(message('nr5g:waveformGeneratorApp:RBGridXLabel')));
        ylabel(ax,getString(message('nr5g:waveformGeneratorApp:RBGridYLabel')));
        colormap(ax,cmap);


        fnames=strrep(fieldnames(chplevel),'_',' ');
        fnames=strrep(fnames,'CSIRS','CSI-RS');
        chpval=struct2cell(chplevel);
        clevels=floor(cscaling*[chpval{:}]);
        N=length(clevels);
        p=struct('Marker','s','LineStyle','none','MarkerSize',8,'LineWidth',1.25);
        L=line(ax,NaN(N),NaN(N),p);

        c=mat2cell(cmap(clevels,:),ones(1,N),3);
        set(L,{'color'},c);
        set(L,{'MarkerFaceColor'},c);

        legend(ax,fnames{:},'AutoUpdate','off','Location','NorthEast','Tag','gridLegend');

        isCORESET=strcmpi(fnames,'CORESET');
        set(L(isCORESET),'MarkerFaceColor','None');
    end


    crstgrid=round(crstgrid/chplevel.CORESET);
    c=cmap(floor(cscaling*chplevel.CORESET),:);
    maxm=max(crstgrid(:));
    for i=0:maxm


        tag='wirelessWaveformGenerator.internal.plotBoundingBoxes';
        if(i==0)
            tagged=findobj(ax.Children,'Tag',tag);
            delete(tagged);
        else
            wirelessWaveformGenerator.internal.plotBoundingBoxes(ax,crstgrid==i,c);
        end
    end

end