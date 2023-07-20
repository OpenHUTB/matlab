function drawCircles(p,isRotating)











    ax=p.hAxes;
    hh=p.hCircles;




    angResDeg=2;












    if isempty(hh{1})||~ishghandle(hh{1})
        hh{1}=patch(...
        'Parent',ax,...
        'HandleVisibility','off',...
        'Tag',sprintf('SmithGrid%d',p.pAxesIndex));


        b=hggetbehavior(hh{1},'DataCursor');
        b.Enable=false;
        b=hggetbehavior(hh{1},'Plotedit');
        b.Enable=false;


        th=[0:angResDeg:360,0];
        x=cosd(th);
        y=sind(th);
        set(hh{1},...
        'Visible','on',...
        'XData',x,...
        'YData',y,...
        'ZData',zeros(size(th)),...
        'FaceAlpha',1.0,...
        'EdgeColor','none');

        set(hh{1},'uicontextmenu',p.UIContextMenu_Grid);
        p.hCircles=hh;
    end


    set(hh{1},...
    'FaceColor',p.GridBackgroundColor,...
    'EdgeColor',p.GridForegroundColor);










    if isempty(hh{2})||~ishghandle(hh{2})
        hh{2}=line(...
        'Parent',ax,...
        'HandleVisibility','off',...
        'Tag',sprintf('SmithGrid%d',p.pAxesIndex));


        b=hggetbehavior(hh{2},'DataCursor');
        b.Enable=false;
        b=hggetbehavior(hh{2},'Plotedit');
        b.Enable=false;

        p.hCircles=hh;
    end
    set(hh{2},'uicontextmenu',p.UIContextMenu_Grid);
    if isempty(hh{3})||~ishghandle(hh{3})
        hh{3}=line(...
        'Parent',ax,...
        'HandleVisibility','off',...
        'Tag',sprintf('SmithGrid%d',p.pAxesIndex));


        b=hggetbehavior(hh{3},'DataCursor');
        b.Enable=false;
        b=hggetbehavior(hh{3},'Plotedit');
        b.Enable=false;

        p.hCircles=hh;
    end
    set(hh{3},'uicontextmenu',p.UIContextMenu_Grid);


    if~isRotating






        points2=[];
        [points1,~]=p.mysmith(p.GridValue(1,:),...
        p.GridValue(2,:),1);

        points1=[points1,-1,1];
        xdata1=real(points1);
        ydata1=imag(points1);

        xdata2=real(points2);
        ydata2=imag(points2);

        set(hh{2},...
        'XData',[xdata1(:);xdata2(:)],...
        'YData',[ydata1(:);ydata2(:)],...
        'ZData',getGridZ(p)*ones(numel([xdata1(:);xdata2(:)]),1),...
        'Visible',internal.LogicalToOnOff(p.GridVisible));

        set(hh{3},...
        'XData',[-xdata1(:);-xdata2(:)],...
        'YData',[ydata1(:);ydata2(:)],...
        'ZData',getGridZ(p)*ones(numel(xdata2),1),...
        'Visible',internal.LogicalToOnOff(p.GridVisible));
        if p.GridVisible
            switch lower(p.GridType)
            case 'z'
                set(hh{2},...
                'LineWidth',p.GridLineWidth,...
                'LineStyle',p.GridLineStyle,...
                'Color',p.GridForegroundColor);
                set(hh{3},...
                'Visible','off');
            case 'y'
                set(hh{2},...
                'Visible','off');
                set(hh{3},...
                'LineWidth',p.GridLineWidth,...
                'LineStyle',p.GridLineStyle,...
                'Color',p.GridForegroundColor);
            case 'yz'
                set(hh{2},...
                'LineWidth',p.GridSubLineWidth,...
                'LineStyle',p.GridSubLineStyle,...
                'Color',p.GridSubForegroundColor);
                set(hh{3},...
                'LineWidth',p.GridLineWidth,...
                'LineStyle',p.GridLineStyle,...
                'Color',p.GridForegroundColor);
            case 'zy'
                set(hh{2},...
                'LineWidth',p.GridLineWidth,...
                'LineStyle',p.GridLineStyle,...
                'Color',p.GridForegroundColor);
                set(hh{3},...
                'LineWidth',p.GridSubLineWidth,...
                'LineStyle',p.GridSubLineStyle,...
                'Color',p.GridSubForegroundColor);
            end
        end
    else
        hh{2}.Visible='off';
        hh{3}.Visible='off';
    end




    if isempty(hh{4})||~ishghandle(hh{4})
        hh{4}=patch(...
        'Parent',ax,...
        'HandleVisibility','off',...
        'FaceAlpha',1,...
        'EdgeColor','none',...
        'Tag',sprintf('SmithClip%d',p.pAxesIndex));


        b=hggetbehavior(hh{4},'DataCursor');
        b.Enable=false;
        b=hggetbehavior(hh{4},'Plotedit');
        b.Enable=false;

        p.hCircles=hh;
    end








    xl=ax.XLim;
    xMin=-max(abs(xl));
    xMax=-xMin;
    yl=ax.YLim;
    yMin=-max(abs(yl));
    yMax=-yMin;
    yMid=(yMin+yMax)/2;
    ro=1.005;

    clipping=p.ClipData;






    if clipping
        th=0:2:360;
        xa=cosd(th);
        ya=sind(th);
        xc=[xMax,xa.*ro,xMax,xMax,xMin,xMin,xMax];
        yc=[yMid,ya.*ro,yMid,yMin,yMin,yMax,yMax];
    else

        xc=[];
        yc=[];
    end

    zc=0.292+zeros(size(xc));
    set(hh{4},...
    'XData',xc,...
    'YData',yc,...
    'ZData',zc,...
    'FaceColor',getBackgroundColorOfAxes(p));

