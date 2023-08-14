function plotResourceGridRE(src,~)







    obj=src.UserData.Obj;
    ax=src.UserData.Axes;
    waveconfig=src.UserData.Waveconfig;
    channel=src.UserData.Channel;
    selectedRow=src.UserData.SelectedRow;
    msg=src.UserData.Msg;


    reAx=findall(ax.Parent,'Tag','REAxes');



    if contains(channel,{'PDSCH','PDCCH','CSI-RS','PUSCH','PUCCH','SRS'})&&src.Value


        resGrid=subplot(1,2,1,ax);


        if isempty(reAx)
            reAx=subplot(1,2,2,'Parent',resGrid.Parent);
            reAx.Tag='REAxes';
        end


        uistack(src,'top');




        if isempty(msg)
            msg=updateREPlot(reAx,waveconfig,channel,selectedRow);
        end


        updateREMapVisibility(reAx,'on')

    else


        updateREMapVisibility(reAx,'off')



        subplot(1,1,1,ax);
        ax.OuterPosition=[0,0,1,1];
    end


    if~isempty(msg)


        warnInStatusBar(obj,msg);
    end


    src.UserData.Msg=msg;

end

function msg=updateREPlot(ax,waveconfig,channel,selectedRow)





    [powerLevelMap,cscaling,cmap]=wirelessWaveformGenerator.internal.channelPowerLevelsMap();
    if contains(channel,{'PDSCH','PUSCH'})
        channelName=channel(1:5);
        chplevel.(channelName)=powerLevelMap(channelName);
        chplevel.([channelName,'_DMRS'])=powerLevelMap([channelName,'_DMRS']);
        chplevel.([channelName,'_PTRS'])=powerLevelMap([channelName,'_PTRS']);
    elseif contains(channel,{'PDCCH','PUCCH'})
        channelName=channel(1:5);
        chplevel.(channelName)=powerLevelMap(channelName);
        chplevel.([channelName,'_DMRS'])=powerLevelMap([channelName,'_DMRS']);
    elseif contains(channel,'CSI')
        chplevel.CSIRS=powerLevelMap('CSIRS');
    elseif contains(channel,'SRS')
        chplevel.SRS=powerLevelMap('SRS');
    end


    [reGrid,msg]=wirelessWaveformGenerator.internal.computeResourceGridRE(waveconfig,channel,selectedRow,chplevel);


    img=findobj(ax,'Type','Image','Tag','REGrid');
    if isempty(img)
        img=image(ax,cscaling*reGrid);
        img.Tag='REGrid';
        ax.Tag='REAxes';
    else
        img.CData=cscaling*reGrid;
    end
    minX=0;
    maxX=size(reGrid,2)-1;
    minY=0;
    maxY=11;
    img.XData=minX:maxX;
    img.YData=minY:maxY;
    axis(ax,[minX-0.5,maxX+0.5,minY-0.5,maxY+0.5]);
    axis(ax,'xy');

    ax.XAxis.TickValues=minX-0.5:2:maxX+0.5;
    ax.XAxis.TickLabels=ax.XAxis.TickValues+0.5;
    ax.YAxis.TickValues=minY-0.5:2:maxY+0.5;
    ax.YAxis.TickLabels=ax.YAxis.TickValues+0.5;
    ax.Title.String=getString(message('nr5g:waveformGeneratorApp:REMapTitle',channel));
    if isempty(findobj(ax.Parent,'Type','Legend','-and','Tag','RELegend'))

        xlabel(ax,'Symbols');
        ylabel(ax,'Subcarrier');
        colormap(ax,cmap);
    end


    hiddenLines=findobj(ax.Children,'Type','Line');
    delete(hiddenLines);


    fnames=strrep(fieldnames(chplevel),'_',' ');
    rsidx=strfind(fnames,'RS');
    for idx=1:length(rsidx)
        if~isempty(rsidx{idx})&&~strcmpi(fnames{idx},'SRS')
            fnames{idx}=[fnames{idx}(1:rsidx{idx}-1),'-RS'];
        end
    end
    chpval=struct2cell(chplevel);
    clevels=floor(cscaling*[chpval{:}]);
    N=length(clevels);
    p=struct('Marker','s','LineStyle','none','MarkerSize',8,'LineWidth',1.25);
    L=line(ax,NaN(N),NaN(N),p);

    c=mat2cell(cmap(clevels,:),ones(1,N),3);
    set(L,{'color'},c);
    set(L,{'MarkerFaceColor'},c);

    legend(ax,fnames{:},'AutoUpdate','off','Tag','RELegend');
end

function updateREMapVisibility(reAx,flag)


    if~isempty(reAx)
        reLegend=findall(reAx.Parent,'Tag','RELegend');
        reAx.Visible=flag;
        [reAx.Children.Visible]=deal(flag);
        if~isempty(reLegend)
            reLegend.Visible=flag;
        end
    end
end