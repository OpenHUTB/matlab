function pm=getContextMenu(this,vargin)%#ok<INUSD>



    persistent menu;

    if(~isempty(this.Type))

        if~isempty(menu)&&ishandle(menu)
            menu.delete;
        end
        me=this.MeObj;
        am=DAStudio.ActionManager;
        pm=am.createPopupMenu(me);
        mProp=am.createDefaultAction(me,'EDIT_PROPERTIES');
        pm.addMenuItem(mProp);
        menu=pm;
    end

