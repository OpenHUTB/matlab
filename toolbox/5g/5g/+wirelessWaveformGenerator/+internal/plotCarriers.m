function plotCarriers(ax,waveconfig)





    blue=[0,0.447,0.741];
    red=[0.850,0.325,0.098];
    orange=[0.929,0.694,0.125];
    green=[0.466,0.674,0.188];

    cla(ax);
    delete(findobj(ax.Parent,'type','legend'))

    hold(ax,'on');

    if isa(waveconfig,'nrDLCarrierConfig')||isa(waveconfig,'nrULCarrierConfig')
        carriers=waveconfig.SCSCarriers;
        carrierSCS=cellfun(@(x)x.SubcarrierSpacing,carriers);
        [carrierSCS,ix]=sort(carrierSCS);
        carriers=carriers(ix);
        nrb=cellfun(@(x)x.NSizeGrid,carriers);
        bwpscs=cellfun(@(x)x.SubcarrierSpacing,waveconfig.BandwidthParts);
    else
        carriers=waveconfig.Carriers;
        carrierSCS=[carriers.SubcarrierSpacing];
        [carrierSCS,ix]=sort(carrierSCS);
        carriers=carriers(ix);
        nrb=[carriers.NRB];
        bwpscs=[waveconfig.BWP.SubcarrierSpacing];
    end
    bwpscs=unique(bwpscs);

    if isfield(waveconfig,'ChannelBandwidth')||isprop(waveconfig,'ChannelBandwidth')
        cbw=waveconfig.ChannelBandwidth;
    else
        cbw=[];
    end

    idx=ismember(bwpscs,carrierSCS);
    bwpscs=bwpscs(idx);
    nrb=nrb(idx);
    if isempty(bwpscs)
        title(ax,"");
        msg=getString(message('nr5g:waveformGeneratorApp:NoBWPAssociatedWithSCSCarrier'));
        text(ax,0,1,msg,"HorizontalAlignment","center")
        return;
    end

    cbwString=num2str(cbw);
    scsString=mat2str(bwpscs);
    nrbString=mat2str(nrb);
    title(ax,getString(message('nr5g:waveformGeneratorApp:ChannelViewTitle',cbwString,nrbString,scsString)));
    xlabel(ax,getString(message('nr5g:waveformGeneratorApp:ChannelViewXLabel')));


    k0c=nr5g.internal.wavegen.getFrequencyOffsetk0(carriers);

    xlim_upper=0;
    numBWP=numel(bwpscs);
    for i=1:numBWP


        cidx=carrierSCS==bwpscs(i);
        k0=k0c(cidx);
        if isa(waveconfig,'nrDLCarrierConfig')||isa(waveconfig,'nrULCarrierConfig')
            NSizeGrid=carriers{cidx}.NSizeGrid;
            NStartGrid=carriers{cidx}.NStartGrid;
        else
            NSizeGrid=carriers(cidx).NRB;
            NStartGrid=carriers(cidx).RBStart;
        end
        scs=bwpscs(i);

        if(~isempty(cbw)&&(isfield(waveconfig,'FrequencyRange')||isprop(waveconfig,'FrequencyRange')))
            guardband=nr5g.internal.wavegen.getGuardband(waveconfig.FrequencyRange,cbw,scs);
        else
            guardband=[];
        end

        scs=scs/1e3;

        ypos=numBWP-i;

        for rb=0:(NSizeGrid-1)

            f=((rb*12)+k0-(NSizeGrid*12/2))*scs;
            r=rectangle(ax,'Position',[f,ypos,12*scs,1]);
            r.FaceColor=orange;

            if(rb==0)
                point_a=f-(NStartGrid*12*scs);
            end
            if(rb==(NSizeGrid-1))
                xlim_upper=max(xlim_upper,f+12*scs);
            end

        end

        if(~isempty(guardband))
            p_guardband=plot(ax,ones(1,2)*(-cbw/2+guardband),ypos+[0,1],'Color',red,'LineWidth',2);
            plot(ax,ones(1,2)*(cbw/2-guardband),ypos+[0,1],'Color',red,'LineWidth',2);
        end


        p_point_a=plot(ax,ones(1,2)*point_a,ypos+[-0.2,1.2],'-..','Color',green,'LineWidth',2);

        p_k0=plot(ax,ones(1,2)*k0*scs,ypos+[0.1,0.9],'Color',blue,'LineWidth',2);

    end
    ylimits=[-0.5,length(bwpscs)+1.5];
    p_f0=plot(ax,zeros(1,2),ylimits,'k:');

    xlim_lower=point_a;
    if(~isempty(cbw))
        p_channel=plot(ax,[-cbw/2,-cbw/2],ylimits,'k--');
        plot(ax,[cbw/2,cbw/2],ylimits,'k--');
        xlim_lower=min(xlim_lower,-cbw/2);
        xlim_upper=max(xlim_upper,cbw/2);
    end
    span=xlim_upper-xlim_lower;
    ax.XLim=[xlim_lower-(span*0.05),xlim_upper+(span*0.05)];
    ax.YLim=ylimits;
    ax.YTick=[];

    p=[];
    legends={};
    if(~isempty(cbw))
        p=[p,p_channel];
        legends=[legends,getString(message('nr5g:waveformGeneratorApp:ChannelViewLegendChannelEdges'))];
    end
    if(~isempty(guardband))
        p=[p,p_guardband];
        legends=[legends,getString(message('nr5g:waveformGeneratorApp:ChannelViewLegendGuardbandEdges'))];
    end
    p=[p,p_point_a,p_k0,p_f0];
    legends=[legends,getString(message('nr5g:waveformGeneratorApp:ChannelViewLegendPointA')),'k_0','f_0'];
    legend(ax,p,legends);

end