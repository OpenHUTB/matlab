function cba_buildinfocopy




    me=TflDesigner.getexplorer;
    if~isempty(me)&&~me.getRoot.iseditorbusy&&...
        strcmpi(me.getaction('EDIT_COPYBUILDINFO').Enabled,'on')==1

        me.getRoot.iseditorbusy=true;
        curnode=me.getRoot.currenttreenode;

        if isempty(curnode)||~ishandle(curnode);
            return;
        end

        me.getaction('EDIT_COPYBUILDINFO').Enabled='off';

        selectednodes=TflDesigner.getselectedlistnodes;
        if isa(curnode,'TflDesigner.root')&&isempty(selectednodes)
            selectednodes=me.imme.getVisibleListNodes;
            if isempty(selectednodes)
                return;
            end
            selectednodes=[selectednodes{:}]';
        end

        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:CopyInProgressStatusMsg'));
        if~isempty(selectednodes)
            handle{1}=selectednodes(1);
            name{1}='buildinfo';
            clsh=handle{1};
            if~isempty(clsh)
                me.getRoot.buildinfouiclipboard.fill(handle,clsh.Type,name);
            end

            me.getaction('EDIT_PASTEBUILDINFO').Enabled='on';
        end

        me.getRoot.iseditorbusy=false;
        me.getaction('EDIT_COPYBUILDINFO').Enabled='on';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    end





