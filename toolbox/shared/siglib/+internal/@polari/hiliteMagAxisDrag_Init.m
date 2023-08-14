function hiliteMagAxisDrag_Init(p,state,action)
















    if strcmpi(state,p.pMagAxisHilite)
        return
    end

    h=p.hMagAxisHilite;
    isValid=~isempty(h)&&ishghandle(h.up);

    if strcmpi(state,'off')

        p.pMagAxisHilite='none';
        if isValid
            set([h.up,h.dn,h.lt,h.rt],'Visible','off');
        end

        if p.MagHiliteOnHover




            hm=p.hMagRegionRect;
            if~isempty(hm)&&ishghandle(hm)
                hm.Visible='off';
            end
        end

        return
    end


    if nargin<3
        if p.pShiftKeyPressed
            action='upperlower';
        else
            if p.MagDrag_OrigRadius<=getMagTickHoverBrkpt(p)
                action='lower';
            else
                action='upper';
            end
        end
    end
    p.pMagAxisHilite=action;



    if~isValid
        x=[-1,0,+1,-1]*.5;
        y=[0,1,0,0]*.5;
        up=[x;y];
        y=[0,-1,0,0]*.5;
        dn=[x;y];
        x=[0,-1,0,0]*.5;
        y=[1,0,-1,1]*.5;
        lt=[x;y];
        x=[0,1,0,0]*.5;
        rt=[x;y];
        u={up,dn,lt,rt};

        h=struct;
        f={'up','dn','lt','rt'};
        for i=1:numel(f)

            p_i=patch(...
            'Parent',p.hAxes,...
            'HandleVisibility','off',...
            'FaceColor','none',...
            'FaceAlpha',1.0,...
            'EdgeColor','none',...
            'EdgeAlpha',1.0,...
            'Clipping','on',...
            'UserData',u,...
            'Visible','off');


            b=hggetbehavior(p_i,'DataCursor');
            b.Enable=false;

            h.(f{i})=p_i;


            set(p_i,'uicontextmenu',p.UIContextMenu_MagTicks);
        end

        p.hMagAxisHilite=h;
    end


    hudlr=[h.up,h.dn,h.lt,h.rt];
    set(hudlr,...
    'FaceColor',p.GridBackgroundColor,...
    'EdgeColor',p.pMagnitudeTickLabelColor);








    hiliteMagAxisDrag_Update(p);

    overrideMagnitudeTickLabelVis(p,'on');

    if strcmpi(state,'on')
        if strcmpi(action,'lower')

            set([h.up,h.dn],'Visible','on');
        else

            set(hudlr,'Visible','on');
        end


        hm=p.hMagRegionRect;
        if~isempty(hm)&&ishghandle(hm)
            hm.Visible='on';
        end
    end
end
