function menu=generateFilteredViewPopupMenu()






    menu=struct('callback','slreq.internal.gui.generatedFilterRadioButtonCB','items',[]);

    items={};
    header=getTemplate();
    header.isHeader=true;
    header.label=getString(message('Slvnv:slreq:SelectView'));
    header.name='header';
    header.callbackArg='noop';
    items{end+1}=header;

    items{end+1}=generateViewList();

    items{end+1}=generateSaveItem();


    items{end+1}=generateEditItem();

    menu.items=items;
end

function item=generateSaveItem()
    item=getTemplate();
    item.label=getString(message('Slvnv:slreq:FilterViewSaveDDD'));
    item.callbackArg='__internal_save__';
    item.name='saveView';
    item.tag='__saveView_Tag__';
end

function item=generateEditItem()
    item=getTemplate();
    item.label=getString(message('Slvnv:slreq:ManageFilterViewsDDD'));
    item.callbackArg='__internal_invoke_editor__';
    item.name='editViews';
    item.tag='__editViews_Tag__';
end


function items=generateViewList()
    viewMgr=slreq.app.MainManager.getInstance.viewManager;
    if isempty(viewMgr)
        return;
    end
    views=viewMgr.getViews();


    vv=viewMgr.getView();
    vanillaItem=getTemplate();
    vanillaItem.label=vv.getLabel();
    vanillaItem.tag='__vanillaView_Tag__';
    vanillaItem.name='vanillaView';
    vanillaItem.callbackArg='noop';

    items=vanillaItem;

    for i=1:length(views)
        if views(i).isVanillaView
            items(1).callbackArg=num2str(i);
            continue;
        end

        vitem=getTemplate();
        vitem.callbackArg=num2str(i);
        vitem.label=views(i).getLabel();
        vitem.tag=['__view_',num2str(i),'_Tag__'];
        vitem.name=views(i).name;

        items=[items,vitem];
    end

end


function template=getTemplate()
    template=struct('name','','uniqName','','label','','tag','','accel','','enabled','on','visible','on','isHeader',false);
end

function onoff=bool2OnOff(tf)
    if tf
        onoff='on';
    else
        onoff='off';
    end
end

