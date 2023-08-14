function widget=getTargetHardwareSelectionWidget(hCS,tag,widgetId,enabled)





    if isempty(hCS)
        widget=[];
        return
    end


    if nargin<4
        enabled=true;
    end

    hardwareBoardComboEntries=unique(codertarget.utils.getTargetHardwareSelectionWidgetEntries(hCS,enabled));

    if enabled
        boardIdx=0;
        if codertarget.target.isCoderTarget(hCS)
            boardName=codertarget.data.getParameterValue(hCS,'TargetHardware');
            try
                dispName=codertarget.target.getTargetHardwareDisplayNameFromName(boardName);
                [found,idx]=ismember(dispName,hardwareBoardComboEntries);
            catch e %#ok<NASGU>
                found=false;
            end
            if~found
                boardIdx=0;
                set_param(hCS,'HardwareBoard','None');
            else
                boardIdx=idx-1;
            end
        elseif isequal(get_param(hCS,'SystemTargetFile'),'realtime.tlc')
            if hCS.isValidParam('TargetExtensionPlatform')
                boardIdx=get_param(hCS,'TargetExtensionPlatform');
                [found,idx]=ismember(boardIdx,hardwareBoardComboEntries);
                if~found
                    boardIdx=0;
                    set_param(hCS,'TargetExtensionPlatform','None');
                else
                    boardIdx=idx-1;
                end
            end
        end
        widget.Entries=hardwareBoardComboEntries;
        widget.Value=hardwareBoardComboEntries{boardIdx+1};
    else
        widget.Value=hardwareBoardComboEntries{1};
    end

    widget.Type='combobox';
    widget.Name=getString(message('codertarget:build:HardwareBoard'));
    widget.ToolTip=getString(message('codertarget:build:HardwareBoardToolTip'));
    widget.UserData.ObjectProperty='HardwareBoard';
    widget.MatlabMethod='codertarget.target.targetHardwareChanged';
    widget.MatlabArgs={'%source','%dialog','%tag'};
    widget.Enabled=~(strcmp(hCS.readonly,'on')||hCS.isObjectLocked)&&enabled;
    widget.Visible=true;
    widget.Tag=[tag,'TargetHardware'];
    widget.WidgetId=[widgetId,'TargetHardware'];
    widget.ColSpan=[1,2];
    widget.DialogRefresh=true;

end
