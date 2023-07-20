classdef View<matlab.ui.container.internal.AppContainer



    properties
        Tree matlab.ui.container.Tree
Controller
        UISignalFigure matlab.ui.Figure
        PannedSignalFigure matlab.ui.Figure
        UIHarmonicFigure matlab.ui.Figure
        UITreeFigure matlab.ui.Figure
        GridLayoutSignal matlab.ui.container.GridLayout
        GridLayoutPannedSignal matlab.ui.container.GridLayout
        GridLayoutHarmonics matlab.ui.container.GridLayout
        GridLayoutUITree matlab.ui.container.GridLayout
UISignalAxes
PannedSignalAxes
UIHarmonicAxes
        ImportButton matlab.ui.internal.toolstrip.Button
        NoOfPeriodsSpinner matlab.ui.internal.toolstrip.Spinner
        DCOffsetSpinner matlab.ui.internal.toolstrip.Spinner
        HarmonicOrderSpinner matlab.ui.internal.toolstrip.Spinner
        SimTime matlab.ui.internal.toolstrip.EditField
        NoOfPeriodsLabel matlab.ui.internal.toolstrip.Label
        DCOffsetLabel matlab.ui.internal.toolstrip.Label
        HarmonicOrderLabel matlab.ui.internal.toolstrip.Label
        SimTimeLabel matlab.ui.internal.toolstrip.Label
        StatusBar matlab.ui.internal.statusbar.StatusBar
        StatusLabel matlab.ui.internal.statusbar.StatusLabel
        ExportButtonGroup matlab.ui.internal.toolstrip.ButtonGroup
        ExportAsScript matlab.ui.internal.toolstrip.ToggleGalleryItem
        ExportAsFunction matlab.ui.internal.toolstrip.ToggleGalleryItem
        ExportCategory matlab.ui.internal.toolstrip.GalleryCategory
        ExportPopup matlab.ui.internal.toolstrip.GalleryPopup
        ExportButton matlab.ui.internal.toolstrip.DropDownGalleryButton
        HelpButton matlab.ui.internal.toolstrip.qab.QABHelpButton
    end

    methods(Access=public)
        function app=View()



            appOptions.Tag="ee_harmonicAnalyzer";
            appOptions.Title=getString(message('physmod:ee:harmonicAnalyzer:AppTitle'));
            app@matlab.ui.container.internal.AppContainer(appOptions);


            createComponents(app);



            app.CanCloseFcn=@(app)preClose(app);

            if nargout==0
                clear('app');
            end
        end

        function delete(app)
            app.close;
        end

        function value=preClose(~)
            close(findall(0,'Type','Figure','Name','Error Dialog'));
            value=1;
        end

        function createComponents(app)


            tabGroup=matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag="mainTabGroup";

            analysisTab=matlab.ui.internal.toolstrip.Tab(getString(message('physmod:ee:harmonicAnalyzer:AppTitle')));
            analysisTab.Tag="mainTab";

            tabGroup.add(analysisTab);
            app.add(tabGroup);

            inputSection=analysisTab.addSection(getString(message('physmod:ee:harmonicAnalyzer:InputSection')));
            inputSection.Tag=getString(message('physmod:ee:harmonicAnalyzer:InputSection'));

            optionsSection=analysisTab.addSection(getString(message('physmod:ee:harmonicAnalyzer:OptionsSection')));
            optionsSection.Tag=getString(message('physmod:ee:harmonicAnalyzer:OptionsSection'));

            analyzeSection=analysisTab.addSection(getString(message('physmod:ee:harmonicAnalyzer:OutputSection')));
            analyzeSection.Tag=getString(message('physmod:ee:harmonicAnalyzer:OutputSection'));


            app.ImportButton=matlab.ui.internal.toolstrip.Button...
            (getString(message('physmod:ee:harmonicAnalyzer:ImportButton')),...
            matlab.ui.internal.toolstrip.Icon.IMPORT_24);
            app.ImportButton.Enabled=true;
            app.ImportButton.Tag="import";
            app.ImportButton.Description=getString(message('physmod:ee:harmonicAnalyzer:ImportButtonDescription'));
            column=inputSection.addColumn();
            column.add(app.ImportButton);


            noOfPeriodsspinner=matlab.ui.internal.toolstrip.Spinner([1,1000],10);
            noOfPeriodsspinner.StepSize=1;
            noOfPeriodsspinner.Description=getString(message('physmod:ee:harmonicAnalyzer:PeriodsSpinnerDescription'));
            noOfPeriodsspinner.DecimalFormat='0f';

            noOfPeriodsspinner.Tag='NoOfPeriodsSpinner';
            app.NoOfPeriodsSpinner=noOfPeriodsspinner;

            noOfPeriodsLabel=matlab.ui.internal.toolstrip.Label(getString(message('physmod:ee:harmonicAnalyzer:PeriodsLabel')));
            noOfPeriodsLabel.Tag='NoOfPeriodsLabel';
            noOfPeriodsLabel.Description=getString(message('physmod:ee:harmonicAnalyzer:PeriodsLabelDescription'));
            app.NoOfPeriodsLabel=noOfPeriodsLabel;


            dcOffsetspinner=matlab.ui.internal.toolstrip.Spinner(...
            [-realmax,realmax],0);
            dcOffsetspinner.StepSize=1;
            dcOffsetspinner.Description=getString(message('physmod:ee:harmonicAnalyzer:PeriodsLabelDescription'));
            dcOffsetspinner.DecimalFormat='0f';
            dcOffsetspinner.Tag='DCOffsetSpinner';
            app.DCOffsetSpinner=dcOffsetspinner;

            dcOffsetLabel=matlab.ui.internal.toolstrip.Label(...
            getString(message('physmod:ee:harmonicAnalyzer:DCOffsetLabel')));
            dcOffsetLabel.Tag='DCOffsetLabel';
            dcOffsetLabel.Description=getString(message('physmod:ee:harmonicAnalyzer:DCOffsetLabelDescription'));
            app.DCOffsetLabel=dcOffsetLabel;


            harmonicOrderspinner=matlab.ui.internal.toolstrip.Spinner([1,1000],20);
            harmonicOrderspinner.StepSize=1;
            harmonicOrderspinner.Description=getString(message('physmod:ee:harmonicAnalyzer:HarmonicOrderSpinnerDescription'));
            harmonicOrderspinner.DecimalFormat='0f';
            harmonicOrderspinner.Tag='HarmonicOrderSpinner';
            app.HarmonicOrderSpinner=harmonicOrderspinner;

            harmonicOrderLabel=matlab.ui.internal.toolstrip.Label(...
            getString(message('physmod:ee:harmonicAnalyzer:HarmonicOrderLabel')));
            harmonicOrderLabel.Tag='HarmonicOrderLabel';
            harmonicOrderLabel.Description=getString(message('physmod:ee:harmonicAnalyzer:HarmonicOrderLabelDescription'));
            app.HarmonicOrderLabel=harmonicOrderLabel;


            simTimeEditField=matlab.ui.internal.toolstrip.EditField;
            simTimeEditField.Description=getString(message('physmod:ee:harmonicAnalyzer:SimTimeEditFieldDescription'));
            simTimeEditField.Tag='SimTimeEditField';
            app.SimTime=simTimeEditField;

            simTimeLabel=matlab.ui.internal.toolstrip.Label(...
            getString(message('physmod:ee:harmonicAnalyzer:SimTimeLabel')));
            simTimeLabel.Tag='SimTimeLabel';
            simTimeLabel.Description=getString(message('physmod:ee:harmonicAnalyzer:SimTimeLabelDescription'));
            app.SimTimeLabel=simTimeLabel;

            column=optionsSection.addColumn;
            column.add(app.NoOfPeriodsLabel);
            column.add(app.DCOffsetLabel);
            column.add(app.HarmonicOrderLabel)

            column=optionsSection.addColumn;
            column.add(app.NoOfPeriodsSpinner);
            column.add(app.DCOffsetSpinner);
            column.add(app.HarmonicOrderSpinner);

            column=optionsSection.addColumn;
            column.add(app.SimTimeLabel);

            column=optionsSection.addColumn;
            column.add(app.SimTime);


            app.ExportButtonGroup=matlab.ui.internal.toolstrip.ButtonGroup;


            app.ExportAsScript=matlab.ui.internal.toolstrip.ToggleGalleryItem(...
            getString(message('physmod:ee:harmonicAnalyzer:ExportAsScript')),...
            matlab.ui.internal.toolstrip.Icon.EXPORT_24,app.ExportButtonGroup);
            app.ExportAsScript.Description=getString(...
            message('physmod:ee:harmonicAnalyzer:ExportAsScriptDescription'));

            app.ExportAsFunction=matlab.ui.internal.toolstrip.ToggleGalleryItem(...
            getString(message('physmod:ee:harmonicAnalyzer:ExportAsFunction')),...
            matlab.ui.internal.toolstrip.Icon.EXPORT_24,app.ExportButtonGroup);
            app.ExportAsFunction.Description=getString(...
            message('physmod:ee:harmonicAnalyzer:ExportAsFunctionDescription'));


            app.ExportCategory=matlab.ui.internal.toolstrip.GalleryCategory(...
            getString(message('physmod:ee:harmonicAnalyzer:ExportCategory')));
            app.ExportCategory.add(app.ExportAsScript);
            app.ExportCategory.add(app.ExportAsFunction);


            app.ExportPopup=matlab.ui.internal.toolstrip.GalleryPopup(...
            'ShowSelection',true,'DisplayState','list_view');
            app.ExportPopup.add(app.ExportCategory);


            app.ExportButton=matlab.ui.internal.toolstrip.DropDownGalleryButton(...
            app.ExportPopup,getString(...
            message('physmod:ee:harmonicAnalyzer:ExportButton')),...
            matlab.ui.internal.toolstrip.Icon.EXPORT_24);
            app.ExportButton.Tag="settings";
            app.ExportButton.Description=getString(...
            message('physmod:ee:harmonicAnalyzer:ExportButtonDescription'));


            column=analyzeSection.addColumn();
            column.add(app.ExportButton);


            app.HelpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            app.HelpButton.DocName='sps/Harmonic Analyzer';
            app.add(app.HelpButton);


            signalGroup=matlab.ui.internal.FigureDocumentGroup();
            signalGroup.Title=getString(message('physmod:ee:harmonicAnalyzer:SignalGroupTitle'));
            signalGroup.Tag="SignalPlot";
            app.add(signalGroup);


            signalFigure=matlab.ui.internal.FigureDocument;
            signalFigure.Title=getString(message('physmod:ee:harmonicAnalyzer:SignalFigureTitle'));
            signalFigure.Tag="SignalPlot";
            signalFigure.Closable=false;
            signalFigure.DocumentGroupTag=signalGroup.Tag;
            app.add(signalFigure);
            app.UISignalFigure=signalFigure.Figure;


            pannedSignalGroup=matlab.ui.internal.FigureDocumentGroup();
            pannedSignalGroup.Title=getString(message('physmod:ee:harmonicAnalyzer:PannedSignalGroupTitle'));
            pannedSignalGroup.Tag="PannedSignalPlot";
            app.add(pannedSignalGroup);


            pannedSignalFigure=matlab.ui.internal.FigureDocument;
            pannedSignalFigure.Title=getString(message('physmod:ee:harmonicAnalyzer:PannedSignalFigureTitle'));
            pannedSignalFigure.Tag="PannedSignalPlot";
            pannedSignalFigure.Closable=false;
            pannedSignalFigure.DocumentGroupTag=pannedSignalGroup.Tag;
            app.add(pannedSignalFigure);
            app.PannedSignalFigure=pannedSignalFigure.Figure;


            harmonicGroup=matlab.ui.internal.FigureDocumentGroup();
            harmonicGroup.Title=getString(message('physmod:ee:harmonicAnalyzer:HarmonicGroupTitle'));
            harmonicGroup.Tag="HarmonicPlot";
            app.add(harmonicGroup);


            harmonicFigure=matlab.ui.internal.FigureDocument;
            harmonicFigure.Title=getString(message('physmod:ee:harmonicAnalyzer:HarmonicFigureTitle'));
            harmonicFigure.Tag="HarmonicPlot";
            harmonicFigure.Closable=false;
            harmonicFigure.DocumentGroupTag=harmonicGroup.Tag;
            app.add(harmonicFigure);
            app.UIHarmonicFigure=harmonicFigure.Figure;


            UITreeGroup=matlab.ui.internal.FigureDocumentGroup();
            UITreeGroup.Title=getString(message('physmod:ee:harmonicAnalyzer:SimDataGroupTitle'));
            UITreeGroup.Tag="UITree";
            app.add(UITreeGroup);


            uiTreeFigure=matlab.ui.internal.FigureDocument;
            uiTreeFigure.Title=getString(message('physmod:ee:harmonicAnalyzer:SimDataFigureTitle'));
            uiTreeFigure.Tag="UITree";
            uiTreeFigure.Closable=false;
            uiTreeFigure.DocumentGroupTag=UITreeGroup.Tag;
            app.add(uiTreeFigure);
            app.UITreeFigure=uiTreeFigure.Figure;



            documentLayout=struct;
            documentLayout.gridDimensions.w=3;
            documentLayout.gridDimensions.h=2;
            documentLayout.tileCount=4;
            documentLayout.columnWeights=[0.25,0.375,0.375];
            documentLayout.rowWeights=[0.5,0.5];
            documentLayout.tileCoverage=[1,2,3;1,4,4];
            document1State.id="UITree_UITree";
            document2State.id="PannedSignalPlot_PannedSignalPlot";
            document3State.id="HarmonicPlot_HarmonicPlot";
            document4State.id="SignalPlot_SignalPlot";
            tile1Children=document1State;
            tile2Children=document2State;
            tile3Children=document3State;
            tile4Children=document4State;
            tile1Occupancy.children=tile1Children;
            tile2Occupancy.children=tile2Children;
            tile3Occupancy.children=tile3Children;
            tile4Occupancy.children=tile4Children;
            documentLayout.tileOccupancy=[tile1Occupancy,tile2Occupancy,tile3Occupancy,tile4Occupancy];
            app.DocumentLayout=documentLayout;


            app.GridLayoutSignal=uigridlayout(app.UISignalFigure);
            app.GridLayoutSignal.ColumnWidth={'1x'};
            app.GridLayoutSignal.RowHeight={'1x'};

            app.GridLayoutPannedSignal=uigridlayout(app.PannedSignalFigure);
            app.GridLayoutPannedSignal.ColumnWidth={'1x'};
            app.GridLayoutPannedSignal.RowHeight={'1x'};

            app.GridLayoutHarmonics=uigridlayout(app.UIHarmonicFigure);
            app.GridLayoutHarmonics.ColumnWidth={'1x'};
            app.GridLayoutHarmonics.RowHeight={'1x'};

            app.GridLayoutUITree=uigridlayout(app.UITreeFigure);
            app.GridLayoutUITree.ColumnWidth={'1x'};
            app.GridLayoutUITree.RowHeight={'1x'};


            app.UISignalAxes=uiaxes(app.GridLayoutSignal);
            app.UISignalAxes.Position=[10,10,400,200];
            app.UISignalAxes.Layout.Row=[1,30];
            app.UISignalAxes.Layout.Column=[1,5];


            app.PannedSignalAxes=uiaxes(app.GridLayoutPannedSignal);
            app.PannedSignalAxes.Position=[10,10,400,200];
            app.PannedSignalAxes.Layout.Row=[1,30];
            app.PannedSignalAxes.Layout.Column=[1,5];


            app.UIHarmonicAxes=uiaxes(app.GridLayoutHarmonics);
            app.UIHarmonicAxes.Layout.Row=[1,30];
            app.UIHarmonicAxes.Layout.Column=[1,5];


            app.Tree=uitree(app.GridLayoutUITree);
            app.Tree.Layout.Row=[1,9];
            app.Tree.Layout.Column=1;


            app.StatusBar=matlab.ui.internal.statusbar.StatusBar;
            app.StatusBar.Tag='statusBar';
            app.add(app.StatusBar);
            app.StatusLabel=matlab.ui.internal.statusbar.StatusLabel('');
            app.StatusLabel.Tag='statusLabel';
            app.StatusBar.add(app.StatusLabel);



            app.Tag=matlab.lang.internal.uuid();

            app.WindowBounds(3:4)=[1200,825];
            app.Visible=true;
        end
    end
end
