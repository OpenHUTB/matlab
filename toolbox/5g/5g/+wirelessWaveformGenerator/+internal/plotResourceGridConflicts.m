






function plotResourceGridConflicts(ax,cfgObj,conflicts,bpIndex,conflictColor)


    bwps=cfgObj.BandwidthParts;
    carriers=cfgObj.SCSCarriers;
    bwp=bwps{bpIndex};
    carrierID=nr5g.internal.wavegen.getCarrierIDByBWPIndex(carriers,bwps,bpIndex);
    carrier=carriers{carrierID};
    symbPerSlot=nr5g.internal.wavegen.symbolsPerSlot(bwp);
    numSubframes=cfgObj.NumSubframes;


    cgridSize=[carrier.NSizeGrid,numSubframes*symbPerSlot*fix(bwp.SubcarrierSpacing/15)];

    tag='wirelessWaveformGenerator.internal.plotResourceGridConflicts';
    imgCfl=findobj(ax,'Type','Image','Tag',tag);
    if isempty(imgCfl)
        hold(ax,'on')
        imgCfl=image(ax,[],'Tag',tag);
        hold(ax,'off')
    else
        imgCfl.CData=[];
    end
    maxX=cgridSize(2)-1;
    maxY=cgridSize(1)-1;
    imgCfl.XData=0:maxX;
    imgCfl.YData=0:maxY;


    if~isempty(conflicts)

        bwpIdx=vertcat(conflicts.BwpIdx);
        conflicts=conflicts(any(bwpIdx==bpIndex,2));

        cflGrid=zeros(cgridSize);
        for c=1:length(conflicts)
            cfl=conflicts(c);



            gre=cfl.Grid{cfl.BwpIdx==bpIndex};
            gconv=conv2(gre,ones(12,1),'Valid');
            grb=(gconv(1:12:end,:)~=-0);



            cgrid=zeros(cgridSize);
            crb=bwp.NStartBWP-carrier.NStartGrid+(1:bwp.NSizeBWP);
            cgrid(crb,:)=grb;


            cidx=cgrid~=0;
            cflGrid(cidx)=cgrid(cidx);

        end


        if any(cflGrid,'all')
            col(1,1,1:3)=conflictColor;
            cdata=cflGrid.*col;

            imgCfl.CData=cdata;
            imgCfl.AlphaData=cflGrid*0.8;
        end

    end

end
