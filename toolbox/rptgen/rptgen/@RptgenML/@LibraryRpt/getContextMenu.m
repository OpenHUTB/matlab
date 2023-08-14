function cm=getContextMenu(this,selectedHandles)




    r=RptgenML.Root;
    e=r.getEditor;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(e);







    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_LibraryRpt:openReportLabel')),...
    'Callback','cbkOpen(subsref(getSelectedListNodes(DAStudio.imExplorer(getEditor(RptgenML.Root))),substruct(''()'',{1})));',...
    'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','open.png'),...
    'StatusTip',''));

    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_LibraryRpt:generateReportLabel')),...
    'Callback','cbkReport(subsref(getSelectedListNodes(DAStudio.imExplorer(getEditor(RptgenML.Root))),substruct(''()'',{1})));',...
    'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','Report.png'),...
    'StatusTip',''));

    currSys='';
    if rptgen.isSimulinkLoaded


        try
            currSys=gcs;
        end
    end

    if~isempty(currSys)
        cm.addSeparator();

        cm.addMenuItem(am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_LibraryRpt:associateWithSimulinkLabel')),...
        'Callback','cbkSimulink(subsref(getSelectedListNodes(DAStudio.imExplorer(getEditor(RptgenML.Root))),substruct(''()'',{1})));',...
        'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','simulink_associate.png'),...
        'StatusTip',''));

        cm.addMenuItem(r.actions.UnAssociateSimulink);
    end
