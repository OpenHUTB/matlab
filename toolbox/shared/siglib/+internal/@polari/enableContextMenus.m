function enableContextMenus(p,state)












end

function technique2(p,state)

    f=p.hFigure;
    cm=f.UIContextMenu;
    if isempty(cm)
        return
    end
    ch=cm.Children;


    pidx=p.pAxesIndex;





end

function technique1(p,state)

    ax=p.hFigure;


    shh='showhiddenhandles';
    shh_o=get(0,shh);
    set(0,shh,'on')
    ch=ax.Children;
    set(0,shh,shh_o);


    cm=findobj(ch,'flat','Type','uicontextmenu');





    if state

        set(cm,'Visible','on');
    else

        vis=get(cm,'Visible');
        set(cm,'Visible','off');
    end
end
