function drawGridRefinementLines(p)








    ht=p.hRefinementLines;
    if~p.GridAutoRefinement
        if~isempty(ht)
            ht.Visible='off';
        end
        return
    end








    normRadii=p.pMagnitudeCircleRadii;
    Nc=numel(normRadii);
    No=Nc-2;
    if No<1
        if~isempty(ht)
            ht.Visible='off';
        end
        return
    end























    Nth=360/p.AngleResolution;
    Nd=floor(log2(p.MaxNumRefinementLines./Nth));



    Ndub=min(No,Nd);



    i2=Nc-1;
    i1=i2+1-Ndub;


    xc2=[];
    yc2=[];
    Nth_i=Nth;
    for j=i1:i2
        r_i=[normRadii(j),1.0];



        Nth_i=Nth_i*2;


        th=(1:2:Nth_i)./Nth_i.*360;
        th=getNormalizedAngle(p,th);
        x=cos(th);
        y=sin(th);




        xc=[r_i'*x;NaN(size(x))];
        yc=[r_i'*y;NaN(size(y))];
        xc2=[xc2;xc(:)];%#ok<AGROW>
        yc2=[yc2;yc(:)];%#ok<AGROW>
    end
    zc2=getGridZ(p)*ones(size(xc2));




    if isempty(ht)||~ishghandle(ht)
        ht=line(...
        'Parent',p.hAxes,...
        'HandleVisibility','off',...
        'Tag',sprintf('PolarGrid%d',p.pAxesIndex),...
        'XData',[],...
        'YData',[],...
        'ZData',[]);
        p.hRefinementLines=ht;


        b=hggetbehavior(ht,'DataCursor');
        b.Enable=false;
        b=hggetbehavior(ht,'Plotedit');
        b.Enable=false;

        set(ht,'uicontextmenu',p.UIContextMenu_Grid);
    end
    gridVis=internal.LogicalToOnOff(p.GridVisible);
    set(ht,...
    'XData',xc2,...
    'YData',yc2,...
    'ZData',zc2,...
    'Color',p.GridForegroundColor,...
    'Visible',gridVis,...
    'LineWidth',p.GridWidth);
