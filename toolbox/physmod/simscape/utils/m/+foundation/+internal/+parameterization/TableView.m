classdef TableView<matlab.ui.container.internal.AppContainer





    properties(Access=public)
        UIFigureCompareParts matlab.ui.Figure
        UIFigureCompareWithBlock matlab.ui.Figure
        UIFigurePartSpec matlab.ui.Figure
        GridLayoutCompareParts matlab.ui.container.GridLayout
        GridLayoutCompareWithBlock matlab.ui.container.GridLayout
        GridLayoutPartSpec matlab.ui.container.GridLayout
        HighlightEditableColumnsButton matlab.ui.internal.toolstrip.ToggleButton
        HighlightDifferencesButton matlab.ui.internal.toolstrip.ToggleButton
        HelpButton matlab.ui.internal.toolstrip.qab.QABHelpButton
        ComparePartsUITable matlab.ui.control.Table
        CompareWithBlockUITable matlab.ui.control.Table
        PartSpecUITable matlab.ui.control.Table
        StatusBar matlab.ui.internal.statusbar.StatusBar
        StatusLabel matlab.ui.internal.statusbar.StatusLabel
        SelectManufacturerLabel matlab.ui.internal.toolstrip.Label
        SelectManufacturerDropdown matlab.ui.internal.toolstrip.DropDown
        ApplyAllButton matlab.ui.internal.toolstrip.Button
        ResetAllButton matlab.ui.internal.toolstrip.Button
        DisplaySettingsButtonGroup matlab.ui.internal.toolstrip.ButtonGroup
        DisplaySettingsAll matlab.ui.internal.toolstrip.ToggleGalleryItem
        DisplaySettingsVisible matlab.ui.internal.toolstrip.ToggleGalleryItem
        DisplaySettingsCategory matlab.ui.internal.toolstrip.GalleryCategory
        DisplaySettingsPopup matlab.ui.internal.toolstrip.GalleryPopup
        DisplaySettingsButton matlab.ui.internal.toolstrip.DropDownGalleryButton
Controller
    end

    events
