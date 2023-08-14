function cba_validateEntry





    me=TflDesigner.getexplorer;
    if~me.getRoot.iseditorbusy&&~isempty(me)&&~isempty(me.imme)&&...
        strcmpi(me.getaction('VALIDATE_ENTRY').Enabled,'on')==1

        me.getRoot.iseditorbusy=true;

        me.getaction('VALIDATE_ENTRY').Enabled='off';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ValidationInProgressStatusMsg'));

        entries=TflDesigner.getselectedlistnodes;
        invalidEntryExists=false;

        for i=1:length(entries)
            isInvalid=TflDesigner.doValidateEntry(entries(i),true);
            if isInvalid
                invalidEntryExists=true;
            end
        end

        if invalidEntryExists
            errorstr=DAStudio.message('RTW:tfldesigner:InvalidEntriesFoundMsg');
            dp=DAStudio.DialogProvider;
            dp.errordlg(errorstr,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
        end

        currNode=me.getRoot.currenttreenode;
        currNode.firelistchanged;

        me.getRoot.iseditorbusy=false;
        me.getaction('VALIDATE_ENTRY').Enabled='on';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));

    end

