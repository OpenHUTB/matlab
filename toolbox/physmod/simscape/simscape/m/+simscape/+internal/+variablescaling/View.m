classdef View<matlab.ui.container.internal.AppContainer




    properties
        FigureVisual matlab.ui.Figure;
        FigureTextual matlab.ui.Figure;
        FigureMessage matlab.ui.Figure;
        FigureWarning matlab.ui.Figure;
        GridTextual matlab.ui.container.GridLayout;
        GridMessage matlab.ui.container.GridLayout;
        GridWarning matlab.ui.container.GridLayout;
        MessageArea matlab.ui.control.TextArea;
        WarningArea matlab.ui.control.TextArea;
        OpenModelButton matlab.ui.internal.toolstrip.Button;
        AttachModelButton matlab.ui.internal.toolstrip.Button;
        RunButton matlab.ui.internal.toolstrip.Button;
        SettingsButton matlab.ui.internal.toolstrip.Button;
        NomValsButton matlab.ui.internal.toolstrip.Button;
        PIButton matlab.ui.internal.toolstrip.Button;
        PlotButton matlab.ui.internal.toolstrip.Button;
        HelpButton matlab.ui.internal.toolstrip.qab.QABHelpButton;
        StatusBar matlab.ui.internal.statusbar.StatusBar;
        StatusLabel matlab.ui.internal.statusbar.StatusLabel;
        TabulatedData matlab.ui.control.Table;
        HighlightStyle matlab.ui.style.Style;
    end

    methods
        function app=View()
            appOptions.Tag="SimscapeVariableScalingAnalyzer";
            appOptions.Title=getString(message('physmod:simscape:simscape:variablescaling:AnalyzerName'));
            app@matlab.ui.container.internal.AppContainer(appOptions);


            createComponents(app);
        end

        function delete(obj)
            obj.close;
            delete(obj.TabulatedData);
            delete(obj.StatusLabel);
            delete(obj.StatusBar);
            delete(obj.HelpButton);
            delete(obj.PlotButton);
            delete(obj.SettingsButton);
            delete(obj.NomValsButton);
            delete(obj.PIButton);
            delete(obj.RunButton);
            delete(obj.OpenModelButton);
            delete(obj.AttachModelButton);
            delete(obj.MessageArea);
            delete(obj.WarningArea);
            delete(obj.GridMessage);
            delete(obj.GridWarning);
            delete(obj.GridTextual);
            delete(obj.FigureMessage);
            delete(obj.FigureWarning);
            delete(obj.FigureTextual);
            delete(obj.FigureVisual);
        end
    end

    methods(Access=private)
        function createComponents(app)

            tabGroup=matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag="mainTabGroup";
            tab=matlab.ui.internal.toolstrip.Tab(getString(message('physmod:simscape:simscape:variablescaling:AnalyzerTab')));
            tab.Tag="mainTab";
            tabGroup.add(tab);
            app.add(tabGroup);
            attachSection=tab.addSection(getString(message('physmod:simscape:simscape:variablescaling:AttachTab')));
            attachSection.Tag="attachSection";
            modifySection=tab.addSection(getString(message('physmod:simscape:simscape:variablescaling:ModifyTab')));
            modifySection.Tag="modifySection";
            simulateSection=tab.addSection(getString(message('physmod:simscape:simscape:variablescaling:SimulateTab')));
            simulateSection.Tag="simulateSection";
            plotSection=tab.addSection(getString(message('physmod:simscape:simscape:variablescaling:PlotTab')));
            plotSection.Tag="plotSection";


            group=matlab.ui.internal.FigureDocumentGroup();
            group.Title="Information";
            group.Tag="documentGroup";
            app.add(group);


            visualOptions.Title=getString(message('physmod:simscape:simscape:variablescaling:VisualTab'));
            visualOptions.DocumentGroupTag=group.Tag;
            visualData=matlab.ui.internal.FigureDocument(visualOptions);
            visualData.Closable=false;
            visualData.Tag="visualData";
            app.add(visualData);


            textualOptions.Title=getString(message('physmod:simscape:simscape:variablescaling:DataTab'));
            textualOptions.DocumentGroupTag=group.Tag;
            textualData=matlab.ui.internal.FigureDocument(textualOptions);
            textualData.Closable=false;
            textualData.Tag="textualData";
            app.add(textualData);


            messageOptions.Title=getString(message('physmod:simscape:simscape:variablescaling:MessageTab'));
            messageOptions.DocumentGroupTag=group.Tag;
            messageData=matlab.ui.internal.FigureDocument(messageOptions);
            messageData.Closable=false;
            messageData.Tag="messageData";
            app.add(messageData);


            warningOptions.Title=getString(message('physmod:simscape:simscape:variablescaling:DiagTab'));
            warningOptions.DocumentGroupTag=group.Tag;
            warningData=matlab.ui.internal.FigureDocument(warningOptions);
            warningData.Closable=false;
            warningData.Tag="warningData";
            app.add(warningData);


            app.FigureVisual=visualData.Figure;
            app.FigureTextual=textualData.Figure;
            app.FigureMessage=messageData.Figure;
            app.FigureWarning=warningData.Figure;


            app.GridTextual=uigridlayout(app.FigureTextual);
            app.GridTextual.ColumnWidth={'1x'};
            app.GridTextual.RowHeight={'1x'};


            app.GridMessage=uigridlayout(app.FigureMessage);
            app.GridMessage.ColumnWidth={'1x'};
            app.GridMessage.RowHeight={'1x'};


            app.GridWarning=uigridlayout(app.FigureWarning);
            app.GridWarning.ColumnWidth={'1x'};
            app.GridWarning.RowHeight={'1x'};


            app.OpenModelButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:simscape:simscape:variablescaling:OpenModel')),matlab.ui.internal.toolstrip.Icon.OPEN_24);
            app.OpenModelButton.Enabled=true;
            app.OpenModelButton.Tag="openModel";
            app.OpenModelButton.Description=getString(message('physmod:simscape:simscape:variablescaling:OpenModelDescription'));
            column=attachSection.addColumn();
            column.add(app.OpenModelButton);


            app.AttachModelButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:simscape:simscape:variablescaling:AttachModel')),matlab.ui.internal.toolstrip.Icon.ADD_24);
            app.AttachModelButton.Enabled=true;
            app.AttachModelButton.Tag="attachModel";
            app.AttachModelButton.Description=getString(message('physmod:simscape:simscape:variablescaling:AttachModelDescription'));
            column=attachSection.addColumn();
            column.add(app.AttachModelButton);


            app.RunButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:simscape:simscape:variablescaling:Run')),matlab.ui.internal.toolstrip.Icon.RUN_24);
            app.RunButton.Enabled=false;
            app.RunButton.Tag="runModel";
            app.RunButton.Description=getString(message('physmod:simscape:simscape:variablescaling:RunDescription'));
            column=simulateSection.addColumn();
            column.add(app.RunButton);


            app.SettingsButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:simscape:simscape:variablescaling:ModelSettings')),matlab.ui.internal.toolstrip.Icon.SETTINGS_24);
            app.SettingsButton.Enabled=false;
            app.SettingsButton.Tag="modelSettings";
            app.SettingsButton.Description=getString(message('physmod:simscape:simscape:variablescaling:ModelSettingsDescription'));
            column=modifySection.addColumn();
            column.add(app.SettingsButton);


            app.NomValsButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:simscape:simscape:variablescaling:NominalValues')),matlab.ui.internal.toolstrip.Icon.PROPERTIES_24);
            app.NomValsButton.Enabled=false;
            app.NomValsButton.Tag="nominalValueSettings";
            app.NomValsButton.Description=getString(message('physmod:simscape:simscape:variablescaling:NominalValuesDescription'));
            column=modifySection.addColumn();
            column.add(app.NomValsButton);


            iconPath=fullfile(matlabroot,'toolbox','physmod','simscape','simscape','m','resources','openPropertyInspector_24.png');
            app.PIButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:simscape:simscape:variablescaling:PropertyInspector')),matlab.ui.internal.toolstrip.Icon(iconPath));
            app.PIButton.Enabled=false;
            app.PIButton.Tag="propertyInspector";
            app.PIButton.Description=getString(message('physmod:simscape:simscape:variablescaling:PropertyInspectorDescription'));
            column=modifySection.addColumn();
            column.add(app.PIButton);


            app.PlotButton=matlab.ui.internal.toolstrip.Button(getString(message('physmod:simscape:simscape:variablescaling:PlotState')),matlab.ui.internal.toolstrip.Icon.PLOT_24);
            app.PlotButton.Enabled=false;
            app.PlotButton.Tag="plotModel";
            app.PlotButton.Description=getString(message('physmod:simscape:simscape:variablescaling:PlotStateDescription'));
            column=plotSection.addColumn();
            column.add(app.PlotButton);


            app.HelpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            app.HelpButton.DocName='simscape/Simscape Variable Scaling Analyzer';
            app.add(app.HelpButton);


            app.StatusBar=matlab.ui.internal.statusbar.StatusBar;
            app.StatusBar.Tag='statusBar';
            app.add(app.StatusBar);
            app.StatusLabel=matlab.ui.internal.statusbar.StatusLabel('');
            app.StatusLabel.Tag='statusLabel';
            app.StatusBar.add(app.StatusLabel);


            app.TabulatedData=uitable(app.GridTextual);
            app.TabulatedData.Layout.Row=1;
            app.TabulatedData.Layout.Column=1;
            app.TabulatedData.ColumnSortable=true;
            app.TabulatedData.SelectionType="row";


            app.MessageArea=uitextarea(app.GridMessage);
            app.MessageArea.Editable='off';


            app.WarningArea=uitextarea(app.GridWarning);
            app.WarningArea.Editable='off';


            documentLayout=struct;
            documentLayout.gridDimensions.w=3;
            documentLayout.gridDimensions.h=2;
            documentLayout.tileCount=4;
            documentLayout.columnWeights=[0.5,0.25,0.25];
            documentLayout.rowWeights=[0.5,0.5];
            documentLayout.tileCoverage=[1,1,1;2,3,4];
            visualFigure.id="documentGroup_visualData";
            textualFigure.id="documentGroup_textualData";
            warningFigure.id="documentGroup_warningData";
            messageFigure.id="documentGroup_messageData";
            tile1.children=textualFigure;
            tile2.children=visualFigure;
            tile3.children=warningFigure;
            tile4.children=messageFigure;
            documentLayout.tileOccupancy=[tile1,tile2,tile3,tile4];
            app.DocumentLayout=documentLayout;


            app.HighlightStyle=uistyle('BackgroundColor','yellow');


            app.Visible=true;
        end
    end
end
