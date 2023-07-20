function cba_copy



    me=TflDesigner.getexplorer;
    if~isempty(me)&&~me.getRoot.iseditorbusy&&...
        strcmpi(me.getaction('EDIT_COPY').Enabled,'on')==1

        me.getRoot.iseditorbusy=true;
        curnode=me.getRoot.currenttreenode;

        if isempty(curnode)||~ishandle(curnode);
            return;
        end

        me.getaction('EDIT_COPY').Enabled='off';

        selectednodes=TflDesigner.getselectedlistnodes;
        if isa(curnode,'TflDesigner.root')&&isempty(selectednodes)
            selectednodes=me.imme.getVisibleListNodes;
            if isempty(selectednodes)
                return;
            end
            selectednodes=[selectednodes{:}]';
        end

        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:CopyInProgressStatusMsg'));
        if isempty(selectednodes)
            if~isempty(curnode)
                me.getRoot.uiclipboard.fill(curnode,curnode.Type,{curnode.name});
            end
        else
            handles=cell(length(selectednodes),1);
            names=cell(length(selectednodes),1);
            for idx=1:length(selectednodes)
                handles{idx}=selectednodes(idx);
                names{idx}=selectednodes(idx);
            end
            clsh=handles{end};
            if~isempty(clsh)
                me.getRoot.uiclipboard.fill(handles,clsh.Type,names);
            end
        end

        me.getRoot.iseditorbusy=false;
        me.getaction('EDIT_COPY').Enabled='on';
        me.getaction('EDIT_PASTE').Enabled='on';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    end
