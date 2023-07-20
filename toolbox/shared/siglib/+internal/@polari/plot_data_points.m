function plot_data_points(p)





    set(p.hDataPatch,...
    'HandleVisibility','off',...
    'Visible','off');


    hglow=p.hDataLineGlow;
    if~isempty(hglow)&&~ishghandle(hglow)
        hglow=[];
    end
    hline=p.hDataLine;
    if~isempty(hline)
        valid=ishghandle(hline);
        if any(~valid)

            delete(hline(valid));
            hline=[];
        end
    end
    if xor(isempty(hline),isempty(hglow))


        if~isempty(hglow)
            delete(hglow);
            hglow=[];
        else
            delete(hline);
            hline=[];
        end
    end



    pdata=getAllDatasets(p);
    Nd=numel(pdata);
    if Nd~=numel(hline)

        [Zplane,hline,hglow]=points_AddOrRemoveLinesAsNeeded(p,Nd);

    elseif Nd==0


        p.hDataLine=[];
        p.hDataLineGlow=[];
        Zplane=[];

    else





        Zplane=zeros(Nd,1);
        for i=1:Nd
            Zplane(i)=getappdata(hline(i),'polariZPlane');
        end
        set(hline,'HandleVisibility','on');
    end


    initColorIdx=p.ColorOrderIndex;


    markerIdx=1;
    if iscell(p.Marker)
        marker=p.Marker;
        markerN=numel(marker);
    else
        marker={p.Marker};
        markerN=1;
    end


    linestyleIdx=1;
    if iscell(p.LineStyle)
        lineStyle=p.LineStyle;
        linestyleN=numel(lineStyle);
    else
        lineStyle={p.LineStyle};
        linestyleN=1;
    end


    markerSiz=p.MarkerSize;
    markersizIdx=1;
    if isscalar(markerSiz)
        markersizN=numel(markerSiz);
    else
        markersizN=1;
    end


    lineWidth=p.LineWidth;
    linewidthIdx=1;
    if~isscalar(lineWidth)
        linewidthN=numel(lineWidth);
    else
        linewidthN=1;
    end

    for datasetIndex=1:Nd
        pdata_i=pdata(datasetIndex);

        r=getNormalizedMag(p,pdata_i.mag);
        th=getNormalizedAngle(p,pdata_i.ang);
        if p.ConnectEndpoints
            th=[th;th(1)];%#ok<AGROW>
            r=[r;r(1)];%#ok<AGROW>
        end

        if p.DisconnectAngleGaps
            [th,r]=insertValueAtGaps(NaN,th,r);
        end



        r(r<=0)=eps;
        x=r.*cos(th);
        y=r.*sin(th);
        z=Zplane(datasetIndex).*ones(size(x));

        set(hline(datasetIndex),...
        'XData',x,...
        'YData',y,...
        'ZData',z,...
        'Color',getPointsNextPlotColor(p),...
        'Marker',marker{markerIdx},...
        'MarkerSize',markerSiz(markersizIdx),...
        'LineStyle',lineStyle{linestyleIdx},...
        'LineWidth',lineWidth(linewidthIdx),...
        'Visible','on');


        markerIdx=1+rem(markerIdx,markerN);
        markersizIdx=1+rem(markersizIdx,markersizN);
        linewidthIdx=1+rem(linewidthIdx,linewidthN);
        linestyleIdx=1+rem(linestyleIdx,linestyleN);
    end


    if numel(p.LineWidth)==1
        LineWidth=p.LineWidth*ones(1,Nd);
    else
        LineWidth=[p.LineWidth,ones(1,Nd-numel(p.LineWidth))];
    end
    hglow.LineWidth=7+2*(LineWidth(p.ActiveDataset)-1);


    p.ColorOrderIndex=initColorIdx;



