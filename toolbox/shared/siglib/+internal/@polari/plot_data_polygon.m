function plot_data_polygon(p)



    set(p.hDataLine,...
    'Visible','off',...
    'HandleVisibility','off');
    set(p.hDataLineGlow,'Visible','off');


    ht=p.hDataPatch;
    Nht=numel(ht);
    bogus=~ishghandle(ht);
    if Nht>0&&any(bogus)

        delete(ht(bogus));
        ht=ht(~bogus);
        Nht=numel(ht);
    end


    pdata=getAllDatasets(p);
    Nd=numel(pdata);

    if Nht~=Nd

        delete(ht);



        Zmin=0.1;
        Zmax=0.2;
        del=Zmax-Zmin;
        Zplane=Zmin+del*(0:Nd-1)'/Nd;

        for datasetIndex=1:Nd
            ht_i=patch(...
            'Parent',p.hAxes,...
            'Tag',sprintf('PolarData%d',p.pAxesIndex),...
            'EdgeAlpha',1.0,...
            'Visible','off');
            set(ht_i,'uicontextmenu',p.UIContextMenu_Data);
            setappdata(ht_i,'polariDatasetIndex',datasetIndex);
            setappdata(ht_i,'polariZPlane',Zplane(datasetIndex));

            b=hggetbehavior(ht_i,'DataCursor');
            b.UpdateFcn=@(h,e)figureDataCursorUpdateFcn(p,e);
            b=hggetbehavior(ht_i,'Plotedit');
            b.Enable=false;

            if datasetIndex==1
                ht=ht_i;
            else
                ht=[ht;ht_i];%#ok<AGROW>
            end
        end
        p.hDataPatch=ht;
    else





        Zplane=zeros(Nd,1);
        for i=1:Nd
            Zplane(i)=getappdata(ht(i),'polariZPlane');
            ht(i).HandleVisibility='on';
        end
    end


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
    if isscalar(lineWidth)
        linewidthN=numel(lineWidth);
    else
        linewidthN=1;
    end

    for datasetIndex=1:Nd
        pdata_i=pdata(datasetIndex);


        if datasetIndex==p.pCurrentDataSetIndex
            lineStyle_i=lineStyle{linestyleIdx};
        else
            lineStyle_i='none';
        end

        r=getNormalizedMag(p,pdata_i.mag);
        Nr=numel(r);
        Nth_orig=numel(pdata_i.ang_orig);
        sector_based=Nth_orig==Nr+1;
        if p.ConnectEndpoints
            theta=pdata_i.ang;
        else



            r=[0;r;0];%#ok<AGROW>
            if sector_based

                theta=[pdata_i.ang_orig(1);pdata_i.ang;pdata_i.ang_orig(end)];
            else
                mid_th=(pdata_i.ang(1)+pdata_i.ang(end))/2;
                theta=[mid_th;pdata_i.ang;mid_th];
            end
        end
        th=getNormalizedAngle(p,theta);

        if p.DisconnectAngleGaps

            [th,r,gapIdx]=insertValueAtGaps(NaN,th,r);



            th(gapIdx)=(th(gapIdx-1)+th(gapIdx+1))/2;

            r(gapIdx)=0;
        end





        r(r<=0)=eps;
        x=r.*cos(th);
        y=r.*sin(th);
        z=Zplane(datasetIndex).*ones(size(x));

        faceColor_i=getDatasetColor(p,datasetIndex);

        set(ht(datasetIndex),...
        'XData',x,...
        'YData',y,...
        'ZData',z,...
        'FaceColor',faceColor_i,...
        'FaceAlpha',1.0,...
        'EdgeColor',p.EdgeColor,...
        'Marker',marker{markerIdx},...
        'MarkerEdgeColor',p.EdgeColor,...
        'MarkerSize',markerSiz(markersizIdx),...
        'LineStyle',lineStyle_i,...
        'LineWidth',lineWidth(linewidthIdx),...
        'Visible','on');


        markerIdx=1+rem(markerIdx,markerN);
        markersizIdx=1+rem(markersizIdx,markersizN);
        linewidthIdx=1+rem(linewidthIdx,linewidthN);
        linestyleIdx=1+rem(linestyleIdx,linestyleN);
    end



