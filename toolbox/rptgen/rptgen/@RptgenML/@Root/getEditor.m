function e=getEditor(this)




    e=this.Editor;
    if~isa(e,'DAStudio.Explorer')

        e=DAStudio.Explorer(this,'Report Generator');
        this.Editor=e;
        e.Title=getString(message('rptgen:RptgenML_Root:ReportExplorerLabel'));
        e.Icon=fullfile(toolboxdir('rptgen'),'resources','ReportGenerator.png');
        e.setTreeTitle('');
        e.allowWholeRowDblClick=true;


        extraSpaces=repmat(' ',[1,100]);
        e.addPropDisplayNames({'Name',[getString(message('rptgen:RptgenML_Root:NameLabel')),extraSpaces]})

        e.showContentsOf(false);
        e.delegateClose=true;
        e.clientCloseFunction='closeEditor(RptgenML.Root);';




        this.resetDispatcherEvents();

        ime=DAStudio.imExplorer(e);
        ime.showDialogView;
        ime.showUnappliedChangesDialog=false;
        ime.applyChanges=true;

        am=DAStudio.ActionManager;
        am.initializeClient(e);


        this.Listeners=[...
        handle.listener(e,...
        'METreeSelectionChanged',...
        {@treeSelectionChanged,this})
        handle.listener(DAStudio.EventDispatcher(),...
        'ListChangedEvent',...
        {@listChanged,this})
        handle.listener(e,...
        'MEPostClosed',...
        {@postClosed,this})
        handle.listener(e,...
        'MEPostShow',...
        {@postShow,this})
        ];


        menuFile=am.createPopupMenu(e);
        am.addSubMenu(e,menuFile,getString(message('rptgen:RptgenML_Root:fileLabelAcc')));

        i.New=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:newLabelAcc')),...
        'Callback','addReport(RptgenML.Root,''-new'');',...
        'Accel','Ctrl+n',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','new.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:createNewReportFileLabel')));
        menuFile.addMenuItem(i.New);

        i.NewForm=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:newFormLabelAcc')),...
        'Callback','addReport(RptgenML.Root,''-newform'');',...
        'Accel','Ctrl+Alt+n',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','newForm.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:createNewFormReportLabel')));
        menuFile.addMenuItem(i.NewForm);

        i.Open=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:openLabelAcc')),...
        'Callback','addReport(RptgenML.Root,''-open'');',...
        'Accel','Ctrl+o',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','open.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:openLabel')));
        menuFile.addMenuItem(i.Open);

        i.Save=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:saveLabelAcc')),...
        'Callback','cbkSave(RptgenML.Root,[],false);',...
        'Accel','Ctrl+s',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','save.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:saveCurrentFileLabel')));
        menuFile.addMenuItem(i.Save);

        i.SaveAs=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:saveAsLabelAcc')),...
        'Callback','cbkSave(RptgenML.Root,[],true);',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:saveWithDiffNameLabel')));
        menuFile.addMenuItem(i.SaveAs);

        i.Script=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:writeMFileLabelAcc')),...
        'Callback','cbkScript(RptgenML.Root);',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:saveAsMFileLabel')));
        menuFile.addMenuItem(i.Script);

        menuFile.addSeparator;

        i.Report=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:reportLabelAcc')),...
        'Callback','cbkReport(RptgenML.Root,''-rundeferred'');',...
        'Accel','Ctrl+r',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','Report.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:runCurrentReportLabel')));
        menuFile.addMenuItem(i.Report);

        i.Log=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:logFileLabelAcc')),...
        'Callback','cbkLog(RptgenML.Root)',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:createDescriptionLabel')));
        menuFile.addMenuItem(i.Log);

        menuFile.addSeparator;

        i.Preferences=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:prefsLabelAcc')),...
        'Callback','RptgenML.showPrefs;',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:editFormatPrefsLabel')));
        menuFile.addMenuItem(i.Preferences);

        menuFile.addSeparator;

        i.Close=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:closeLabelAcc')),...
        'Callback','closeReport(RptgenML.Root);',...
        'Accel','Ctrl+w');


        menuFile.addMenuItem(i.Close);

        i.Exit=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:exitLabelAcc')),...
        'Callback','closeEditor(RptgenML.Root);',...
        'Accel','Ctrl+q',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:exitLabel')));
        menuFile.addMenuItem(i.Exit);


        menuEdit=am.createPopupMenu(e);
        am.addSubMenu(e,menuEdit,getString(message('rptgen:RptgenML_Root:editLabelAcc')));




        i.Undo=am.createDefaultAction(e,'EDIT_UNDO');


        i.Redo=am.createDefaultAction(e,'EDIT_REDO');






        i.Cut=am.createAction(e,...
        'text',getString(message('rptgen:RptgenML_Root:cutLabelAcc')),...
        'callback','cbkCut(RptgenML.Root);',...
        'accel','Ctrl+X',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','cut.png'),...
        'statusTip',getString(message('rptgen:RptgenML_Root:cutToClipboardLabel')),...
        'toolTip',getString(message('rptgen:RptgenML_Root:cutLabel')));

        i.Cut2=am.createAction(e,...
        'text',getString(message('rptgen:RptgenML_Root:cutLabel')),...
        'callback','cbkCut(RptgenML.Root);',...
        'accel','Shift+Del');

        menuEdit.addMenuItem(i.Cut);



        i.Copy=am.createAction(e,...
        'text',getString(message('rptgen:RptgenML_Root:copyLabelAcc')),...
        'callback','cbkCopy(RptgenML.Root);',...
        'accel','Ctrl+C',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','copy.png'),...
        'statusTip',getString(message('rptgen:RptgenML_Root:copyToClipboardLabel')),...
        'toolTip',getString(message('rptgen:RptgenML_Root:copyLabel')));

        i.Copy2=am.createAction(e,...
        'text',getString(message('rptgen:RptgenML_Root:copyLabel')),...
        'callback','cbkCopy(RptgenML.Root);',...
        'accel','Ctrl+Ins');

        menuEdit.addMenuItem(i.Copy);



        i.Paste=am.createAction(e,...
        'text',getString(message('rptgen:RptgenML_Root:pasteLabelAcc')),...
        'callback','cbkPaste(RptgenML.Root);',...
        'accel','Ctrl+V',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','paste.png'),...
        'statusTip',getString(message('rptgen:RptgenML_Root:pasteFromClipboardLabel')),...
        'toolTip',getString(message('rptgen:RptgenML_Root:pasteLabel')));

        i.Paste2=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:pasteLabel')),...
        'callback','cbkPaste(RptgenML.Root);',...
        'accel','Shift+Ins');

        menuEdit.addMenuItem(i.Paste);


        i.Delete=am.createAction(e,...
        'text',getString(message('rptgen:RptgenML_Root:deleteLabelAcc')),...
        'callback','cbkDelete(RptgenML.Root);',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','delete.png'),...
        'statusTip',getString(message('rptgen:RptgenML_Root:deleteSelectedLabel')),...
        'toolTip',getString(message('rptgen:RptgenML_Root:deleteLabel')));

        menuEdit.addMenuItem(i.Delete);

        menuEdit.addSeparator;











        i.Activate=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:toggleComponentLabelAcc')),...
        'Callback','cbkToggleActivate(RptgenML.Root);',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','Component_deactivated.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:disableComponentLabel')));
        menuEdit.addMenuItem(i.Activate);

        menuEdit.addSeparator;

        i.MoveUp=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:moveUpLabelAcc')),...
        'Callback','cbkMove(RptgenML.Root,''up'');',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','move_up.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:moveUpLabel')));
        menuEdit.addMenuItem(i.MoveUp);

        i.MoveDown=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:moveDownLabelAcc')),...
        'Callback','cbkMove(RptgenML.Root,''down'');',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','move_down.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:moveDownLabel')));
        menuEdit.addMenuItem(i.MoveDown);

        i.MoveLeft=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:moveLeftLabelAcc')),...
        'Callback','cbkMove(RptgenML.Root,''left'');',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','move_left.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:moveLeftLabel')));
        menuEdit.addMenuItem(i.MoveLeft);

        i.MoveRight=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:moveRightLabelAcc')),...
        'Callback','cbkMove(RptgenML.Root,''right'');',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','move_right.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:moveRightLabel')));
        menuEdit.addMenuItem(i.MoveRight);



        menuView=am.createPopupMenu(e);
        am.addSubMenu(e,menuView,getString(message('rptgen:RptgenML_Root:viewLabelAcc')));

        i.FontIncrease=am.createDefaultAction(e,'VIEW_INCREASEFONT');
        menuView.addMenuItem(i.FontIncrease);

        i.FontDecrease=am.createDefaultAction(e,'VIEW_DECREASEFONT');
        menuView.addMenuItem(i.FontDecrease);

        menuView.addSeparator;


        i.ViewMessageList=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:showMessageListLabelAcc')),...
        'Callback','getDisplayClient(RptgenML.Root,''-view'');',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:displayStatusWindowLabel')));
        menuView.addMenuItem(i.ViewMessageList);


        menuTools=am.createPopupMenu(e);
        am.addSubMenu(e,menuTools,getString(message('rptgen:RptgenML_Root:toolsLabelAcc')));

        i.AssociateSimulink=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:associateWithSimulinkLabel')),...
        'Callback','cbkAssociateSimulink(RptgenML.Root);',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','simulink_associate.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:associateReportLabel')));
        menuTools.addMenuItem(i.AssociateSimulink);

        i.UnAssociateSimulink=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:unassociateWithSimulinkLabelAcc')),...
        'Callback','cbkAssociateSimulink(RptgenML.Root,[],''-null'');',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','simulink_unassociate.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:unassociateSystemLabel')));
        menuTools.addMenuItem(i.UnAssociateSimulink);

        menuTools.addSeparator;

        i.CreateComponent=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:createComponentLabelAcc')),...
        'Callback','cbkCreateComponent(RptgenML.Root);',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','Component_parentable.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:createNewComponentLabel')));

        menuTools.addMenuItem(i.CreateComponent);

        i.CreateComponentV2=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:createComponentFromLabelAcc')),...
        'Callback','cbkCreateComponent(RptgenML.Root,''-v2browse'');',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','Component_parentable.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:createDerivedComponentLabel')));

        menuTools.addMenuItem(i.CreateComponentV2);

        menuTools.addSeparator;

        i.EditStylesheet=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:editStylesheetLabelAcc')),...
        'Callback','addStylesheetEditor(RptgenML.Root);',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','Stylesheet.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:createStylesheetLabel')));

        menuTools.addMenuItem(i.EditStylesheet);

        i.EditDB2DOMTemplate=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:editDB2DOMTemplateLabelAcc')),...
        'Callback','showDB2DOMTemplateBrowser(RptgenML.Root);',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','Stylesheet.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:editDB2DOMTemplateLabel')));

        i.EditDB2DOMTemplate.Visible='on';

        menuTools.addMenuItem(i.EditDB2DOMTemplate);

        i.ConvertFile=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:convertSourceLabel')),...
        'Callback','RptgenML.FileConverter(RptgenML.Root);',...
        'Icon',fullfile(toolboxdir('rptgen'),'resources','Convert.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:convertXmlSourceLabel')));
        menuTools.addMenuItem(i.ConvertFile);



        menuHelp=am.createPopupMenu(e);
        am.addSubMenu(e,menuHelp,getString(message('rptgen:RptgenML_Root:helpLabelAcc')));

        i.HelpEditor=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:explorerHelpLabelAcc')),...
        'Callback','helpview(RptgenML.getHelpMapfile,''helpmenu.editor'');',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:showHelpLabel')));
        menuHelp.addMenuItem(i.HelpEditor);

        i.HelpRptgen=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:ReportGeneratorHelpLabelAcc')),...
        'Callback','helpview(RptgenML.getHelpMapfile,''helpmenu.rptgen'');',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:showHelpReportGeneratorLabel')));
        menuHelp.addMenuItem(i.HelpRptgen);

        menuHelp.addSeparator;

        i.About=am.createAction(e,...
        'Text',getString(message('rptgen:RptgenML_Root:aboutReportGeneratorLabel')),...
        'Callback','RptgenML.about;',...
        'StatusTip',getString(message('rptgen:RptgenML_Root:showCopyrightLabel')));
        menuHelp.addMenuItem(i.About);



        rTool=am.createToolBar(e);
        rTool.Label=getString(message('rptgen:RptgenML_Root:ReportGeneratorLabel'));

        rTool.addAction(i.New);
        rTool.addAction(i.NewForm);
        rTool.addAction(i.Open);
        rTool.addAction(i.Save);

        rTool.addSeparator;

        rTool.addAction(i.Cut);
        rTool.addAction(i.Copy);
        rTool.addAction(i.Paste);
        rTool.addAction(i.Delete);
        rTool.addAction(i.Activate);

        rTool.addSeparator;

        rTool.addAction(i.Report);

        rTool.addAction(i.AssociateSimulink);
        rTool.addAction(i.UnAssociateSimulink);

        rTool.addSeparator;

        rTool.addAction(i.MoveUp);
        rTool.addAction(i.MoveDown);
        rTool.addAction(i.MoveRight);
        rTool.addAction(i.MoveLeft);


        this.Actions=i;


        e.getDialog.refresh;
        enableActions(this);
        disableListViewNameSorting(this);
    end
    show(e);


    function cacheListView(currentNode)




        persistent libComps ssComps

        rptRoot=RptgenML.Root;



        if(isempty(libComps)||(~isempty(libComps)...
            &&~isa(libComps(1),'RptgenML.LibraryCategory')...
            &&~isa(libComps(1),'RptgenML.LibraryComponent')))
            libComps=rptRoot.listLibraryComponents;
        end




        if isa(currentNode,'RptgenML.StylesheetEditor')
            TransformType=currentNode.TransformType;
            if(isempty(ssComps)||~isfield(ssComps,TransformType))




                rgsRoot=RptgenML.StylesheetRoot;
                ssLib=getParamsLibrary(rgsRoot,TransformType,'-nobuild');
                if isa(ssLib,'RptgenML.Library')
                    ssComps.(TransformType)=getChildren(ssLib);
                end
            end
        end


        function treeSelectionChanged(eSrc,eData,this)%#ok


            enableActions(this);
            cacheListView(eData.EventData);
            disableListViewNameSorting(this);


            function disableListViewNameSorting(this)


                e=this.Editor;
                if(~isempty(e)&&isa(e,'DAStudio.Explorer')&&e.isVisible)
                    ime=DAStudio.imExplorer(e);
                    ime.enableListSorting(false,'Name',false,false);
                end


                function postShow(eSrc,eData,this)%#ok

                    disableListViewNameSorting(this);



                    function listChanged(eSrc,eData,this)%#ok

                        disableListViewNameSorting(this);


                        function postClosed(eSrc,eData,this)%#ok











                            closeEditor(this);






