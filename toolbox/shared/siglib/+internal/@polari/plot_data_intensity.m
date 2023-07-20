function plot_data_intensity(p)





    set(p.hDataPatch,...
    'HandleVisibility','off',...
    'Visible','off');
    set(p.hDataLine,...
    'Visible','off',...
    'HandleVisibility','off');
    set(p.hDataLineGlow,'Visible','off');

    pdata=getAllDatasets(p);
    Nd=numel(pdata);
    Z0=0.2;

    hs=p.hIntensitySurf;
    if isempty(hs)
        hs=surface(...
        'Parent',p.hAxes,...
        'Tag',sprintf('PolarData%d',p.pAxesIndex),...
        'HandleVisibility','on',...
        'Visible','off',...
        'EdgeColor','none');
        p.hIntensitySurf=hs;

        b=hggetbehavior(hs,'DataCursor');
        b.UpdateFcn=@(h,e)figureDataCursorUpdateFcn(p,e);

        set(hs,'uicontextmenu',p.UIContextMenu_Data);
        setappdata(hs,'polariDatasetIndex',1);
        setappdata(hs,'polariZPlane',Z0);
    end

    if Nd>0

        pdata_i=pdata(1);

        r=getNormalizedMag(p,pdata_i.mag);
        th=getNormalizedAngle(p,pdata_i.ang);













        ridx=find(r>=0,1,'first');
        if~isempty(ridx)&&(ridx>1)
            if(r(ridx)>0)





                r=r(ridx-1:end);
                cdata=pdata.intensity(ridx-1:end,:);
            else
                r=r(ridx:end);
                cdata=pdata.intensity(ridx:end,:);
            end
        else
            cdata=pdata.intensity;
        end







        if~pdata.angGapAtEnd
            th=[th;th(1)];
            cdata=[cdata,cdata(:,1)];
        end


        [thm,rm]=meshgrid(th,r);
        [xm,ym]=pol2cart(thm,rm);
        zm=ones(size(xm))*Z0;

        set(hs,...
        'XData',xm,...
        'YData',ym,...
        'ZData',zm,...
        'CData',cdata,...
        'Visible','on',...
        'HandleVisibility','on');
    else

        hs.Visible='off';
    end
