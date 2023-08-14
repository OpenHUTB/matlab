function cba_validateTable







    me=TflDesigner.getexplorer;
    if~me.getRoot.iseditorbusy&&~isempty(me)&&~isempty(me.imme)&&...
        strcmpi(me.getaction('VALIDATE_TABLE').Enabled,'on')==1

        me.getRoot.iseditorbusy=true;

        me.getaction('VALIDATE_TABLE').Enabled='off';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ValidationInProgressStatusMsg'));

        currNode=me.getRoot.currenttreenode;
        entries=currNode.children;
        invalidEntryExists=false;
        firstInvalidEntry=[];
        for i=1:length(entries)
            isInvalid=TflDesigner.doValidateEntry(entries(i),true);
            if isInvalid
                invalidEntryExists=true;
                if isempty(firstInvalidEntry)
                    firstInvalidEntry=entries(i);
                end
            end
        end

        if invalidEntryExists
            errorstr=DAStudio.message('RTW:tfldesigner:InvalidEntriesFoundMsg');
            dp=DAStudio.DialogProvider;
            dp.errordlg(errorstr,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
        end

        if isempty(firstInvalidEntry)
            TflDesigner.setcurrentlistnode(entries(1));
        else
            TflDesigner.setcurrentlistnode(firstInvalidEntry);
        end

        me.getRoot.iseditorbusy=false;
        currNode.firelistchanged;
        me.getaction('VALIDATE_TABLE').Enabled='on';
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));

    end

