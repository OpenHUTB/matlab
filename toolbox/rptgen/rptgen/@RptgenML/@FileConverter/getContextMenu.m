function cm=getContextMenu(this,selectedHandles)




    r=RptgenML.Root;
    e=r.getEditor;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(e);







    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_FileConverter:selectXmlSource')),...
    'Callback','cbkSelectFile(getCurrentTreeNode(RptgenML.Root));',...
    'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','open.png'),...
    'StatusTip',''));

    if exist(this.SrcFileName,'file')
        convertEnable='on';
    else
        convertEnable='off';
    end

    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_FileConverter:convertFile')),...
    'Callback','cbkConvert(getCurrentTreeNode(RptgenML.Root));',...
    'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','Convert.png'),...
    'Enable',convertEnable,...
    'StatusTip',''));

    cm.addMenuItem(am.createAction(e,...
    'Text',getString(message('rptgen:RptgenML_FileConverter:editStylesheetLabel')),...
    'Callback','addStylesheetEditor(RptgenML.Root,getCurrentTreeNode(RptgenML.Root));',...
    'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','Stylesheet.png'),...
    'Visible',r.Actions.EditStylesheet.Visible,...
    'StatusTip',getString(message('rptgen:RptgenML_FileConverter:alreadyAssigned'))));

    cm.addMenuItem(r.actions.Close)

    cm.addSeparator;

    cm.addMenuItem(am.createDefaultAction(e,'CONTEXT_TREE_TO_WS'));
