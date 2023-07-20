function cm=getContextMenu(this,selectedHandles)




    r=RptgenML.Root;
    e=r.getEditor;

    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(e);

    if isLibrary(this)







        cm.addMenuItem(am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_StylesheetEditor:editStylesheetLabel')),...
        'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','Stylesheet.png'),...
        'Callback','exploreAction(getSelectedListNodes(RptgenML.Root));',...
        'StatusTip',getString(message('rptgen:RptgenML_StylesheetEditor:editThisStylesheetLabel'))));

        onoff=locOnOff(~isempty(this.ID)&&...
        ~isempty(this.Registry)&&...
        endsWith(java.lang.String(this.Registry),(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS)));

        cm.addMenuItem(am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_StylesheetEditor:deleteStylesheetLabel')),...
        'Enabled',onoff,...
        'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','delete.png'),...
        'Callback','registryRemove(getSelectedListNodes(RptgenML.Root),true);',...
        'StatusTip',getString(message('rptgen:RptgenML_StylesheetEditor:deleteStylesheetFileLabel'))));


        cm.addMenuItem(am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_StylesheetEditor:sendToFileConverterLabel')),...
        'Enabled',locOnOff(~isempty(this.ID)),...
        'Callback','rptconvert(getSelectedListNodes(RptgenML.Root,true));',...
        'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','Convert.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_StylesheetEditor:openFileConversionWithCurrentLabel'))));

    else

        cm.addMenuItem(r.actions.Save)
        cm.addMenuItem(r.actions.SaveAs)
        cm.addMenuItem(r.actions.Close)

        cm.addSeparator;

        cm.addMenuItem(r.actions.Cut);
        cm.addMenuItem(r.actions.Copy);
        cm.addMenuItem(r.actions.Paste);


        cm.addSeparator;

        cm.addMenuItem(am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_StylesheetEditor:sendToFileConverterLabel')),...
        'Enabled',locOnOff(~isempty(this.ID)),...
        'Callback','rptconvert(getCurrentTreeNode(RptgenML.Root));',...
        'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','Convert.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_StylesheetEditor:openFileConversionWithCurrentLabel'))));

        cm.addSeparator;

        cm.addMenuItem(r.actions.MoveUp);
        cm.addMenuItem(r.actions.MoveDown);

        cm.addSeparator;

        cm.addMenuItem(am.createDefaultAction(e,'CONTEXT_TREE_TO_WS'));

    end




    function tf=locOnOff(tf)

        if tf
            tf='on';
        else
            tf='off';
        end

