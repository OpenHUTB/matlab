function createPointContextMenu(p,hParent)











    masterMenu=nargin>1;
    if~masterMenu
        hc=p.UIContextMenu_Point;
    else
        hc=hParent;
    end







    Nc=numel(hc.Children);
    if Nc==1
        hDummy=hc.Children;
    else
        hDummy=[];
    end
    make=Nc<2;







































































    if make&&~masterMenu



        dummy=rfdata.data;
        mappoints=p.hAxes.CurrentPoint;

        z=gamma2z(complex(mappoints(1,1),mappoints(1,2)),1);
        internal.ContextMenus.createContext({hc,'R circle',...
        @(~,~)circle(dummy,1e9,'R',real(z),p),'separator','on'});
        internal.ContextMenus.createContext({hc,'X circle',...
        @(~,~)circle(dummy,1e9,'X',imag(z),p),'separator','on'});


    end

    ht=findobj(hc,'Tag','Properties...');
    if~isempty(ht)
        ht.Enable=internal.LogicalToOnOff(~is_intensity_data);
    end
    if make&&~isempty(hDummy)
        delete(hDummy);
    end