AppClosed
    end

    methods(Access=public)
        function app=TableView()



            appOptions.Title=getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:BlockParameterizationManager'));
            app@matlab.ui.container.internal.AppContainer(appOptions);


            createComponents(app);



            app.CanCloseFcn=@(app)preClose(app);

            if nargout==0
                clear('app');
            end
        end

        function delete(app)
            app.close;
            notify(app,'AppClosed')
        end

        function value=preClose(app)
            notify(app,'AppClosed')
            value=1;
        end
    end


    methods(Access=private)


        function createComponents(app)


            tabGroup=matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag="mainTabGroup";


            mainTab=matlab.ui.internal.toolstrip.Tab(getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:SelectTab')));
            mainTab.Tag="mainTab";
            tabGroup.add(mainTab);
            app.add(tabGroup);


            formatTab=matlab.ui.internal.toolstrip.Tab(getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:FormatTab')));
            formatTab.Tag="formatTab";
            tabGroup.add(formatTab);
            app.add(tabGroup);


            parameterizeSection=mainTab.addSection(getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:ParameterizeSection')));
            parameterizeSection.Tag="parameterizeSection";

            selectSection=mainTab.addSection(getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:FilterSection')));
            selectSection.Tag="selectSection";


            formatSection=formatTab.addSection(getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:FormatTab')));
            formatSection.Tag="formatSection";

            highlightSection=formatTab.addSection(getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:HighlightSection')));
            highlightSection.Tag="highlightSection";


            comparepartsGroup=matlab.ui.internal.FigureDocumentGroup();
            comparepartsGroup.Title=getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:ComparePartsGroupName'));
            comparepartsGroup.Tag="comparePartsTable";
            comparepartsGroup.Closable=false;
            app.add(comparepartsGroup);


            figOptions.Title=getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:ComparePartsGroupName'));
            figOptions.Tag="CompareParts";
            figOptions.DocumentGroupTag=comparepartsGroup.Tag;
            figOptions.Closable=false;
            documentCompareParts=matlab.ui.internal.FigureDocument(figOptions);
            app.add(documentCompareParts);


            app.UIFigureCompareParts=documentCompareParts.Figure;


            app.GridLayoutCompareParts=uigridlayout(app.UIFigureCompareParts);
            app.GridLayoutCompareParts.ColumnWidth={'1x'};
            app.GridLayoutCompareParts.RowHeight={'1x'};


            comparewithBlockGroup=matlab.ui.internal.FigureDocumentGroup();
            comparewithBlockGroup.Title=getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:CompareWithBlockGroupName'));
            comparewithBlockGroup.Tag="compareWithBlockTable";
            comparewithBlockGroup.Closable=false;
            app.add(comparewithBlockGroup);


            figOptions.Title=getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:CompareWithBlockGroupName'));
            figOptions.Tag="CompareWithBlock";
            figOptions.DocumentGroupTag=comparewithBlockGroup.Tag;
            figOptions.Closable=false;
            documentCompareWithBlock=matlab.ui.internal.FigureDocument(figOptions);
            app.add(documentCompareWithBlock);


            app.UIFigureCompareWithBlock=documentCompareWithBlock.Figure;


            app.GridLayoutCompareWithBlock=uigridlayout(app.UIFigureCompareWithBlock);
            app.GridLayoutCompareWithBlock.ColumnWidth={'1x'};
            app.GridLayoutCompareWithBlock.RowHeight={'1x'};


            partSpecGroup=matlab.ui.internal.FigureDocumentGroup();
            partSpecGroup.Title=getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:PartSpecGroupName'));
            partSpecGroup.Tag="partSpecTable";
            partSpecGroup.Closable=false;
            app.add(partSpecGroup);


            figOptions.Title=getString(message(...
            'physmod:simscape:utils:BlockParameterizationManager:PartSpecGroupName'));
            figOptions.Tag="partSpec";
            figOptions.DocumentGroupTag=partSpecGroup.Tag;
            figOptions.Closable=false;
            partSpecdocument=matlab.ui.internal.FigureDocument(figOptions);
            app.add(partSpecdocument);


            app.UIFigurePartSpec=partSpecdocument.Figure;


            app.GridLayoutPartSpec=uigridlayout(app.UIFigurePartSpec);
            app.GridLayoutPartSpec.ColumnWidth={'1x'};
            app.GridLayoutPartSpec.RowHeight={'1x'};































































            documentLayout=struct;
            documentLayout.gridDimensions.w=2;
            documentLayout.gridDimensions.h=2;
            documentLayout.tileCount=3;






            documentLayout.columnWeights=[0.55,0.45];
            documentLayout.rowWeights=[0.5,0.5];
            documentLayout.tileCoverage=[1,2;3,3];

            document1State.id="comparePartsTable_CompareParts";
            document2State.id="partSpecTable_partSpec";
            document3State.id="compareWithBlockTable_CompareWithBlock";
            tile1Children=document1State;
            tile2Children=document2State;
            tile3Children=document3State;

            tile1Occupancy.children=tile1Children;
            tile2Occupancy.children=tile2Children;
            tile3Occupancy.children=tile3Children;

            documentLayout.tileOccupancy=[tile1Occupancy,tile2Occupancy...
            ,tile3Occupancy];
            app.DocumentLayout=documentLayout;


            selectManufacturerLabel=matlab.ui.internal.toolstrip.Label(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:SelectManufacturer')));
            selectManufacturerLabel.Tag='SelectManufacturer';
            app.SelectManufacturerLabel=selectManufacturerLabel;
            app.SelectManufacturerDropdown=matlab.ui.internal.toolstrip.DropDown();
            app.SelectManufacturerDropdown.Description=...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:SelectManufacturerDescription'));
            column=selectSection.addColumn();
            column.add(app.SelectManufacturerLabel);
            column=selectSection.addColumn('HorizontalAlignment','center','width',300);
            column.add(app.SelectManufacturerDropdown);


            app.ApplyAllButton=matlab.ui.internal.toolstrip.Button(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:ApplyAllButton')),...
            matlab.ui.internal.toolstrip.Icon.FORWARD_24);
            app.ApplyAllButton.Description=...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:ApplyAllButtonDescription'));
            app.ApplyAllButton.Enabled=true;
            app.ApplyAllButton.Tag="update";
            column=parameterizeSection.addColumn();
            column.add(app.ApplyAllButton);


            app.ResetAllButton=matlab.ui.internal.toolstrip.Button(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:ResetAllButton')),...
            matlab.ui.internal.toolstrip.Icon.UNDO_24);
            app.ResetAllButton.Description=...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:ResetAllButtonDescription'));
            app.ResetAllButton.Enabled=false;
            app.ResetAllButton.Tag="reset";
            column=parameterizeSection.addColumn();
            column.add(app.ResetAllButton);


            app.HighlightEditableColumnsButton=matlab.ui.internal.toolstrip.ToggleButton(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:EditFieldsString')),matlab.ui.internal.toolstrip.Icon.PROPERTIES_24);
            app.HighlightEditableColumnsButton.Description=...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:EditFieldsDescription'));
            app.HighlightEditableColumnsButton.Value=false;
            app.HighlightEditableColumnsButton.Tag="highlightEditFields";
            column=highlightSection.addColumn();
            column.add(app.HighlightEditableColumnsButton);


            app.HighlightDifferencesButton=matlab.ui.internal.toolstrip.ToggleButton(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:DifferencesToggleString')),matlab.ui.internal.toolstrip.Icon.PROPERTIES_24);
            app.HighlightDifferencesButton.Description=...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:DifferencesToggleDescription'));
            app.HighlightDifferencesButton.Value=false;
            app.HighlightDifferencesButton.Tag="highlightDifferences";
            column=highlightSection.addColumn();
            column.add(app.HighlightDifferencesButton);


            app.DisplaySettingsButtonGroup=matlab.ui.internal.toolstrip.ButtonGroup;


            app.DisplaySettingsAll=matlab.ui.internal.toolstrip.ToggleGalleryItem(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:DisplaySettingsAll')),...
            matlab.ui.internal.toolstrip.Icon.SETTINGS_24,app.DisplaySettingsButtonGroup);
            app.DisplaySettingsAll.Description=getString(...
            message('physmod:simscape:utils:BlockParameterizationManager:DisplaySettingsAllDescription'));
            app.DisplaySettingsAll.Value=true;

            app.DisplaySettingsVisible=matlab.ui.internal.toolstrip.ToggleGalleryItem(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:DisplaySettingsActive')),...
            matlab.ui.internal.toolstrip.Icon.SETTINGS_24,app.DisplaySettingsButtonGroup);
            app.DisplaySettingsVisible.Description=getString(...
            message('physmod:simscape:utils:BlockParameterizationManager:DisplaySettingsActiveDescription'));


            app.DisplaySettingsCategory=matlab.ui.internal.toolstrip.GalleryCategory(...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:DisplaySettingsCategory')));
            app.DisplaySettingsCategory.add(app.DisplaySettingsVisible);
            app.DisplaySettingsCategory.add(app.DisplaySettingsAll);


            app.DisplaySettingsPopup=matlab.ui.internal.toolstrip.GalleryPopup(...
            'ShowSelection',true,'DisplayState','list_view');
            app.DisplaySettingsPopup.add(app.DisplaySettingsCategory);


            app.DisplaySettingsButton=matlab.ui.internal.toolstrip.DropDownGalleryButton(...
            app.DisplaySettingsPopup,getString(...
            message('physmod:simscape:utils:BlockParameterizationManager:DisplaySettingsButton')),...
            matlab.ui.internal.toolstrip.Icon.SETTINGS_24);
            app.DisplaySettingsButton.Tag="settings";
            app.DisplaySettingsButton.Description=getString(...
            message('physmod:simscape:utils:BlockParameterizationManager:DisplaySettingsButtonDescription'));


            column=formatSection.addColumn();
            column.add(app.DisplaySettingsButton);


            app.HelpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            app.HelpButton.DocName='List of Pre-Parameterized Components';
            app.add(app.HelpButton);


            app.ComparePartsUITable=uitable(app.GridLayoutCompareParts);
            app.ComparePartsUITable.Layout.Row=1;
            app.ComparePartsUITable.Layout.Column=1;
            app.ComparePartsUITable.ColumnSortable=true;
            app.ComparePartsUITable.ColumnRearrangeable=true;
            app.ComparePartsUITable.RowName=[];


            app.CompareWithBlockUITable=uitable(app.GridLayoutCompareWithBlock);
            app.CompareWithBlockUITable.Layout.Row=1;
            app.CompareWithBlockUITable.Layout.Column=1;
            app.CompareWithBlockUITable.ColumnSortable=true;
            app.CompareWithBlockUITable.ColumnRearrangeable=true;
            app.CompareWithBlockUITable.RowName=[];
            app.CompareWithBlockUITable.ColumnName={...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:ParameterName'));...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:Parameterization'));...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:Override'));...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:PartValue'));...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:PresentBlockValue'));...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:Unit'));...
            };
            app.CompareWithBlockUITable.ColumnEditable=[false,false,true,false,true,false];


            app.PartSpecUITable=uitable(app.GridLayoutPartSpec);
            app.PartSpecUITable.Layout.Row=1;
            app.PartSpecUITable.Layout.Column=1;
            app.PartSpecUITable.ColumnName={...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:Attribute'));...
            getString(message('physmod:simscape:utils:BlockParameterizationManager:Value'))};
            app.PartSpecUITable.ColumnSortable=true;
            app.PartSpecUITable.RowName=[];







            app.StatusBar=matlab.ui.internal.statusbar.StatusBar;
            app.StatusBar.Tag='statusBar';
            app.add(app.StatusBar);
            app.StatusLabel=matlab.ui.internal.statusbar.StatusLabel('');
            app.StatusLabel.Tag='statusLabel';
            app.StatusBar.add(app.StatusLabel);


            app.Visible=true;


            app.WindowBounds(3:4)=[1400,810];
        end
    end
end