function dlgstruct=getDialogSchema(this,~)


    items=generateWebWindow(this);
    dlgstruct=getDlgStruct(this,{items});

end

function webWindow=generateWebWindow(~)


    webWindow.Type='webbrowser';
    webWindow.Tag='TaskPane';

    taskPaneUrl=learning.simulink.Application.getInstance().getTaskPaneUrl();
    academyUrl=connector.getUrl(taskPaneUrl);

    webWindow.Url=academyUrl;
    webWindow.DisableContextMenu=true;
    webWindow.DialogRefresh=true;
    webWindow.RowSpan=[1,1];
    webWindow.Alignment=0;
    webWindow.SecuritySettings={'AllowFileAccessFromFileUrls','AllowUniversalAccessFromFileUrls','EnableWebSecurity'};
    webWindow.KeyShortcutsAcceptPolicy={'All'};

    webWindow.MinimumSize=[300,500];

    if learning.simulink.Application.getInstance().getDebugMode()
        webWindow.Debug=true;
        webWindow.EnableInspectorOnLoad=true;
        webWindow.EnableInspectorInContextMenu=true;
    else
        webWindow.Debug=false;
        webWindow.EnableInspectorOnLoad=false;
        webWindow.EnableInspectorInContextMenu=false;
    end

end

function dlgstruct=getDlgStruct(~,items)

    dlgstruct.DialogTitle='';
    dlgstruct.DialogTag=learning.simulink.slAcademy.TaskPane.TASK_PANE_DOCKED_TAG;
    numrows=numel(items);

    dlgstruct.LayoutGrid=[numrows,1];
    dlgstruct.RowStretch=zeros(1,numrows);
    dlgstruct.RowStretch(end)=1;
    colstretch=zeros(1,1);
    colstretch(1)=1;
    dlgstruct.ColStretch=colstretch;

    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.IsScrollable=true;
    dlgstruct.MinimalApply=true;
    dlgstruct.DialogRefresh=true;
    dlgstruct.Items=items;

    dlgstruct.ExplicitShow=true;
end
