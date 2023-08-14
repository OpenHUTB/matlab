function labelAngles(p)




    S=p.pAngleLabelCoords;
    xc=S.x;
    yc=S.y;


    cstrRef=S.thetaStrs;
    cstrUser=p.pAngleTickLabel;
    if ischar(cstrUser)||(isstring(cstrUser)&&isscalar(cstrUser))
        cstrUser={cstrUser};
    end
    N=numel(cstrRef);
    Nuser=numel(cstrUser);
    if Nuser<N

        cstr=cstrUser(1+mod(0:N-1,Nuser));
    elseif Nuser>N
        cstr=cstrUser(1:N);
    else
        cstr=cstrUser;
    end







    ht=p.hAngleText;
    is_valid=~isempty(ht)&&ishghandle(ht(1));

    if is_valid&&(N~=numel(ht))
        delete(ht);
        ht=[];
        is_valid=false;
    end

    angleFontSize=getAngleFontSize(p);

    z0=0.294;
    if~is_valid
        ht=text(...
        xc,yc,z0*ones(size(xc)),cstr,...
        'Parent',p.hAxes,...
        'Tag',sprintf('AngleTicks%d',p.pAxesIndex),...
        'HandleVisibility','off',...
        'HorizontalAlignment','center',...
        'FontName',p.FontName,...
        'FontSize',angleFontSize,...
        'Clipping','on',...
        'Color',p.pAngleTickLabelColor);
        p.hAngleText=ht;


        for i=1:numel(xc)
            b=hggetbehavior(ht(i),'Plotedit');
            b.Enable=false;
        end


        set(ht,'uicontextmenu',p.UIContextMenu_AngleTicks);
    else
        for i=1:N
            set(ht(i),...
            'Position',[xc(i),yc(i),z0],...
            'String',cstr{i},...
            'Color',p.pAngleTickLabelColor);
        end
    end







    for i=1:N



        hh=ht(i);

        origStr=cstr{i};
        single_char=isscalar(origStr);
        if single_char
            hh.String=['0',origStr];
        end

        hh.Rotation=0;
        ext=hh.Extent(3:4);
        setappdata(hh,'Extent',ext);

        if p.AngleTickLabelRotation
            hh.Rotation=atan2d(yc(i),xc(i))-90;
        end

        if single_char
            hh.String=origStr;
        end
    end

    overrideAngleTickLabelVis(p,'default');
