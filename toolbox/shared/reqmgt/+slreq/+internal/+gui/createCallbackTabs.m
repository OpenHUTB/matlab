function panel=createCallbackTabs(obj,callbackList)













    tabcontainer=struct('Type','tab','Name','tab','RowSpan',[2,2],'ColSpan',[1,1],'Tag','callback_container');

    tabs={};

    for index=1:length(callbackList)
        callbackName=callbackList{index};
        tabs{end+1}=createCallBackTab(obj,callbackName);%#ok<AGROW> 
    end

    tabcontainer.Tabs=tabs;

    panel=struct('Type','togglepanel','Name',getString(message('Slvnv:slreq:Callbacks')),'LayoutGrid',[1,1]);
    if isa(obj,'slreq.import.ui.ImportDlg')
        panel.Tag='SlreqImportDlg_Callbacks';
    else
        panel.Tag='Callbacks';
    end
    panel.ColStretch=1;
    panel.Enabled=true;
    panel.Items={tabcontainer};
    panel.Expand=slreq.gui.togglePanelHandler('get',panel.Tag,false);
    panel.ExpandCallback=@slreq.gui.togglePanelHandler;

end

function tab=createCallBackTab(obj,callBackName)
    codeEditor=struct('Type','matlabeditor',...
    'RowSpan',[2,4],'ColSpan',[2,4],...
    'Enabled',true,'Visible',true);
    codeEditor.MatlabEditorFeatures={'SyntaxHilighting','TabCompletion','CodeAnalyzer','LineNumber','GoToLine'};
    codeEditor.Graphical=true;
    codeEditor.MatlabMethod='slreq.app.CallbackHandler.callbackForChangeOfCallbackText';
    codeEditor.MatlabArgs={obj,callBackName,'%value'};

    codeEditor.Source=obj;

    if isa(obj,'slreq.import.ui.ImportDlg')
        codeEditor.Tag=['SlreqImportDlg_',callBackName];
        codeEditor.Value=['% ',getString(message(['Slvnv:slreq:CallbackTooltip',callBackName]))];

    else
        codeEditor.Tag=callBackName;
        codeEditor.Value=obj.(callBackName);
    end

    codeEditor.ToolTip=getString(message(['Slvnv:slreq:CallbackTooltip',callBackName]));

    predefinedItem=struct('Items',{{codeEditor}},'LayoutGrid',[2,4],'RowStretch',[0,1],'ColStretch',[0,0,0,1]);

    tab=predefinedItem;
    tab.Name=callBackName;
    tab.Tag=[callBackName,'_tab'];
end
