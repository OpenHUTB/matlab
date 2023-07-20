function panel=getRTTDialogItems(hCS,info)




    hObj=hCS.getComponent('Run on Hardware');
    try
        allGroups=[info.parametersGroup1,info.parametersGroup2...
        ,info.parametersGroup3,info.parametersGroup4];
        tagssofar={'Dummy'};
        tagprefix='Tag_ConfigSet_RTT_Settings_';
        panel.Type='panel';
        panel.Tag=[tagprefix,'settingsStack'];
        panel.Items={};
        panel.LayoutGrid=[1+numel(allGroups)+1,2];
        panel.RowStretch=[zeros(1,1+numel(allGroups)),1];
        panel.ColStretch=[3,1];

        panel.Items={};

        row=2;
        for i=1:4
            parametersGroups=info.(['parametersGroup',num2str(i)]);
            parameters=info.(['parameters',num2str(i)]);
            for j=1:numel(parametersGroups)
                group.Type='group';
                group.Name=parametersGroups{j};
                group.Tag=[tagprefix,strrep(group.Name,' ',''),'_Group'];
                group.LayoutGrid=[numel(parameters{j})+1,1];
                group.RowSpan=[row,row];
                group.ColSpan=[1,1];
                group.Items={};
                for k=1:numel(parameters{j})
                    WidgetHint=parameters{j}{k};
                    found=find(strcmp(tagssofar,WidgetHint.Tag),1);
                    assert(isempty(found),DAStudio.message('realtime:build:ConfigTagAlreadyPresent',WidgetHint.Tag));
                    tagssofar{end+1}=WidgetHint.Tag;%#ok<AGROW>
                    widget=i_getWidgetFor(hObj,WidgetHint);
                    widget=i_setWidgetValueFromObject(widget,hObj);
                    widget.Source=hObj;
                    widget.ObjectMethod='widgetChanged';
                    widget.MethodArgs={'%dialog',widget.Tag,WidgetHint.Type};
                    widget.ArgDataTypes={'handle','string','string'};
                    group.Items{k}=widget;
                end
                panel.Items{end+1}=group;
                row=row+1;
            end
        end
    catch e
        panel={};
    end
end



function widget=i_getWidgetFor(hObj,WidgetHint)
    tagprefix='Tag_ConfigSet_RTT_Settings_';
    widget.Name=WidgetHint.Name;
    widget.Tag=[tagprefix,WidgetHint.Tag];
    widget.Type=WidgetHint.Type;
    widget.Entries=WidgetHint.Entries;
    widget.Value=WidgetHint.Value;
    if isequal(widget.Type,'combobox')&&~isempty(widget.Entries)&&~iscell(widget.Entries)
        widget.Entries=eval(widget.Entries);
    end
    simStatus=get_param(hObj.getModel,'SimulationStatus');
    if isequal(simStatus,'running')||isequal(simStatus,'initializing')||...
        isequal(simStatus,'external');
        widget.Enabled=false;
    else
        if ischar(WidgetHint.Enabled)
            widget.Enabled=eval(WidgetHint.Enabled);
        else
            widget.Enabled=WidgetHint.Enabled;
        end
    end
    if ischar(WidgetHint.Visible)
        widget.Visible=eval(WidgetHint.Visible);
    else
        widget.Visible=WidgetHint.Visible;
    end

    widget.RowSpan=WidgetHint.RowSpan;
    widget.ColSpan=WidgetHint.ColSpan;
    widget.DialogRefresh=WidgetHint.DialogRefresh;
    widget.UserData=WidgetHint.Storage;
end



function widget=i_setWidgetValueFromObject(widget,hObj)
    tagprefix='Tag_ConfigSet_RTT_Settings_';
    fieldName=strrep(widget.Tag,tagprefix,'');
    data=get_param(hObj,'TargetExtensionData');
    if isfield(data,fieldName)
        objectValue=data.(fieldName);
        widget.Value=objectValue;
    else
        hDlg=[];%#ok<NASGU> % do not remove, this initialization is needed
        if isnumeric(widget.Value)
            value=widget.Value;
        else




            if isfield(widget,'UserData')&&~isempty(strmatch('dontevalstring',strvcat(widget.UserData),'exact'))%#ok
                value=widget.Value;
            else
                value=eval(widget.Value);
            end

        end
        widget.Value=value;

        hDlg=hObj.getConfigSet().getDialogHandle();
        if~isempty(hDlg)&&...
            ~isequal(hDlg.getWidgetValue(widget.Tag),value)
            hDlg.setWidgetValue(widget.Tag,value);
        end
    end
end