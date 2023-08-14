function drawRadialGridLines(p)



    Nth=360/p.AngleResolution;
    th=(0:Nth-1)./Nth.*360;
    th=getNormalizedAngle(p,th);

    x=cos(th);
    y=sin(th);
    if p.DrawGridToOrigin
        r_i=0.0;
    else

        normRadii=p.pMagnitudeCircleRadii;
        if numel(normRadii)<2

            r_i=1.0;
        else






            k=0.25;
            idx=find(normRadii>k,1,'first');



            if(idx>1)&&(k-normRadii(idx-1)<normRadii(idx)-k)
                idx=idx-1;
            end
            r_i=normRadii(idx);
        end
    end





    xc=[r_i.*x;x;NaN(size(x))];xc=xc(:);
    yc=[r_i.*y;y;NaN(size(y))];yc=yc(:);
    zc=getGridZ(p)*ones(size(yc));


    ht=p.hRadialLines;
    gridVis=internal.LogicalToOnOff(p.GridVisible);
    if isempty(ht)||~ishghandle(ht)
        ht=line(...
        'Parent',p.hAxes,...
        'HandleVisibility','off',...
        'Tag',sprintf('PolarGrid%d',p.pAxesIndex),...
        'XData',[],...
        'YData',[],...
        'ZData',[]);
        p.hRadialLines=ht;


        b=hggetbehavior(ht,'DataCursor');
        b.Enable=false;
        b=hggetbehavior(ht,'Plotedit');
        b.Enable=false;

        set(ht,'uicontextmenu',p.UIContextMenu_Grid);
    end
    set(ht,...
    'XData',xc,...
    'YData',yc,...
    'ZData',zc,...
    'Color',p.GridForegroundColor,...
    'LineWidth',p.GridWidth,...
    'Visible',gridVis);

    ht=p.hZeroLine;
    if p.ZeroAngleLine






        S=p.pAngleLabelCoords;
        idx=S.zeroIdx;



        th_c=th(idx);
        x=cos(th_c);
        y=sin(th_c);

        if p.FullZeroAngleLine
            r0=0;
        else
            r0=r_i;
        end


        if isempty(ht)||~ishghandle(ht(1))
            ht1=line(...
            'Parent',p.hAxes,...
            'HandleVisibility','off',...
            'Tag',sprintf('PolarGrid%d',p.pAxesIndex),...
            'XData',[],...
            'YData',[],...
            'ZData',[]);
            ht2=line(...
            'Parent',p.hAxes,...
            'HandleVisibility','off',...
            'Tag',sprintf('PolarGrid%d',p.pAxesIndex),...
            'XData',[],...
            'YData',[],...
            'ZData',[]);
            ht=[ht1,ht2];
            p.hZeroLine=ht;


            b=hggetbehavior(ht1,'DataCursor');
            b.Enable=false;
            b=hggetbehavior(ht2,'DataCursor');
            b.Enable=false;
            b=hggetbehavior(ht1,'Plotedit');
            b.Enable=false;
            b=hggetbehavior(ht2,'Plotedit');
            b.Enable=false;



            set(ht,'uicontextmenu',p.UIContextMenu_Grid);
        end



        if p.ZeroAngleLineCWMarker







            if strcmpi(p.AngleDirection,'ccw')
                off=4.25;
            else
                off=-4.25;
            end
            th_flag=th_c+off*pi/180;

            xp=[r0.*x,x];
            yp=[r0.*y,y];
            xpFlag=[x,.955*cos(th_flag),.91*x];
            ypFlag=[y,.955*sin(th_flag),.91*y];
        else

            xp=[r0.*x,x];
            yp=[r0.*y,y];
            xpFlag=[];
            ypFlag=[];
        end






        w=max(0.5,min(4*p.GridWidth,3));

        zg=getGridZ(p);
        zp=zg*ones(size(xp));
        zpFlag=zg*ones(size(xpFlag));

        set(ht(1),...
        'XData',xp,...
        'YData',yp,...
        'ZData',zp,...
        'Color',p.GridForegroundColor,...
        'LineWidth',w,...
        'Visible','on');
        set(ht(2),...
        'XData',xpFlag,...
        'YData',ypFlag,...
        'ZData',zpFlag,...
        'LineWidth',w,...
        'Color',p.GridForegroundColor,...
        'Visible','on');

    elseif~isempty(ht)&&all(ishghandle(ht))
        set(ht,'Visible','off');
    end
