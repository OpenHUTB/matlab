function cba_delete(varargin)






    me=TflDesigner.getexplorer;
    if~me.getRoot.iseditorbusy&&~isempty(me)&&~isempty(me.imme)&&...
        strcmpi(me.getaction('EDIT_DELETE').Enabled,'on')==1

        if nargin==1
            cut=logical(varargin{1});
        else
            cut=false;
        end

        me.getRoot.iseditorbusy=true;
        curnode=me.getRoot.currenttreenode;

        if isempty(curnode)||~ishandle(curnode);
            return;
        end;

        me.getaction('EDIT_DELETE').Enabled='off';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:DeleteInProgressStatusMsg'));

        selectednodes=TflDesigner.getselectedlistnodes;
        if~cut

            if curnode==me.getRoot
                selectednodes=[];
                msg=DAStudio.message('RTW:tfldesigner:ConfirmDeleteAllTablesDialogMessage');
            else
                if~isempty(selectednodes)
                    msg=DAStudio.message('RTW:tfldesigner:ConfirmDeleteEntryDialogMessage');
                else
                    msg=DAStudio.message('RTW:tfldesigner:ConfirmDeleteTableDialogMessage');
                end
            end
            resume=questdlg(msg,DAStudio.message('RTW:tfldesigner:DeleteText'),...
            DAStudio.message('RTW:tfldesigner:YesText'),...
            DAStudio.message('RTW:tfldesigner:NoText'),...
            DAStudio.message('RTW:tfldesigner:NoText'));
        else
            resume=DAStudio.message('RTW:tfldesigner:YesText');
        end

        selectedNodeAfterDeletion=curnode;
        if strcmpi(resume,DAStudio.message('RTW:tfldesigner:YesText'))
            if~isempty(selectednodes)
                selectedNodeAfterDeletion=delelement(me,selectednodes,cut);
            else
                selectedNodeAfterDeletion=me.getRoot.deletenode(curnode,cut);

                me.getRoot.firehierarchychanged;
            end
        end
        me.getRoot.refreshchildrencache(true);
        me.getaction('EDIT_DELETE').Enabled='on';

        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
        me.getRoot.iseditorbusy=false;
        me.show;
        TflDesigner.setcurrenttreenode(selectedNodeAfterDeletion);
    end


    function selectedNodeAfterDeletion=delelement(me,curnode,cut)

        if isa(curnode(1),'TflDesigner.elements')
            parent=curnode(1).parentnode;
        else
            parent=curnode(1).parent;
        end

        try
            if length(curnode)>1
                nodeidxinparent=[];
                for idx=1:length(curnode)
                    nodeidxinparent(end+1)=find(parent.children==curnode(idx));%#ok
                end

                nodeidxinparent=sort(nodeidxinparent);
            else
                nodeidxinparent=0;
                nodeidxinparent=find(parent.children==curnode);
            end

            if length(nodeidxinparent)>1
                for idx=1:length(nodeidxinparent)
                    childelement=parent.children(nodeidxinparent(idx)-(idx-1));
                    if isa(childelement,'TflDesigner.elements')
                        childelement.clearlinks;
                    end
                    if~cut
                        delete(childelement);
                    end
                    parent.children(nodeidxinparent(idx)-(idx-1))=[];

                end
                newnodeidxinparent=nodeidxinparent(idx)-(idx-1);
            else
                childelement=parent.children(nodeidxinparent);
                if isa(childelement,'TflDesigner.elements')
                    childelement.clearlinks;
                end
                if~cut
                    delete(childelement);
                end
                parent.children(nodeidxinparent)=[];
            end
            parent.firelistchanged;

        catch ERR
            me.getRoot.iseditorbusy=false;
            dp=DAStudio.DialogProvider;
            dp.errordlg(ERR.message,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
        end

        if length(nodeidxinparent)>1
            nodeidxinparent=newnodeidxinparent;
        end

        selectedNodeAfterDeletion=parent;

        if nodeidxinparent<=length(parent.children)
            nextnode=parent.children(nodeidxinparent);
            TflDesigner.setcurrentlistnode(nextnode);
        elseif nodeidxinparent>length(parent.children)&&~isempty(parent.children)
            nextnode=parent.children(nodeidxinparent-1);
            TflDesigner.setcurrentlistnode(nextnode);
        end
