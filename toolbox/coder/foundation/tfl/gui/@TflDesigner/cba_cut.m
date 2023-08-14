function cba_cut




    me=TflDesigner.getexplorer;
    if~isempty(me)&&~me.getRoot.iseditorbusy&&...
        strcmpi(me.getaction('EDIT_CUT').Enabled,'on')==1

        curnode=me.getRoot.currenttreenode;
        if isempty(curnode)||~ishandle(curnode);
            return;
        end;

        TflDesigner.cba_copy;
        TflDesigner.cba_delete(true);
    end