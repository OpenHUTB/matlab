function plotULResourceGrid(ax,waveconfig,gridset,bpIndex)





    [chplevelmap,cscaling,cmap]=wirelessWaveformGenerator.internal.channelPowerLevelsMap();
    channelNames=["PUCCH","PUSCH","SRS"];
    for cn=channelNames
        chplevel.(cn)=chplevelmap(cn);
    end


    bwp=waveconfig.BandwidthParts{bpIndex};
    bpID=bwp.BandwidthPartID;
    carriers=waveconfig.SCSCarriers;
    carrierID=nr5g.internal.wavegen.getCarrierIDByBWPIndex(carriers,waveconfig.BandwidthParts,bpIndex);
    carrier=carriers{carrierID};

    symbperslot=nr5g.internal.wavegen.symbolsPerSlot(bwp);
    bwpOffset=bwp.NStartBWP-carrier.NStartGrid;
    bwpSCS=bwp.SubcarrierSpacing;
    carrierNRB=carrier.NSizeGrid;


    bgrid=gridset(bpIndex).ResourceGridPRB;
    cgrid=zeros(carrierNRB,size(bgrid,2));
    cgrid(bwpOffset+(1:size(bgrid,1)),:)=bgrid;




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

    title(ax,getString(message('nr5g:waveformGeneratorApp:RBGridTitle',bpID,bwpSCS)));
    leg=findobj(ax.Parent,'Tag','gridLegend');
    downlinkPlot=~isempty(leg)&&contains('CORESET',leg.String);
    if downlinkPlot

        tag='wirelessWaveformGenerator.internal.plotBoundingBoxes';
        tagged=findobj(ax.Children,'Tag',tag);
        delete(tagged);
    end
    if isempty(leg)||downlinkPlot
        xlabel(ax,getString(message('nr5g:waveformGeneratorApp:RBGridXLabel')));
        ylabel(ax,getString(message('nr5g:waveformGeneratorApp:RBGridYLabel')));
        colormap(ax,cmap);


        fnames=strrep(fieldnames(chplevel),'_',' ');
        chpval=struct2cell(chplevel);
        clevels=floor(cscaling*[chpval{:}]);
        N=length(clevels);
        L=line(ax,ones(N),ones(N),'LineWidth',8);

        c=mat2cell(cmap(clevels,:),ones(1,N),3);
        set(L,{'color'},c);
        set(L,{'MarkerFaceColor'},c);

        legend(ax,fnames{:},'AutoUpdate','off','Location','NorthEast','Tag','gridLegend');
    end

end
