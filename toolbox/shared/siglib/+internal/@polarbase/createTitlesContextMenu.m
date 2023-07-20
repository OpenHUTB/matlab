function createTitlesContextMenu(p,hParent)







    hchild=hParent.Children;
    if~isempty(hchild)
        delete(hchild(2:end));
        h1=hchild(1);
        delete(h1.Children);
    end

    addTitleMenu=false;
    if addTitleMenu



        label='<html><b>TITLES</b></html>';
        h1.Label=label;
        h1.Tag=h1.Label;
        h1.Separator='off';
        h1.Callback='';
        h1.Enable='off';
        h1.Checked='off';

        h=internal.ContextMenus.createContext({hParent,...
        'Show Top Title',...
        @(hMe,~)toggleTitleAndMenu(p,hMe,'top'),'separator','on'});
        h.Checked=internal.LogicalToOnOff(~isempty(p.TitleTop));

        h=internal.ContextMenus.createContext({hParent,...
        'Show Bottom Title',...
        @(hMe,~)toggleTitleAndMenu(p,hMe,'bottom')});
        h.Checked=internal.LogicalToOnOff(~isempty(p.TitleBottom));

    else



        label='Show Top Title';
        h1.Label=label;
        h1.Tag=h1.Label;
        h1.Separator='off';
        h1.Enable='on';
        h1.Checked=internal.LogicalToOnOff(~isempty(p.TitleTop));
        h1.Callback=@(hMe,~)toggleTitleAndMenu(p,hMe,'top');

        h=internal.ContextMenus.createContext({hParent,...
        'Show Bottom Title',...
        @(hMe,~)toggleTitleAndMenu(p,hMe,'bottom')});
        h.Checked=internal.LogicalToOnOff(~isempty(p.TitleBottom));
    end

end

function toggleTitleAndMenu(p,hMenu,sel)





    if strcmpi(sel,'top')
        propStr='TitleTop';
    else
        propStr='TitleBottom';
    end
    if isempty(p.(propStr))
        p.(propStr)=p.NewTitleString;
        hMenu.Checked='on';
    else
        p.(propStr)='';
        hMenu.Checked='off';
    end

end
