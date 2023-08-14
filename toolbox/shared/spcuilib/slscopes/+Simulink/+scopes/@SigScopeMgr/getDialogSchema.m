function dlgstruct=getDialogSchema(this,dialogTagName)




    addButton.Name='';
    addButton.Type='pushbutton';
    addButton.FilePath=fullfile(matlabroot(),'toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','add-new-16.png');
    addButton.ToolTip=getString(message('Spcuilib:scopes:SSMgrAdd'));
    addButton.MatlabMethod='Simulink.scopes.SigScopeMgr.onAddButton';
    addButton.MatlabArgs={'%source'};
    addButton.Tag='ssMgrAddButton';



    addButton.Enabled=true;

    paramsButton.Name='';
    paramsButton.Type='pushbutton';
    paramsButton.FilePath=fullfile(matlabroot(),'toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','parameters2-16.png');
    paramsButton.ToolTip=getString(message('Spcuilib:scopes:SSMgrParameters'));
    paramsButton.MatlabMethod='Simulink.scopes.SigScopeMgr.onParamsButton';
    paramsButton.MatlabArgs={'%source'};
    paramsButton.Tag='ssMgrParamsButton';
    paramsButton.Enabled=false;

    sigSelectButton.Name='';
    sigSelectButton.Type='pushbutton';
    sigSelectButton.FilePath=fullfile(matlabroot(),'toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','bindMode16.png');
    sigSelectButton.ToolTip=getString(message('Spcuilib:scopes:SSMgrBind'));
    sigSelectButton.MatlabMethod='Simulink.scopes.SigScopeMgr.onSigSelectButton';
    sigSelectButton.MatlabArgs={'%source'};
    sigSelectButton.Tag='ssMgrSelectButton';
    sigSelectButton.Enabled=false;

    promoteButton.Name='';
    promoteButton.Type='pushbutton';
    promoteButton.FilePath=fullfile(matlabroot(),'toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','arrow_up_blue.png');
    promoteButton.ToolTip='Promote to Results Gallery';
    promoteButton.MatlabMethod='Simulink.scopes.SigScopeMgr.onPromoteButton';
    promoteButton.MatlabArgs={'%source'};
    promoteButton.Tag='ssMgrPromoteButton';
    promoteButton.Enabled=false;


    promoteButton.Visible=false;

    deleteButton.Name='';
    deleteButton.Type='pushbutton';
    deleteButton.FilePath=fullfile(matlabroot(),'toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','delete-16.png');
    deleteButton.ToolTip=getString(message('Spcuilib:scopes:SSMgrDelete'));
    deleteButton.MatlabMethod='Simulink.scopes.SigScopeMgr.onDeleteButton';
    deleteButton.MatlabArgs={'%source'};
    deleteButton.Tag='ssMgrDeleteButton';
    deleteButton.Enabled=false;

    helpButton.Name='';
    helpButton.Type='pushbutton';
    helpButton.FilePath=fullfile(matlabroot(),'toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','help1-16.png');
    helpButton.ToolTip=getString(message('Spcuilib:scopes:SSMgrHelp'));
    helpButton.MatlabMethod='Simulink.scopes.SigScopeMgr.onHelpButton';
    helpButton.MatlabArgs={'%source'};
    helpButton.Tag='ssMgrHelpButton';
    helpButton.Enabled=true;




    viewerSpreadsheet.Type='spreadsheet';
    viewerSpreadsheet.Columns={' ',getString(message('Spcuilib:scopes:SSMgrName')),...
    getString(message('Spcuilib:scopes:SSMgrType')),getString(message('Spcuilib:scopes:SSMgrIn'))};
    viewerSpreadsheet.Source=Simulink.scopes.SigScopeMgrUtil.internal.ViewerGeneratorSpreadsheet(...
    this,this.mBlockDiagramHandle,'viewers');
    viewerSpreadsheet.Tag='ssMgrViewerSpreadsheet';
    viewerSpreadsheet.SelectionChangedCallback=@(tag,sels,dlg)Simulink.scopes.SigScopeMgr.onViewerSelectionChanged(tag,sels,dlg,this);
    viewerSpreadsheet.ItemClickedCallback=@(tag,item,name,dlg)Simulink.scopes.SigScopeMgr.onItemClicked(tag,item,name,dlg,this);



    viewerSpreadsheet.PreferredSize=[250,0];

    viewerSpreadsheet.Config='{ "enablemultiselect" : false }';

    generatorSpreadsheet.Type='spreadsheet';
    generatorSpreadsheet.Columns={getString(message('Spcuilib:scopes:SSMgrName')),...
    getString(message('Spcuilib:scopes:SSMgrType'))};
    generatorSpreadsheet.Source=Simulink.scopes.SigScopeMgrUtil.internal.ViewerGeneratorSpreadsheet(...
    this,this.mBlockDiagramHandle,'generators');
    generatorSpreadsheet.Tag='ssMgrGeneratorSpreadsheet';
    generatorSpreadsheet.PreferredSize=[250,0];
    generatorSpreadsheet.SelectionChangedCallback=@(tag,sels,dlg)Simulink.scopes.SigScopeMgr.onGeneratorSelectionChanged(tag,sels,this);
    generatorSpreadsheet.ItemClickedCallback=@(tag,item,name,dlg)Simulink.scopes.SigScopeMgr.onItemClicked(tag,item,name,dlg,this);




    generatorSpreadsheet.Config='{ "enablemultiselect" : false }';

    signalSpreadsheet.Type='spreadsheet';


    signalSpreadsheet.Columns={getString(message('Spcuilib:scopes:SSMgrDisplay')),...
    getString(message('Spcuilib:scopes:SSMgrType'))};
    signalSpreadsheet.Tag='ssMgrSignalSpreadsheet';
    signalSpreadsheet.Source=Simulink.scopes.SigScopeMgrUtil.internal.SignalSpreadsheet(...
    this,this.mBlockDiagramHandle);
    signalSpreadsheet.PreferredSize=[250,0];
    signalSpreadsheet.SelectionChangedCallback=@(tag,sels,dlg)Simulink.scopes.SigScopeMgr.onSignalSelectionChanged(tag,sels,this);
    signalSpreadsheet.ContextMenuCallback=@(tag,item,dlg)Simulink.scopes.SigScopeMgr.onSignalSpreadSheetContextMenuCB(tag,item,dlg,this);

    signalSpreadsheet.Config='{ "enablemultiselect" : false }';






    viewerTab.Name=getString(message('Spcuilib:scopes:SSMgrViewerTab'));
    viewerTab.Tag='ViewerTab';
    viewerTab.Items={viewerSpreadsheet};

    generatorTab.Name=getString(message('Spcuilib:scopes:SSMgrGeneratorsTab'));
    generatorTab.Tag='GeneratorTag';
    generatorTab.Items={generatorSpreadsheet};

    connSigsTab.Name=getString(message('Spcuilib:scopes:SSMgrConnectedSignals'));
    connSigsTab.Items={signalSpreadsheet};





    viewersGenerators.Name='tabcont';
    viewersGenerators.Type='tab';
    viewersGenerators.TabChangedCallback='Simulink.scopes.SigScopeMgr.onViewerGenTabChanged';
    viewersGenerators.Tabs={viewerTab,generatorTab};
    viewersGenerators.Tag='viewersAndGenerators';
    if(isempty(this.mSelectedTab))
        this.mSelectedTab='viewers';
    end

    connSigs.Name='tabcont';
    connSigs.Type='tab';
    connSigs.Tabs={connSigsTab};

    spacer.Type='panel';

    buttons.Name='panelcont';
    buttons.Type='panel';
    buttons.LayoutGrid=[1,7];
    buttons.ColStretch=[0,0,0,0,0,0,1];
    buttons.Items={addButton,paramsButton,sigSelectButton,promoteButton,deleteButton,helpButton,spacer};








    extraButton.Name='';
    extraButton.Type='pushbutton';
    extraButton.PreferredSize=[250,0];

    dlgstruct.DialogTitle='';
    dlgstruct.HelpMethod='slprophelp';
    dlgstruct.HelpArgs={'sigandscopemgr'};
    dlgstruct.LayoutGrid=[5,1];
    dlgstruct.RowStretch=[0,0,0,0,1];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.Items={buttons,viewersGenerators,connSigs,extraButton};
    dlgstruct.DialogTag=dialogTagName;
    dlgstruct.CloseCallback='Simulink.scopes.SigScopeMgr.onClose';
    dlgstruct.CloseArgs={this};
end