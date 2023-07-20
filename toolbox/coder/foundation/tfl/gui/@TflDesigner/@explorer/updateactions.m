function updateactions(me)




    persistent actionnames;

    if isempty(actionnames)
        actionnames=me.getaction_names;
    end


    if isempty(me.getRoot.Children)
        if strcmp(me.getRoot.uiclipboard.type,'TflTable')
            state=me.getaction('EDIT_PASTE').Enabled;
        else
            state='off';
        end
        setallnodeactions(me,actionnames,'off');
        me.getaction('EDIT_PASTE').Enabled=state;
        me.getaction('EDIT_PASTEBUILDINFO').Enabled='off';
    else
        curnode=me.getRoot.currenttreenode;
        if isempty(curnode)
            curnode=me.getRoot;
        end
        me.getaction('EDIT_PASTEBUILDINFO').Enabled='off';
        if curnode==me.getRoot
            me.getaction('EDIT_CUT').Enabled='off';
            me.getaction('EDIT_COPY').Enabled='off';
            me.getaction('EDIT_COPYBUILDINFO').Enabled='off';
            setentryactions(me,actionnames,'off');
            return;
        end

        if strcmp(me.getRoot.uiclipboard.type,'TflEntry')
            me.getaction('EDIT_PASTE').Enabled='on';
        end

        if isempty(curnode.Children)
            setallnodeactions(me,actionnames,'off');
            setentryactions(me,actionnames,'on');
            seteditactions(me,'on');
        else
            if~isempty(me.getRoot.buildinfouiclipboard.contents)
                me.getaction('EDIT_PASTEBUILDINFO').Enabled='on';
            end
            setallnodeactions(me,actionnames,'on');
        end
    end

    drawnow;
end


function setallnodeactions(me,actionnames,status)

    me.getaction('FILE_EXPORT').Enabled=status;
    me.getaction('VALIDATE_ENTRY').Enabled=status;
    me.getaction('VALIDATE_TABLE').Enabled=status;
    me.getaction('EDIT_COPYBUILDINFO').Enabled=status;

    idxs=strmatch('FILE_NEW_',actionnames);
    idx_2=strmatch('FILE_CUSTOM_',actionnames);
    idxs=[idxs;idx_2];

    for i=1:length(idxs)
        me.getaction(actionnames{idxs(i)}).Enabled=status;
    end
    seteditactions(me,status);
end


function setentryactions(me,actionnames,status)
    idxs=strmatch('FILE_NEW_',actionnames);
    idx_2=strmatch('FILE_CUSTOM_',actionnames);
    idxs=[idxs;idx_2];

    for i=1:length(idxs)
        me.getaction(actionnames{idxs(i)}).Enabled=status;
    end
end


function seteditactions(me,status)

    me.getaction('EDIT_CUT').Enabled=status;
    me.getaction('EDIT_COPY').Enabled=status;
    me.getaction('EDIT_DELETE').Enabled=status;
end

