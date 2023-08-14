classdef View<matlab.ui.container.internal.AppContainer





    properties(Access=public)
        UIFigureNodes matlab.ui.Figure
        UIFigureBusbars matlab.ui.Figure
        UIFigureConnections matlab.ui.Figure
        GridLayoutNodes matlab.ui.container.GridLayout
        GridLayoutBusbars matlab.ui.container.GridLayout
        GridLayoutConnections matlab.ui.container.GridLayout
        HighlightinputsintableCheckBox matlab.ui.internal.toolstrip.ToggleButton
        HighlightblocksinmodelCheckBox matlab.ui.internal.toolstrip.ToggleButton
        RefreshButton matlab.ui.internal.toolstrip.Button
        SettingsButtonGroup matlab.ui.internal.toolstrip.ButtonGroup
        SettingsFrequencyAndTime matlab.ui.internal.toolstrip.ToggleGalleryItem
        SettingsTimeAndSteadyState matlab.ui.internal.toolstrip.ToggleGalleryItem
        SettingsLocal matlab.ui.internal.toolstrip.ToggleGalleryItem
        SettingsCategory matlab.ui.internal.toolstrip.GalleryCategory
        SettingsPopup matlab.ui.internal.toolstrip.GalleryPopup
        SettingsButton matlab.ui.internal.toolstrip.DropDownGalleryButton
        SettingsSimulationConfigurationButtonGroup matlab.ui.internal.toolstrip.ButtonGroup
        SettingsStatic matlab.ui.internal.toolstrip.ToggleGalleryItem
        SettingsDynamic matlab.ui.internal.toolstrip.ToggleGalleryItem
        SettingsSimulationConfigurationCategory matlab.ui.internal.toolstrip.GalleryCategory
        RunButton matlab.ui.internal.toolstrip.Button
        TimeSlider matlab.ui.internal.toolstrip.Slider
        TimeEdit matlab.ui.internal.toolstrip.EditField
        ExportButton matlab.ui.internal.toolstrip.Button
        HelpButton matlab.ui.internal.toolstrip.qab.QABHelpButton
        NodeUITable matlab.ui.control.Table
        BusbarUITable matlab.ui.control.Table
        ConnectionUITable matlab.ui.control.Table
        StatusBar matlab.ui.internal.statusbar.StatusBar
        StatusLabel matlab.ui.internal.statusbar.StatusLabel
    end

    properties(Access=private)
        Control=[];
    end

    methods(Access=public)
        function app=View()



            appOptions.Tag="ee_loadFlowApp";
            appOptions.Title=getString(message('physmod:ee:loadflow:SimscapeElectricalLoadFlowAnalyzer'));
            app@matlab.ui.container.internal.AppContainer(appOptions);


            createComponents(app);

            if nargout==0
                clear('app');
            end
        end

        function delete(app)
            app.close;
        end

        function addControl(app,control)

            app.Control=control;
        end
    end


    methods(Access=private)

        function createComponents(app)

            tabGroup=matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag="mainTabGroup";
            tab=matlab.ui.internal.toolstrip.Tab(getString(message('physmod:ee:loadflow:LoadFlowTabName')));
            tab.Tag="mainTab";
            tabGroup.add(tab);
            app.add(tabGroup);
            prepareSection=tab.addSection(getString(message('physmod:ee:loadflow:PrepareSectionName')));
            prepareSection.Tag="prepareSection";
            simulateSection=tab.addSection(getString(message('physmod:ee:loadflow:SimulateSectionName')));
            simulateSection.Tag="simulateSection";
            timeSection=tab.addSection(getString(message('physmod:ee:loadflow:TimeSectionName')));
            timeSection.Tag="timeSection";
            exportSection=tab.addSection(getString(message('physmod:ee:loadflow:ExportSectionName')));
            exportSection.Tag="exportSection";


            nodesAndBusbarsGroup=matlab.ui.internal.FigureDocumentGroup();
            nodesAndBusbarsGroup.Title=getString(message('physmod:ee:loadflow:NodesGroupName'));
            nodesAndBusbarsGroup.Tag="NodesAndBusbarsTables";
            nodesAndBusbarsGroup.DefaultRegion='top';
            app.add(nodesAndBusbarsGroup);


            connectionsGroup=matlab.ui.internal.FigureDocumentGroup();
            connectionsGroup.Title=getString(message('physmod:ee:loadflow:ConnectionsGroupName'));
            connectionsGroup.Tag="ConnectionsTable";
            connectionsGroup.DefaultRegion='bottom';
            app.add(connectionsGroup);


            figOptions.Title=getString(message('physmod:ee:loadflow:BusbarTableName'));
            figOptions.Tag="Busbars";
            figOptions.DocumentGroupTag=nodesAndBusbarsGroup.Tag;
            documentBusbars=matlab.ui.internal.FigureDocument(figOptions);
            documentBusbars.Closable=false;
            app.add(documentBusbars);


            figOptions=struct;
            figOptions.Title=getString(message('physmod:ee:loadflow:NodeTableName'));
            figOptions.Tag="Nodes";
            figOptions.DocumentGroupTag=nodesAndBusbarsGroup.Tag;
            documentNodes=matlab.ui.internal.FigureDocument(figOptions);
            documentNodes.Closable=false;
            app.add(documentNodes);


            figOptions=struct;
            figOptions.Title=getString(message('physmod:ee:loadflow:ConnectionTableName'));
            figOptions.Tag="Connections";
            figOptions.DocumentGroupTag=connectionsGroup.Tag;
            documentConnections=matlab.ui.internal.FigureDocument(figOptions);
            documentConnections.Closable=false;
            app.add(documentConnections);


            app.UIFigureNodes=documentNodes.Figure;
            app.UIFigureBusbars=documentBusbars.Figure;
            app.UIFigureConnections=documentConnections.Figure;


            app.GridLayoutNodes=uigridlayout(app.UIFigureNodes);
            app.GridLayoutNodes.ColumnWidth={'1x'};
            app.GridLayoutNodes.RowHeight={'1x'};
            app.GridLayoutBusbars=uigridlayout(app.UIFigureBusbars);
            app.GridLayoutBusbars.ColumnWidth={'1x'};
            app.GridLayoutBusbars.RowHeight={'1x'};
            app.GridLayoutConnections=uigridlayout(app.UIFigureConnections);
            app.GridLayoutConnections.ColumnWidth={'1x'};
            app.GridLayoutConnections.RowHeight={'1x'};


            app.HighlightinputsintableCheckBox=matlab.ui.internal.toolstrip.ToggleButton(...
            getString(message('physmod:ee:loadflow:HighlightTableString')),...
            matlab.ui.internal.toolstrip.Icon.PROPERTIES_24);
            app.HighlightinputsintableCheckBox.Value=false;
            app.HighlightinputsintableCheckBox.Tag="highlightinputs";
            app.HighlightinputsintableCheckBox.Description=getString(message('physmod:ee:loadflow:HighlightinputsintableCheckBox'));
            column=prepareSection.addColumn();
            column.add(app.HighlightinputsintableCheckBox);


            app.HighlightblocksinmodelCheckBox=matlab.ui.internal.toolstrip.ToggleButton(...
            getString(message('physmod:ee:loadflow:HighlightModelString')),...
            matlab.ui.internal.toolstrip.Icon.SIMULINK_24);
            app.HighlightblocksinmodelCheckBox.Value=false;
            app.HighlightblocksinmodelCheckBox.Enabled=false;
            app.HighlightblocksinmodelCheckBox.Tag="highlightmodel";
            app.HighlightblocksinmodelCheckBox.Description=getString(message('physmod:ee:loadflow:HighlightblocksinmodelCheckBox'));
            column=prepareSection.addColumn();
            column.add(app.HighlightblocksinmodelCheckBox);


            app.RefreshButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:ee:loadflow:RefreshButton')),matlab.ui.internal.toolstrip.Icon.REFRESH_24);
            app.RefreshButton.Enabled=false;
            app.RefreshButton.Tag="refresh";
            app.RefreshButton.Description=getString(message('physmod:ee:loadflow:RefreshButtonDescription'));
            column=prepareSection.addColumn();
            column.add(app.RefreshButton);


            app.SettingsButtonGroup=matlab.ui.internal.toolstrip.ButtonGroup;


            app.SettingsFrequencyAndTime=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('physmod:ee:loadflow:SettingsFrequencyAndTime')),matlab.ui.internal.toolstrip.Icon.SETTINGS_24,app.SettingsButtonGroup);
            app.SettingsFrequencyAndTime.Description=getString(message('physmod:ee:loadflow:SettingsFrequencyAndTimeDescription'));
            app.SettingsFrequencyAndTime.Value=true;
            app.SettingsTimeAndSteadyState=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('physmod:ee:loadflow:SettingsTimeAndSteadyState')),matlab.ui.internal.toolstrip.Icon.SETTINGS_24,app.SettingsButtonGroup);
            app.SettingsTimeAndSteadyState.Description=getString(message('physmod:ee:loadflow:SettingsTimeAndSteadyStateDescription'));
            app.SettingsLocal=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('physmod:ee:loadflow:SettingsLocal')),matlab.ui.internal.toolstrip.Icon.SETTINGS_24,app.SettingsButtonGroup);
            app.SettingsLocal.Description=getString(message('physmod:ee:loadflow:SettingsLocalDescription'));


            app.SettingsCategory=matlab.ui.internal.toolstrip.GalleryCategory(getString(message('physmod:ee:loadflow:SimscapeSolverConfiguration')));
            app.SettingsCategory.add(app.SettingsFrequencyAndTime);
            app.SettingsCategory.add(app.SettingsTimeAndSteadyState);
            app.SettingsCategory.add(app.SettingsLocal);


            app.SettingsPopup=matlab.ui.internal.toolstrip.GalleryPopup('ShowSelection',true,'DisplayState','list_view');
            app.SettingsPopup.add(app.SettingsCategory);


            app.SettingsButton=matlab.ui.internal.toolstrip.DropDownGalleryButton(app.SettingsPopup,getString(message('physmod:ee:loadflow:Settings')),matlab.ui.internal.toolstrip.Icon.SETTINGS_24);
            app.SettingsButton.Tag="settings";
            app.SettingsButton.Description=getString(message('physmod:ee:loadflow:SimscapeSolverConfiguration'));


            app.SettingsSimulationConfigurationButtonGroup=matlab.ui.internal.toolstrip.ButtonGroup;


            app.SettingsStatic=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('physmod:ee:loadflow:SettingsStatic')),matlab.ui.internal.toolstrip.Icon.SETTINGS_24,app.SettingsSimulationConfigurationButtonGroup);
            app.SettingsStatic.Description=getString(message('physmod:ee:loadflow:SettingsStaticDescription'));
            app.SettingsStatic.Value=true;
            app.SettingsDynamic=matlab.ui.internal.toolstrip.ToggleGalleryItem(getString(message('physmod:ee:loadflow:SettingsDynamic')),matlab.ui.internal.toolstrip.Icon.SETTINGS_24,app.SettingsSimulationConfigurationButtonGroup);
            app.SettingsDynamic.Description=getString(message('physmod:ee:loadflow:SettingsDynamicDescription'));


            app.SettingsSimulationConfigurationCategory=matlab.ui.internal.toolstrip.GalleryCategory(getString(message('physmod:ee:loadflow:SettingsSimulationConfiguration')));
            app.SettingsSimulationConfigurationCategory.add(app.SettingsStatic);
            app.SettingsSimulationConfigurationCategory.add(app.SettingsDynamic);


            app.SettingsPopup.add(app.SettingsSimulationConfigurationCategory);


            column=simulateSection.addColumn();
            column.add(app.SettingsButton);


            app.RunButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:ee:loadflow:RunButton')),matlab.ui.internal.toolstrip.Icon.RUN_24);
            app.RunButton.Enabled=false;
            app.RunButton.Tag="run";
            app.RunButton.Description=getString(message('physmod:ee:loadflow:RunButtonDescription'));

            column=simulateSection.addColumn();
            column.add(app.RunButton);


            app.TimeSlider=matlab.ui.internal.toolstrip.Slider([0,10],0);
            app.TimeSlider.Enabled=false;
            app.TimeSlider.Tag="timeslider";
            app.TimeSlider.Description=getString(message('physmod:ee:loadflow:TimeSliderDescription'));
            column=timeSection.addColumn();
            column.add(app.TimeSlider);


            app.TimeEdit=matlab.ui.internal.toolstrip.EditField('0');
            app.TimeEdit.Enabled=false;
            app.TimeEdit.Tag="timeslider";
            app.TimeEdit.Description=getString(message('physmod:ee:loadflow:TimeEditDescription'));
            column.add(app.TimeEdit);


            app.ExportButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:ee:loadflow:ExportButton')),matlab.ui.internal.toolstrip.Icon.EXPORT_24);
            app.ExportButton.Enabled=true;
            app.ExportButton.Tag="export";
            app.ExportButton.Description=getString(message('physmod:ee:loadflow:ExportButtonDescription'));
            column=exportSection.addColumn();
            column.add(app.ExportButton);


            app.HelpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            app.HelpButton.DocName='sps/Load-Flow Analyzer';
            app.add(app.HelpButton);


            app.NodeUITable=uitable(app.GridLayoutNodes);
            app.NodeUITable.Layout.Row=1;
            app.NodeUITable.Layout.Column=1;
            app.NodeUITable.ColumnSortable=true;
            app.NodeUITable.ColumnName={...
            getString(message('physmod:ee:loadflow:BlockType'));...
            getString(message('physmod:ee:loadflow:BusType'));...
            getString(message('physmod:ee:loadflow:RatedVoltage'));...
            getString(message('physmod:ee:loadflow:SpecifiedVoltageMagnitude'));...
            getString(message('physmod:ee:loadflow:ActualVoltageMagnitude'));...
            getString(message('physmod:ee:loadflow:VoltageAngle'));...
            getString(message('physmod:ee:loadflow:SpecifiedRealGenerationP'));...
            getString(message('physmod:ee:loadflow:ActualRealGenerationP'));...
            getString(message('physmod:ee:loadflow:ActualReactiveGenerationQ'));...
            getString(message('physmod:ee:loadflow:SpecifiedRealDemandP'));...
            getString(message('physmod:ee:loadflow:ActualRealDemandP'));...
            getString(message('physmod:ee:loadflow:SpecifiedReactiveDemandQl'));...
            getString(message('physmod:ee:loadflow:SpecifiedReactiveDemandQc'));...
            getString(message('physmod:ee:loadflow:ActualReactiveDemandQ'));...
            };


            app.BusbarUITable=uitable(app.GridLayoutBusbars);
            app.BusbarUITable.Layout.Row=1;
            app.BusbarUITable.Layout.Column=1;
            app.BusbarUITable.ColumnSortable=true;
            app.BusbarUITable.ColumnName={...
            getString(message('physmod:ee:loadflow:BlockType'));...
            getString(message('physmod:ee:loadflow:RatedVoltage'));...
            getString(message('physmod:ee:loadflow:ActualVoltageMagnitude'));...
            getString(message('physmod:ee:loadflow:VoltageAngle'));...
            getString(message('physmod:ee:loadflow:RealPowerFlowP1'));...
            getString(message('physmod:ee:loadflow:ReactivePowerFlowQ1'));...
            getString(message('physmod:ee:loadflow:RealPowerFlowP2'));...
            getString(message('physmod:ee:loadflow:ReactivePowerFlowQ2'));...
            getString(message('physmod:ee:loadflow:RealPowerFlowP3'));...
            getString(message('physmod:ee:loadflow:ReactivePowerFlowQ3'));...
            getString(message('physmod:ee:loadflow:RealPowerFlowP4'));...
            getString(message('physmod:ee:loadflow:ReactivePowerFlowQ4'));...
            };


            app.ConnectionUITable=uitable(app.GridLayoutConnections);
            app.ConnectionUITable.Layout.Row=1;
            app.ConnectionUITable.Layout.Column=1;
            app.ConnectionUITable.ColumnSortable=true;
            app.ConnectionUITable.ColumnName={...
            getString(message('physmod:ee:loadflow:BlockType'));...
            getString(message('physmod:ee:loadflow:FromBusbar'));...
            getString(message('physmod:ee:loadflow:ToBusbar'));...
            getString(message('physmod:ee:loadflow:RatedVoltage'));...
            getString(message('physmod:ee:loadflow:VoltageV1'));...
            getString(message('physmod:ee:loadflow:VoltageV2'));...
            getString(message('physmod:ee:loadflow:VoltageAngle12'));...
            getString(message('physmod:ee:loadflow:RealPowerFlowP12'));...
            getString(message('physmod:ee:loadflow:ReactivePowerFlowQ12'));...
            getString(message('physmod:ee:loadflow:RealPowerFlowP21'));...
            getString(message('physmod:ee:loadflow:ReactivePowerFlowQ21'));...
            getString(message('physmod:ee:loadflow:RealPowerLoss'));...
            getString(message('physmod:ee:loadflow:ReactivePowerLoss'));...
            };


            app.StatusBar=matlab.ui.internal.statusbar.StatusBar;
            app.StatusBar.Tag='statusBar';
            app.add(app.StatusBar);
            app.StatusLabel=matlab.ui.internal.statusbar.StatusLabel('');
            app.StatusLabel.Tag='statusLabel';
            app.StatusBar.add(app.StatusLabel);



            app.Tag=matlab.lang.internal.uuid();


            app.Visible=true;


            app.WindowBounds(3:4)=[1024,768];
        end
    end
end