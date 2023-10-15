classdef PCBDesignerTool < cad.CADDesignTab ...
        & em.internal.pcbDesigner.AntennaAnalysisTab ...
        & em.internal.pcbDesigner.OptimizerViewModelWrapper






    properties
        App

        Model
        ViewModel
        View
        CanvasView
        TreeView
        PropertiesView
        Layer3DView
        SettingsView
        ValidationView
        AnalysisSettingsView
        GerberExportView
        VariablesView
        Controller

        LayerSection
        FeedViaSection
        SettingsSection
        ValidationSection

        CanvasParent

        TreeParent


        TabGroup
        FigureDocumentGroup

        TreeDocument

        CanvasDocument

        PropertiesDocument
        VariablesDocument


        Layer3DDocument
        ExploreDocument
        PatternDocument
        CurrentDocument
        AzimuthDocument
        ElevationDocument
        ImpedanceDocument
        SparameterDocument
        MeshDocument
        MeshDropDown

        SettingsFigure;
        ValidationFigure;
        AnalysisSettingsFigure;
        GerberExportFigure;

        FirstShapeNotAddedFlag = 1;
        FileName = '';
        SessionChanged = 0;
        ModelChanged = 0;
        ModelBusy

        UpdateAnalysis = [ 0, 0, 0, 0, 0, 0 ];

        VariablesManager

        DesignVarPanel
    end

    methods
        function self = PCBDesignerTool(  )
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.*;
            self.ModelBusy = 0;




            appOptions.Tag = "PCBAntennaDesigner" + "_" + matlab.lang.internal.uuid;
            appOptions.Title = "PCB Antenna Designer";

            self.App = AppContainer( 'Tag', appOptions.Tag, 'Title', appOptions.Title );


            self.VariablesManager = cad.VariablesManager;


            helpButton = matlab.ui.internal.toolstrip.qab.QABHelpButton(  );
            helpButton.DocName = 'antenna/pcbantennadesigner_app';
            self.App.add( helpButton );

            self.TabGroup = TabGroup(  );
            self.TabGroup.Tag = 'CAD2DDesign';
            self.App.add( self.TabGroup );
            createCadDesignTab( self, self.TabGroup );
            createAntennaAnalysisTab( self, self.TabGroup );

            group = FigureDocumentGroup(  );
            group.Title = "Cad2DDesigner";
            group.Tag = "CanvasGroup";
            self.App.add( group );
            self.FigureDocumentGroup = group;

            generateNewSessionView( self );
            addProgressBar( self, self.App );
            self.App.DocumentGridDimensions = [ 1, 1 ];
            self.SettingsFigure = uifigure( 'Visible', 'off' );
            self.ValidationFigure = uifigure( 'Visible', 'off' );
            self.AnalysisSettingsFigure = uifigure( 'Visible', 'off' );
            self.GerberExportFigure = uifigure( 'Visible', 'off' );
            self.App.CanCloseFcn = @( src, evt )closeApp( self );

            addViewModelAndController( self )


            disableDesignTab( self, false );
            addDesignTabListeners( self )
            figureResized( self.View( 2 ) );
            self.ModelBusy = 0;
            setExploreView( self );
            self.SessionChanged = 0;
            self.App.WindowBounds( 3 ) = 1400;
            self.App.DocumentColumnWeights = [ 0.6, 0.4 ];
            self.App.LeftWidth = 250;
            self.App.RightWidth = 250;
            defaultLayout( self );
            self.App.DocumentGridDimensions = [ 1, 1 ];
            self.ExploreDocument.Visible = true;
            self.App.WindowBounds( 3 ) = 1400;
            self.TreeDocument.Opened = 0;
            self.PropertiesDocument.Opened = 0;
            self.VariablesDocument.Opened = 0;
            self.App.Visible = true;
            sync( self, 'App' );


        end




    end


    methods


        function rtn = closeApp( self )
            if ~self.ModelBusy
                if checkValid( self, self ) && checkValid( self, self.App )

                    rtn = deleteApp( self );
                    if rtn


                        delete( self );
                    end
                end
            else
                rtn = false;
            end
        end

        function defaultLayout( self )
            self.TreeDocument.Opened = true;
            self.TreeDocument.Index = 1;
            self.PropertiesDocument.Opened = true;
            self.PropertiesDocument.Index = 2;
            self.VariablesDocument.Opened = true;
            self.VariablesDocument.Index = 3;
            sync( self, 'update' );
            self.App.DocumentGridDimensions = [ 2, 1 ];


            self.CanvasDocument.Tile = 1;
            self.Layer3DDocument.Tile = 2;
            self.ExploreDocument.Visible = false;
            self.ImpedanceDocument.Tile = 1;
            self.SparameterDocument.Tile = 1;
            self.PatternDocument.Tile = 1;
            self.CurrentDocument.Tile = 1;
            self.AzimuthDocument.Tile = 1;
            self.ElevationDocument.Tile = 1;
            self.MeshDocument.Tile = 1;
            self.App.WindowBounds( 3 ) = 1400;
            self.App.DocumentColumnWeights = [ 0.6, 0.4 ];
            self.App.LeftWidth = 250;
            self.App.RightWidth = 250;
            self.TreeDocument.Index = 1;
            self.PropertiesDocument.Index = 2;
            self.VariablesDocument.Index = 3;
            self.App.DocumentColumnWeights = [ 0.6, 0.4 ];
            sync( self, 'update' );

        end

        function disableDesignTab( self, val )
            disableDesignTab@cad.CADDesignTab( self, val );
            if val
                val = true;
            else
                val = false;
            end
            self.FileSection.Save.Button.Enabled = val;
            self.disableCadSettingsSection( val );
            self.disableFeedViaLoadSection( false );
            self.disableValidationSection( val );
            self.disableLayersSection( false );
            self.disableActions( false );
            self.disableBooleanSection( false );
        end

        function rtn = checkValid( ~, tHandle )
            if ~isempty( tHandle )
                if isvalid( tHandle )
                    rtn = true;
                else
                    rtn = false;
                end
            else
                rtn = false;
            end
        end

        function rtn = deleteApp( self )
            rtn = false;
            if checkValid( self, self.App )

                if self.SessionChanged
                    ButtonName = questdlg( 'Do you want to save the current design?',  ...
                        'Save Dialog',  ...
                        'Yes', 'No', 'Yes' );
                    switch ButtonName
                        case 'Yes'
                            issaved = saveFile( self );

                            self.bringToFront(  );
                            if issaved
                                clearCurrentSession( self.Model );
                                deleteView( self );
                                rtn = true;
                            else
                                rtn = false;
                                return ;
                            end
                        case 'No'
                            self.bringToFront(  );
                            clearCurrentSession( self.Model );
                            deleteView( self );
                            rtn = true;
                        case ''
                            self.bringToFront(  );
                            rtn = false;
                            return ;
                    end
                else
                    self.bringToFront(  );
                    clearCurrentSession( self.Model );
                    deleteView( self );
                    rtn = true;
                end

            end
        end


        function deleteView( self )
            deleteView@cad.CADDesignTab( self );
            deleteView@em.internal.pcbDesigner.AntennaAnalysisTab( self );
            self.deleteCadSettingsSection(  );
            self.deleteFeedViaLoadSection(  );
            delete( self.TabGroup );
            self.deleteLayerSection(  );
            self.deleteMeshCheckbox(  );
            self.deleteValidationSection(  );
            self.CanvasView.delete;
            self.TreeView.delete;
            self.PropertiesView.delete;
            self.Layer3DView.delete;
            self.SettingsView.delete;
            self.ValidationView.delete;
            self.AnalysisSettingsView.delete;
            self.GerberExportView.delete;


        end
        function exportToWorkspace( self )
            pass = validateDesign( self.Model );
            if ~pass
                return ;
            end
            targetObj = self.Model.createPCBObject;

            targetObjCopy = copy( targetObj );

            wsName = [ self.Model.Name ];

            accessVariable = 'pcbstack';
            labels = { [ 'Save ', accessVariable, ' Object as:' ] };

            vars = { wsName };

            values = { targetObjCopy };

            export2wsdlg( labels, vars, values );
        end

        function exportScript( self )
            pass = validateDesign( self.Model );
            if ~pass
                return ;
            end
            matlab.desktop.editor.newDocument( self.Model.genScript(  ) );
        end

        function gerberExport( self )
            pass = validateDesign( self.Model );
            if pass
                try
                    pcbObj = getPCBObject( self.Model );
                    self.GerberExportView.PCBStackObject = copy( pcbObj );
                    self.GerberExportView.createNewWriterObjWithAntenna(  );
                    valuechanged( self.GerberExportView, findall( self.GerberExportView.WriterPanel,  ...
                        'type', 'uicheckbox', 'tag', 'UseDefaultConnector' ),  - 1 );
                    setViaDiameter( self.GerberExportView, pcbObj.ViaDiameter );
                    setFeedDiameter( self.GerberExportView, pcbObj.FeedDiameter );
                    self.GerberExportView.showSettingsDialog(  );
                catch me
                    errordlg( me.message, 'Error' );
                end
            end

        end

        function importMatFileDialog( self )
            if self.SessionChanged
                ButtonName = questdlg( 'Do you want to save the current design?',  ...
                    'Save Dialog',  ...
                    'Yes', 'No', 'Yes' );
                switch ButtonName
                    case 'Yes'
                        saveFile( self );
                    case 'No'
                    case ''
                        self.bringToFront(  );
                        return ;
                end
                self.bringToFront(  );
            end

            self.App.Busy = 1;
            try
                [ filename, pathname ] = uigetfile( '*.mat*', 'Select .mat file with pcbStack object' );
                if ~( isequal( filename, 0 ) || isequal( pathname, 0 ) )
                    openFileName = fullfile( pathname, filename );
                    matfile = load( openFileName );
                    f = fields( matfile );
                    if numel( f ) > 1
                        error( getString( message( 'antenna:pcbantennadesigner:MultipleObjectsPresent', 'pcbStack' ) ) );
                    end
                    if numel( f ) == 0
                        error( getString( message( 'antenna:pcbantennadesigner:EmptyMatFile', 'pcbStack' ) ) );
                    end
                    objectVal = matfile.( f{ 1 } );
                    if isa( objectVal, 'em.internal.pcbDesigner.SessionData' )
                        error( getString( message( 'antenna:pcbantennadesigner:UseOpenSession' ) ) );
                    end
                    if ~isa( objectVal, 'pcbStack' )
                        error( getString( message( 'antenna:pcbantennadesigner:PCBStackNotFound' ) ) );
                    end

                else
                    return ;
                end
                importMatFile( self.Model, openFileName );

                setVariablesManager( self, self.Model.VariablesManager );
                setSessionView( self );
                disableDesignTab( self, true );
            catch me
                errordlg( me.message, 'Error' );
            end

            self.App.Busy = 0;
            self.FileName = '';
        end

        function importGerberDialog( self )
            if self.SessionChanged
                ButtonName = questdlg( 'Do you want to save the current design?',  ...
                    'Save Dialog',  ...
                    'Yes', 'No', 'Yes' );
                switch ButtonName
                    case 'Yes'
                        saveFile( self );
                    case 'No'
                    case ''
                        self.bringToFront(  );
                        return ;
                end
                self.bringToFront(  );
            end

            self.App.Busy = 1;
            try
                [ filename, pathname ] = uigetfile( '*.*', 'Select Top Layer, Bottom Layer, Drill File', 'MultiSelect', 'on' );
                self.bringToFront(  );
                if ~( isequal( filename, 0 ) || isequal( pathname, 0 ) )
                    openFileName = fullfile( pathname, filename );
                    if ischar( openFileName )
                        openFileName = { openFileName };
                    end
                    if numel( openFileName ) >= 4
                        error( 'Please select .gbr or .gtl file for Top Layer, .gbr or .gbl for Bottom Layer and .txt or .drl for Drill File' );
                    end
                    toplayer = {  };
                    bottomlayer = {  };
                    drillfile = {  };
                    idx = zeros( 1, numel( openFileName ) );
                    for i = 1:numel( openFileName )
                        if strcmpi( openFileName{ i }( end  - 3:end  ), '.gtl' ) || strcmpi( openFileName{ i }( end  - 3:end  ), '.gbr' )
                            if isempty( toplayer )
                                toplayer = openFileName( i );
                                idx( i ) = 1;
                            end
                        elseif strcmpi( openFileName{ i }( end  - 3:end  ), '.gbl' ) || strcmpi( openFileName{ i }( end  - 3:end  ), '.gbr' )
                            if isempty( bottomlayer )
                                bottomlayer = openFileName( i );
                                idx( i ) = 1;
                            end
                        elseif strcmpi( openFileName{ i }( end  - 3:end  ), '.txt' ) || strcmpi( openFileName{ i }( end  - 3:end  ), '.drl' )
                            if isempty( drillfile )
                                drillfile = openFileName( i );
                                idx( i ) = 1;
                            end
                        else
                            error( 'Invalid file selected. Please select .gbr or .gtl file as Top Layer, .gbr or .gbl as Bottom Layer and .txt or .drl as Drill File' );
                        end
                    end
                    openFileName = [ toplayer, bottomlayer, drillfile ];
                else
                    return ;
                end
                importgerber( self.Model, openFileName );

                setVariablesManager( self, self.Model.VariablesManager );
                setSessionView( self );
                disableDesignTab( self, true );
            catch me
                errordlg( me.message, 'Error' );
            end

            self.App.Busy = 0;
            self.FileName = '';
        end

        function openFileDialog( self )
            if self.SessionChanged
                ButtonName = questdlg( 'Do you want to save the current design?',  ...
                    'Save Dialog',  ...
                    'Yes', 'No', 'Yes' );
                switch ButtonName
                    case 'Yes'
                        saveFile( self );
                    case 'No'
                    case ''
                        self.bringToFront(  );
                        return ;
                end
                self.bringToFront(  );
            end

            self.App.Busy = 1;
            try
                [ filename, pathname ] = uigetfile( '*.mat', 'Pick a MAT file' );
                self.bringToFront(  );
                if ~( isequal( filename, 0 ) || isequal( pathname, 0 ) )
                    openFileName = fullfile( pathname, filename );
                    prevFileName = self.FileName;
                    self.FileName = openFileName;
                else

                    return ;
                end
                filedata = load( openFileName );
                f = fields( filedata );
                if numel( f ) > 1
                    error( getString( message( "antenna:pcbantennadesigner:SessionDataNotFound" ) ) );
                end
                if ~isa( filedata.( f{ 1 } ), 'em.internal.pcbDesigner.SessionData' )
                    error( getString( message( "antenna:pcbantennadesigner:SessionDataNotFound" ) ) );
                end
                openSession( self.Model, openFileName );

                setVariablesManager( self, self.Model.VariablesManager );

                setSessionView( self );
                disableDesignTab( self, true );
            catch me
                self.FileName = prevFileName;
                errordlg( me.message, 'Error' );
            end

            self.App.Busy = 0;
        end

        function set.SessionChanged( self, val )
            self.SessionChanged = val;
        end

        function newSession( self )
            if self.SessionChanged
                ButtonName = questdlg( 'Do you want to save the current design?',  ...
                    'Save Dialog',  ...
                    'Yes', 'No', 'Yes' );
                switch ButtonName
                    case 'Yes'
                        saveFile( self );
                    case 'No'
                    case ''
                        self.bringToFront(  );
                        return ;
                end
                self.bringToFront(  );
            end
            self.FileName = '';

            self.App.Busy = 1;
            openSession( self.Model, [  ] );
            disableDesignTab( self, true );
            disableLayersSection( self, false );

            setNewSessionView( self );

            setVariablesManager( self, self.Model.VariablesManager );

            self.App.Busy = 0;
        end

        function setVariablesManager( self, managerobj )
            arguments
                self
                managerobj( 1, 1 )cad.VariablesManager
            end
            self.Model.VariablesManager = managerobj;
            self.PropertiesView.VariablesManager = managerobj;
            self.VariablesManager = managerobj;
            self.VariablesView.VariablesManager = managerobj;


            self.VariablesView.updateView( 1 );
        end

        function rtn = saveFile( self )
            if strcmpi( self.FileName, '' )
                rtn = saveAsFileDialog( self );
            else
                saveSession( self.Model, self.FileName );
                rtn = true;
            end
        end
        function rtn = saveAsFileDialog( self )
            [ filename, pathname ] = uiputfile( '*.mat', 'Pick a MAT file' );
            self.bringToFront(  );
            if ~( isequal( filename, 0 ) || isequal( pathname, 0 ) )
                saveFileName = fullfile( pathname, filename );
                self.FileName = saveFileName;
                rtn = true;
            else
                rtn = false;
                return ;
            end

            saveSession( self.Model, saveFileName );
        end


        function createCadDesignTab( self, tabGrp )
            self.createDesignTab( tabGrp );
            self.addFileSection(  )
            self.addLayerSection(  )
            self.addShapeGallerySection(  )
            self.addBooleanSection(  )
            self.addFeedViaLoadSection(  )
            self.addActionsSection(  )
            self.addCadSettingsSection(  )
            addValidationSection( self );
            addViewSection( self );
            self.addExportSection(  )
        end

        function createAntennaAnalysisTab( self, tabGrp )
            self.createAnalysisTab( tabGrp );
            self.addFrequencySection(  );
            self.addMeshSection(  );
            self.addVectorAnalysisSection(  );
            self.addScalarAnalysisSection(  );
            self.addSettingsSection(  );
            self.addUpdatePlotsSection(  );
            self.addOptimizerSection(  );
            self.addAnalysisExportSection(  )
            self.FrequencySection.PlotFrequencyEditField.Value = '1';
            self.FrequencySection.PlotFrequencyUnitDropdown.Value = 'GHz';
            self.FrequencySection.FrequencyRangeUnitDropdown.Value = 'GHz';
            self.FrequencySection.FrequencyRangeEditField.Value = '0.9:0.01:1.1';
            self.UpdatePlots.Enabled = false;
        end

        function addLayerSection( self )
            import matlab.ui.internal.toolstrip.*
            section = self.DesignTab.addSection( "Layers" );
            self.LayerSection.Section = section;
            column = self.LayerSection.Section.addColumn(  );
            self.LayerSection.Column1 = column;
            button = SplitButton( [ 'Add', newline, 'Layer' ], Icon( fullfile( self.IconPath, 'addLayer_24.png' ) ) );
            button.Tag = 'Layers';
            button.Description = getString( message( 'antenna:pcbantennadesigner:AddLayer' ) );
            add( column, button );
            self.LayerSection.AddLayer = button;
            button.Enabled = false;
            button.Popup = PopupList;
            l = ListItem( 'Metal Layer' );
            l.Tag = 'Metal Layer';
            l.Description = getString( message( 'antenna:pcbantennadesigner:MetalLayer' ) );
            button.Popup.add( l );
            self.LayerSection.MetalLayer = l;
            l = ListItem( 'Dielectric Layer' );
            button.Popup.add( l );
            l.Tag = 'Dielectric Layer';
            l.Description = getString( message( 'antenna:pcbantennadesigner:DielectricLayer' ) );
            self.LayerSection.DielectricLayer = l;

            column = self.LayerSection.Section.addColumn(  );
            self.LayerSection.Column2 = column;
            button = Button( 'Move Up', Icon( fullfile( self.IconPath, 'up_16.png' ) ) );
            add( column, button );
            self.LayerSection.MoveUp = button;
            button.Enabled = false;
            button.Tag = 'Move Up';
            button.Description = getString( message( 'antenna:pcbantennadesigner:MoveUp' ) );

            button = Button( 'Move Down', Icon( fullfile( self.IconPath, 'down_16.png' ) ) );
            add( column, button );
            self.LayerSection.MoveDown = button;
            button.Enabled = false;
            button.Tag = 'Move Down';
            button.Description = getString( message( 'antenna:pcbantennadesigner:MoveDown' ) );
        end

        function deleteLayerSection( self )
            self.LayerSection.Section.delete;
            self.LayerSection.Column1.delete;
            self.LayerSection.AddLayer.delete;
            self.LayerSection.MetalLayer.delete;
            self.LayerSection.DielectricLayer.delete;
            self.LayerSection.Column2.delete;
            self.LayerSection.MoveUp.delete;
            self.LayerSection.MoveDown.delete;

        end

        function disableLayersSection( self, val )
            if val
                val = true;
            else
                val = false;
            end
            self.LayerSection.Addlayer.Enabled = val;
            self.LayerSection.MoveUp.Enabled = val;
            self.LayerSection.MoveDown.Enabled = val;
        end

        function addCadSettingsSection( self )
            import matlab.ui.internal.toolstrip.*
            section = self.DesignTab.addSection( "Settings" );
            self.SettingsSection.Section = section;
            column = self.SettingsSection.Section.addColumn(  );
            self.SettingsSection.Column = column;
            button = Button( [ 'Canvas', newline, 'Settings' ], Icon( fullfile( self.IconPath, 'settings_24.png' ) ) );
            button.Tag = 'Settings';
            button.Description = getString( message( 'antenna:pcbantennadesigner:SettingsButton' ) );
            add( column, button );
            self.SettingsSection.Settings = button;
        end

        function deleteCadSettingsSection( self )
            self.SettingsSection.Section.delete;
            self.SettingsSection.Column.delete;
            self.SettingsSection.Settings.delete;
        end

        function disableCadSettingsSection( self, val )
            if val
                val = true;
            else
                val = false;
            end
            self.SettingsSection.Settings.Enabled = val;
        end

        function addValidationSection( self )
            import matlab.ui.internal.toolstrip.*
            section = self.DesignTab.addSection( "Validate" );
            self.ValidationSection.Section = section;
            column = self.ValidationSection.Section.addColumn(  );
            self.ValidationSection.Column = column;
            button = Button( [ 'Validate', newline, 'Design' ], Icon( fullfile( self.IconPath, 'proveProperties_24.png' ) ) );
            button.Tag = 'Validate';
            button.Description = getString( message( 'antenna:pcbantennadesigner:ValidateDesign' ) );
            add( column, button );
            self.ValidationSection.Validate = button;
        end

        function deleteValidationSection( self )
            self.ValidationSection.Section.delete;
            self.ValidationSection.Column.delete;
            self.ValidationSection.Validate.delete;
        end

        function disableValidationSection( self, val )
            if val
                val = true;
            else
                val = false;
            end
            self.ValidationSection.Validate.Enabled = val;
        end
        function addFeedViaLoadSection( self )
            import matlab.ui.internal.toolstrip.*
            section = self.DesignTab.addSection( "Feed Via" );
            self.FeedViaSection.Section = section;
            column = self.FeedViaSection.Section.addColumn(  );
            self.FeedViaSection.Column = column;
            button = Button( 'Add Feed', Icon( fullfile( self.IconPath, 'addFeed_16.png' ) ) );
            add( column, button );
            self.FeedViaSection.Feed = button;
            button.Enabled = false;
            button.Tag = 'Feed';
            button.Description = getString( message( 'antenna:pcbantennadesigner:Feed' ) );

            button = Button( 'Add Via', Icon( fullfile( self.IconPath, 'addVia_16.png' ) ) );
            add( column, button );
            self.FeedViaSection.Via = button;
            button.Enabled = false;
            button.Tag = 'Via';
            button.Description = getString( message( 'antenna:pcbantennadesigner:Via' ) );

            button = Button( 'Add Load', Icon( fullfile( self.IconPath, 'addLoad_16.png' ) ) );
            add( column, button );
            self.FeedViaSection.Load = button;
            button.Enabled = false;
            button.Tag = 'Load';
            button.Description = getString( message( 'antenna:pcbantennadesigner:Load' ) );
        end


        function deleteFeedViaLoadSection( self )
            self.FeedViaSection.Section.delete;
            self.FeedViaSection.Column.delete;
            self.FeedViaSection.Feed.delete;
            self.FeedViaSection.Via.delete;
            self.FeedViaSection.Load.delete;
        end

        function disableFeedViaLoadSection( self, val )
            if val
                val = true;
            else
                val = false;
            end
            self.FeedViaSection.Feed.Enabled = val;
            self.FeedViaSection.Via.Enabled = val;
            self.FeedViaSection.Load.Enabled = val;
        end

        function setExploreView( self )
            self.TreeDocument.Opened = 0;
            self.PropertiesDocument.Opened = 0;
            self.VariablesDocument.Opened = 0;
            self.ExploreDocument.Visible = true;
            self.ImpedanceDocument.Visible = false;
            self.SparameterDocument.Visible = false;
            self.PatternDocument.Visible = false;
            self.CurrentDocument.Visible = false;
            self.AzimuthDocument.Visible = false;
            self.ElevationDocument.Visible = false;
            self.MeshDocument.Visible = false;
            self.CanvasDocument.Visible = false;
            self.Layer3DDocument.Visible = false;
            resetAnalysisTab( self );



            disableAnalysisTab( self, false );
            self.FrequencySection.FrequencyRangeEditField.Value = '';
            self.FrequencySection.FrequencyRangeEditField.Enabled = false;
            self.FrequencySection.PlotFrequencyEditField.Value = '';
            self.FrequencySection.PlotFrequencyEditField.Enabled = false;
            self.FrequencySection.FrequencyRangeUnitDropdown.Enabled = false;
            self.FrequencySection.PlotFrequencyUnitDropdown.Enabled = false;

        end

        function setSessionView( self )
            self.TreeDocument.Opened = 0;
            self.PropertiesDocument.Opened = 0;
            self.PropertiesDocument.Opened = true;
            self.VariablesDocument.Opened = 0;
            self.VariablesDocument.Opened = true;
            self.TreeDocument.Opened = true;
            self.TreeDocument.Index = 1;

            self.PropertiesDocument.Index = 2;
            self.VariablesDocument.Index = 3;
            sync( self, 'update' );
            self.ExploreDocument.Visible = false;
            self.ImpedanceDocument.Visible = false;
            self.SparameterDocument.Visible = false;
            self.PatternDocument.Visible = false;
            self.CurrentDocument.Visible = false;
            self.AzimuthDocument.Visible = false;
            self.ElevationDocument.Visible = false;
            self.MeshDocument.Visible = false;
            self.CanvasDocument.Visible = true;
            self.Layer3DDocument.Visible = true;
            sync( self, 'update' );
            resetAnalysisTab( self );
            self.App.DocumentGridDimensions = [ 2, 1 ];

            self.CanvasDocument.Tile = 1;
            self.Layer3DDocument.Tile = 2;
            self.App.DocumentColumnWeights = [ 0.6, 0.4 ];
            self.App.LeftWidth = 250;
            self.App.RightWidth = 250;
            self.TreeDocument.Index = 1;
            self.PropertiesDocument.Index = 2;
            self.VariablesDocument.Index = 3;
            self.App.DocumentColumnWeights = [ 0.6, 0.4 ];
            sync( self, 'update' );
            disableAnalysisTab( self, false );
            if ~isempty( self.FrequencySection.FrequencyRangeEditField.Value ) &&  ...
                    ~isempty( self.FrequencySection.PlotFrequencyEditField.Value )
                disableAnalysisTab( self, true );
                self.FrequencySection.FrequencyRangeEditField.Enabled = true;
                self.FrequencySection.PlotFrequencyEditField.Enabled = true;
                self.FrequencySection.FrequencyRangeUnitDropdown.Enabled = true;
                self.FrequencySection.PlotFrequencyUnitDropdown.Enabled = true;

            else
                self.FrequencySection.FrequencyRangeEditField.Value = '';
                self.FrequencySection.FrequencyRangeEditField.Enabled = true;
                self.FrequencySection.PlotFrequencyEditField.Value = '';
                self.FrequencySection.PlotFrequencyEditField.Enabled = true;
                self.FrequencySection.FrequencyRangeUnitDropdown.Enabled = true;
                self.FrequencySection.PlotFrequencyUnitDropdown.Enabled = true;
            end
            updateStateOfOptimizer( self );
            updateStateOfUpdatePlots( self );


        end

        function setNewSessionView( self )
            setSessionView( self );


        end

        function generateNewSessionView( self )
            import matlab.ui.internal.*;


            panelOptions.Title = "PCB Stack";
            panelOptions.Tag = "TreeView";
            panelOptions.Opened = 0;
            panel = matlab.ui.internal.FigurePanel( panelOptions );
            self.App.add( panel );
            self.TreeDocument = panel;
            panel.Figure.Scrollable = 'on';

            panelOptions.Title = "Properties";
            panelOptions.Tag = "Properties";
            panelOptions.Opened = 0;
            panel = matlab.ui.internal.FigurePanel( panelOptions );
            self.App.add( panel );
            self.PropertiesDocument = panel;
            self.PropertiesDocument.Opened = 0;
            panel.Figure.Scrollable = 'on';

            panelOptions.Title = "Design Variables";
            panelOptions.Tag = "Variables";
            panelOptions.Opened = 0;
            panel = matlab.ui.internal.FigurePanel( panelOptions );
            self.App.add( panel );
            self.VariablesDocument = panel;
            self.VariablesDocument.Opened = 0;
            panel.Figure.Scrollable = 'on';



            documentOptions.Title = "Canvas";
            documentOptions.Tag = "Canvas";

            documentOptions.DocumentGroupTag = "CanvasGroup";
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.CanvasDocument = document;
            self.CanvasDocument.Visible = false;
            document.Closable = 0;

            documentOptions.Title = "3D-View";
            documentOptions.Tag = "Layer3D";

            documentOptions.DocumentGroupTag = "CanvasGroup";
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.Layer3DDocument = document;
            self.Layer3DDocument.Visible = false;
            document.Closable = 0;

            documentOptions.Title = "Pattern3D";
            documentOptions.Tag = "pattern3D";

            documentOptions.DocumentGroupTag = "CanvasGroup";
            documentOptions.Tile = 1;
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.PatternDocument = document;
            self.PatternDocument.Visible = false;
            document.Closable = 0;

            documentOptions.Title = "Pattern Azimuth";
            documentOptions.Tag = "patternAzimuth";
            documentOptions.Tile = 1;
            documentOptions.DocumentGroupTag = "CanvasGroup";
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.AzimuthDocument = document;
            self.AzimuthDocument.Visible = false;
            document.Closable = 0;

            documentOptions.Title = "Pattern Elevation";
            documentOptions.Tag = "patternElevation";

            documentOptions.Tile = 1;
            documentOptions.DocumentGroupTag = "CanvasGroup";
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.ElevationDocument = document;
            self.ElevationDocument.Visible = false;
            document.Closable = 0;

            documentOptions.Title = "Current";
            documentOptions.Tag = "current";

            documentOptions.DocumentGroupTag = "CanvasGroup";
            documentOptions.Tile = 1;
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.CurrentDocument = document;
            self.CurrentDocument.Visible = false;
            document.Closable = 0;

            documentOptions.Title = "Mesh";
            documentOptions.Tag = "mesh";

            documentOptions.DocumentGroupTag = "CanvasGroup";
            documentOptions.Tile = 1;
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.MeshDocument = document;
            self.MeshDocument.Visible = false;
            document.Closable = 0;


            documentOptions.Title = "Impedance";
            documentOptions.Tag = "impedance";

            documentOptions.DocumentGroupTag = "CanvasGroup";
            documentOptions.Tile = 1;
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.ImpedanceDocument = document;
            self.ImpedanceDocument.Visible = false;
            document.Closable = 0;

            documentOptions.Title = "Sparameter";
            documentOptions.Tag = "sparameter";

            documentOptions.DocumentGroupTag = "CanvasGroup";
            documentOptions.Tile = 1;
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.SparameterDocument = document;
            self.SparameterDocument.Visible = false;
            document.Closable = 0;

            documentOptions.Title = "Explore";
            documentOptions.Tag = "Explore";

            documentOptions.DocumentGroupTag = "CanvasGroup";
            document = FigureDocument( documentOptions );
            self.App.add( document );
            self.ExploreDocument = document;
            self.ExploreDocument.Visible = true;
            document.Closable = 0;

            layout = uigridlayout( self.ExploreDocument.Figure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } );
            u = uilabel( 'Parent', layout, 'text',  ...
                'Click "+" New , Open or Import to start a New session',  ...
                'FontSize', 24, 'HorizontalAlignment', 'center', 'WordWrap', 'on' );

            self.App.PanelLayout.left.freeDimension = 250;

        end

        function deleteNewSessionFigures( self )
            self.TreeDocument.Figure.delete;
            self.PropertiesDocument.Figure.delete;
            self.VariablesDocument.Figure.delete;
            self.CanvasDocument.Figure.delete;
            self.Layer3DDocument.Figure.delete;
            self.PatternDocument.Figure.delete;
            self.AzimuthDocument.Figure.delete;
            self.ElevationDocument.Figure.delete;
            self.CurrentDocument.Figure.delete;
            self.ImpedanceDocument.Figure.delete;
            self.SparameterDocument.Figure.delete;
        end

        function addMeshCheckbox( self )
            fig = self.MeshDocument.Figure;

            dropdownobj = uidropdown( fig, 'Items', { 'Metal - Dielectric Mesh',  ...
                'Metal Mesh', 'Dielectric Mesh' }, 'Value', 'Metal - Dielectric Mesh',  ...
                'Position', [ 10, 10, 160, 25 ], 'Tag', 'MetalDielectricMeshDropDown' );
            dropdownobj.ValueChangedFcn = @( src, evt )updateMeshFig( self, dropdownobj.Value );
            self.MeshDropDown = dropdownobj;
            updateMeshFig( self, dropdownobj.Value );
        end

        function deleteMeshCheckbox( self )
            if checkValid( self, self.MeshDropDown )
                self.MeshDropDown.delete;
            end
        end

        function updateMeshFig( self, val )
            metalobj = findobj( self.MeshDocument.Figure, 'tag', 'metal' );
            feedobj = findobj( self.MeshDocument.Figure, 'tag', 'feed' );
            dielectricobj = findobj( self.MeshDocument.Figure, 'tag', 'dielectric' );
            subsobj = findobj( self.MeshDocument.Figure, 'tag', 'substrate' );
            if isempty( dielectricobj )
                self.MeshDropDown.Visible = 'off';
            end
            switch val
                case 'Metal - Dielectric Mesh'
                    set( metalobj, 'Visible', 'on' );
                    set( feedobj, 'Visible', 'on' );
                    set( dielectricobj, 'Visible', 'on' );
                    set( subsobj, 'Visible', 'on' );
                case 'Metal Mesh'
                    set( metalobj, 'Visible', 'on' );
                    set( feedobj, 'Visible', 'on' );
                    set( dielectricobj, 'Visible', 'off' );
                    set( subsobj, 'Visible', 'off' );
                case 'Dielectric Mesh'
                    set( metalobj, 'Visible', 'off' );
                    set( feedobj, 'Visible', 'off' );
                    set( dielectricobj, 'Visible', 'on' );
                    set( subsobj, 'Visible', 'on' );
            end
        end

        function disableAnalysisTab( self, val )
            disableAnalysisTab@em.internal.pcbDesigner.AntennaAnalysisTab( self, val );
            if val
                val = true;
            else
                val = false;
            end
            if val && self.ModelChanged
                self.UpdatePlots.Enabled = val;
            else
                self.UpdatePlots.Enabled = false;
            end
        end

        function frequencyChanged( self )
            evt.EventType = 'FrequencyChanged';
            self.Model.modelChanged = 1;
            evt.ModelInfo = getInfo( self.Model );
            modelChanged( self, evt );
            self.Model.PlotFrequency = self.PlotFrequency;
            self.Model.FrequencyRange = self.FrequencyRange;
        end



        function modelChanged( self, evt )
            if ~self.SessionChanged
                self.SessionChanged = 1;
            end
            self.ModelChanged = 1;

            if isprop( evt, 'ModelInfo' ) || isfield( evt, 'ModelInfo' )
                modelInfo = evt.ModelInfo;
            else
                modelInfo = [  ];
            end


            if strcmpi( evt.EventType, 'SessionStarted' ) || strcmpi( evt.EventType, 'SessionSaved' ) || strcmpi( evt.EventType, 'SessionCleared' )
                self.SessionChanged = 0;
            end



            if strcmpi( evt.EventType, 'Error' )
                errordlg( evt.Data, 'Error', 'modal' );
            end


            if ~isempty( modelInfo )
                if self.AnalysisEnableState && ~isempty( self.PlotFrequency ) &&  ...
                        ~isempty( self.FrequencyRange )


                    if strcmpi( self.Model.Mesh.MeshingMode, 'auto' )


                        if ~isnumeric( modelInfo.AntennaInfo.IsMeshed )
                            modelInfo.AntennaInfo.IsMeshed = strcmpi( modelInfo.AntennaInfo.IsMeshed, "true" );
                        end
                        if modelInfo.AntennaInfo.IsMeshed
                            self.MeshSection.MeshButton.Enabled = true;
                        else
                            self.MeshSection.MeshButton.Enabled = false;
                            self.MeshSection.MeshButton.Value = false;
                            self.MeshDocument.Visible = false;
                            clf( self.MeshDocument.Figure );
                        end
                    else
                        self.MeshSection.MeshButton.Enabled = true;
                    end
                else
                    self.MeshSection.MeshButton.Enabled = false;
                    self.MeshSection.MeshButton.Value = false;
                    self.MeshDocument.Visible = false;
                    self.OptimizerBtn.Enabled = false;
                    clf( self.MeshDocument.Figure );
                end
            end


            updateStateOfUpdatePlots( self )
            updateStateOfOptimizer( self )
            if ~isvalid( self.Model.Group )
                return ;
            end












        end

        function updateView( self, vm )

            modelInfo = getInfo( self.Model );



            modelInfo.AntennaInfo.IsMeshed = self.Model.IsMeshed;



            if strcmpi( self.Model.Group.MaterialType, 'Dielectric' )
                self.ShapeGallery.Gallery.Enabled = false;
            else
                self.ShapeGallery.Gallery.Enabled = true;
            end
            if numel( self.Model.ShapeStack ) > 0

                if self.FirstShapeNotAddedFlag
                    self.FirstShapeNotAddedFlag = 0;
                    self.LayerSection.AddLayer.Enabled = true;
                    self.LayerSection.MoveUp.Enabled = true;
                    self.LayerSection.MoveDown.Enabled = true;
                end
            end

            tmp = self.Model.FrequencyRange;
            tmp1 = self.Model.PlotFrequency;


            if ~isequal( self.FrequencyRange, tmp )
                self.FrequencyRange = tmp;
            end
            if ~isequal( self.PlotFrequency, tmp1 )
                self.PlotFrequency = tmp1;
            end

            updateStateOfOptimizer( self );
            if self.AnalysisEnableState && ~isempty( self.PlotFrequency ) &&  ...
                    ~isempty( self.FrequencyRange )


                if strcmpi( self.Model.Mesh.MeshingMode, 'auto' )


                    if ~isnumeric( modelInfo.AntennaInfo.IsMeshed )

                        modelInfo.AntennaInfo.IsMeshed = strcmpi( modelInfo.AntennaInfo.IsMeshed, "true" );
                    end
                    if modelInfo.AntennaInfo.IsMeshed
                        self.MeshSection.MeshButton.Enabled = true;
                    else
                        self.MeshSection.MeshButton.Enabled = false;
                        self.MeshSection.MeshButton.Value = false;
                        self.MeshDocument.Visible = false;
                        clf( self.MeshDocument.Figure );
                    end
                else
                    self.MeshSection.MeshButton.Enabled = true;
                end
            else
                self.MeshSection.MeshButton.Enabled = false;
                self.MeshSection.MeshButton.Value = false;
                self.MeshDocument.Visible = false;
                self.OptimizerBtn.Enabled = false;
                clf( self.MeshDocument.Figure );
            end



            if ~isempty( modelInfo )

                try
                    if modelInfo.ClipBoardSize > 0
                        self.Actions.Paste.Enabled = true;
                    else
                        self.Actions.Paste.Enabled = false;
                    end
                catch me
                end

                if modelInfo.ActionsSize > 0
                    self.Actions.Undo.Enabled = true;
                else
                    self.Actions.Undo.Enabled = false;
                end

                if modelInfo.RedoStackSize > 0
                    self.Actions.Redo.Enabled = true;
                else
                    self.Actions.Redo.Enabled = false;
                end

                updateStateOfOptimizer( self );


                if ~self.AnalysisEnableState
                    self.OptimizerBtn.Enabled = false;
                end

                if self.DesignEnabledState && modelInfo.SingleLayerSelected &&  ...
                        any( strcmpi( modelInfo.CurrentLayerType, { 'Metal', 'Dielectric' } ) )
                    self.LayerSection.MoveUp.Enabled = true;
                    self.LayerSection.MoveDown.Enabled = true;
                else
                    self.LayerSection.MoveUp.Enabled = false;
                    self.LayerSection.MoveDown.Enabled = false;
                end

                if strcmpi( modelInfo.CurrentLayerType, 'Metal' )
                    self.FeedViaSection.Feed.Enabled = true;
                    self.FeedViaSection.Via.Enabled = true;
                    self.FeedViaSection.Load.Enabled = true;
                else
                    self.FeedViaSection.Feed.Enabled = false;
                    self.FeedViaSection.Via.Enabled = false;
                    self.FeedViaSection.Load.Enabled = false;
                end

                setActionsButtons( self, logical( modelInfo.ActionsStatus ) );

            end

            updateStateOfUpdatePlots( self );

            if ~isfield( self.Model.SelectedObj, 'Type' )
                setBooleanButtons( self, [ false, false, false, false ] );


                return ;
            else

                selectedInfo = vm.getSelectedObjInfo(  );
                modelInfo = selectedInfo{ 4 };
                treeselected = 0;
                canvasselected = 0;
                if strcmpi( modelInfo.SelectionViewType, 'Canvas' )
                    canvasselected = 1;
                else
                    treeselected = 1;
                end
                shapesSelected = 0;
                singleShapeSelected = 0;
                twoShapesSelected = 0;
                multipleShapesSelected = 0;

                idx = strcmpi( selectedInfo{ 1 }, 'Shape' );
                if sum( idx ) == 1
                    singleShapeSelected = 1;
                    shapesSelected = 1;
                elseif sum( idx ) == 2
                    twoShapesSelected = 1;
                    shapesSelected = 1;
                elseif sum( idx ) > 2
                    multipleShapesSelected = 1;
                    shapesSelected = 1;
                end
                layerSelected = 0;
                singleLayerSelected = 0;
                multipleLayersSelected = 0;
                idx = strcmpi( selectedInfo{ 1 }, 'Layer' );
                layerId =  - 1;
                if sum( idx ) == 1
                    singleLayerSelected = 1;
                    layerSelected = 1;
                    layerId = selectedInfo{ 2 }( idx );
                elseif sum( idx ) > 1
                    multipleLayersSelected = 1;
                    layerSelected = 1;
                    layerId = selectedInfo{ 2 }( idx );
                end
                if any( layerId == 1 )
                    BoardShapeSelected = 1;
                else
                    BoardShapeSelected = 0;
                end

                operationsSelected = 0;
                idx = strcmpi( selectedInfo{ 1 }, 'Operation' );
                if sum( idx ) > 0
                    operationsSelected = 1;
                end
                feedSelected = 0;
                idx = strcmpi( selectedInfo{ 1 }, 'Feed' );
                if sum( idx ) > 0
                    feedSelected = 1;
                end
                viaSelected = 0;
                idx = strcmpi( selectedInfo{ 1 }, 'Via' );
                if sum( idx ) > 0
                    viaSelected = 1;
                end
                loadSelected = 0;
                idx = strcmpi( selectedInfo{ 1 }, 'Load' );
                if sum( idx ) > 0
                    loadSelected = 1;
                end
                if canvasselected
                    if feedSelected || viaSelected || loadSelected
                        setBooleanButtons( self, [ false, false, false, false ] );
                    else
                        if singleShapeSelected
                            setBooleanButtons( self, [ false, false, false, false ] );
                        elseif twoShapesSelected
                            setBooleanButtons( self, [ true, true, true, true ] );
                        elseif multipleShapesSelected
                            setBooleanButtons( self, [ true, false, false, false ] );
                        else
                            setBooleanButtons( self, [ false, false, false, false ] );
                        end
                    end





                elseif treeselected
                    idx = strcmpi( selectedInfo{ 1 }, 'Shape' );
                    if sum( idx ) ~= 0
                        shapeinfo = [ selectedInfo{ 3 }{ idx } ];
                        shapeParentType = { shapeinfo.ParentType };
                        shapeParentsId = [ shapeinfo.ParentId ];
                        if sum( strcmpi( shapeParentType, 'Layer' ) ) == sum( idx ) && numel( unique( shapeParentsId ) ) == 1
                            mainShapesOfOneLayerSelected = 1;
                        else
                            mainShapesOfOneLayerSelected = 0;

                        end
                    else
                        mainShapesOfOneLayerSelected = 0;
                    end
                    if ( operationsSelected || layerSelected ) && ~BoardShapeSelected
                        setBooleanButtons( self, [ false, false, false, false ] );
                    else
                        if mainShapesOfOneLayerSelected && ~feedSelected && ~viaSelected && ~loadSelected
                            if sum( idx ) == 2
                                setBooleanButtons( self, [ true, true, true, true ] );
                            elseif sum( idx ) == 1
                                setBooleanButtons( self, [ false, false, false, false ] );
                            elseif sum( idx ) > 2
                                setBooleanButtons( self, [ true, false, false, false ] );
                            end
                        elseif shapesSelected || feedSelected || viaSelected || loadSelected
                            setBooleanButtons( self, [ false, false, false, false ] );
                        else
                            setBooleanButtons( self, [ false, false, false, false ] );
                        end
                    end









                end
            end
        end

        function updateStateOfUpdatePlots( self )
            if self.Model.modelChanged
                self.UpdateAnalysis = getVisibleAnalysisPlotsIndex( self );
                if self.AnalysisEnableState
                    self.UpdatePlots.Enabled = true;
                    updatePlotsEnabled( self );

                end
            end

            if all( ~self.UpdateAnalysis )
                self.UpdatePlots.Enabled = false;
            else
                self.UpdatePlots.Enabled = true;
            end
        end

        function updateStateOfOptimizer( self )
            try
                varNames = self.VariablesManager.getIndepVarNames(  );
                scalarIndex = cell2mat( cellfun( @( x )isscalar( self.VariablesManager.get( x ) ), varNames, 'UniformOutput', false ) );
                varNames = varNames( scalarIndex );
            catch me
                varNames = {  };
            end
            if self.AnalysisEnableState && ~isempty( self.PlotFrequency ) &&  ...
                    ~isempty( self.FrequencyRange )
                if isvalid( self.VariablesManager ) && numel( self.VariablesManager.Variables ) > 0 &&  ...
                        ~all( cell2mat( cellfun( @( x )isempty( x ), { self.VariablesManager.Variables.VariableMap }, 'UniformOutput', false ) ) ) &&  ...
                        ~isempty( varNames )
                    self.OptimizerBtn.Enabled = true;
                else
                    self.OptimizerBtn.Enabled = false;
                end
            else
                self.OptimizerBtn.Enabled = false;
            end
        end


        function setBooleanButtons( self, visibility )
            if ~self.DesignEnabledState
                return ;
            end
            self.BooleanOpns.Add.Enabled = visibility( 1 );
            self.BooleanOpns.Subtract.Enabled = visibility( 2 );
            self.BooleanOpns.Intersect.Enabled = visibility( 3 );
            self.BooleanOpns.Xor.Enabled = visibility( 4 );
        end

        function setActionsButtons( self, visibility )
            if ~self.DesignEnabledState
                return ;
            end
            self.Actions.Cut.Enabled = visibility( 1 );
            self.Actions.Copy.Enabled = visibility( 2 );
            self.Actions.Paste.Enabled = visibility( 3 );
            self.Actions.Delete.Enabled = visibility( 4 );
        end

        function setModelBusy( self )
            self.ModelBusy = 0;
        end

        function resetModelBusy( self )
            self.ModelBusy = 0;
        end

        function addViewModelAndController( self )
            self.CanvasView = em.internal.pcbDesigner.PCBDesignerCanvas( self.CanvasDocument.Figure );
            self.TreeView = em.internal.pcbDesigner.PCBDesignerTreeView( self.TreeDocument.Figure );
            self.PropertiesView = em.internal.pcbDesigner.PropertyPanelView( self.PropertiesDocument.Figure );
            self.VariablesView = em.internal.pcbDesigner.VariablesView( self.VariablesDocument.Figure );
            self.Layer3DView = em.internal.pcbDesigner.Layer3DView( self.Layer3DDocument.Figure );
            self.SettingsView = em.internal.pcbDesigner.Settings( self.SettingsFigure );
            self.ValidationView = em.internal.pcbDesigner.ValidationView( self.ValidationFigure );
            self.AnalysisSettingsView = em.internal.pcbDesigner.AnalysisSettings( self.AnalysisSettingsFigure );
            self.GerberExportView = em.internal.pcbDesigner.GerberExport( self.GerberExportFigure );

            self.View = [ self.CanvasView, self.TreeView, self.PropertiesView, self.Layer3DView,  ...
                self.SettingsView, self.ValidationView, self.AnalysisSettingsView, self.VariablesView ];
            sf = cad.ShapeFactory;
            of = cad.OperationsFactory;

            self.Model = em.internal.pcbDesigner.PCBModel( sf, of, [  ] );


            self.setVariablesManager( cad.VariablesManager );


            self.ViewModel = em.internal.pcbDesigner.ViewModel(  );
            self.ViewModel.MainModel = self.Model;


            viewModelObj = [ self.CanvasView, self.PropertiesView, self.VariablesView,  ...
                self.Layer3DView, self.AnalysisSettingsView, self.SettingsView ];
            for i = 1:numel( viewModelObj )
                addlistener( self.ViewModel, 'UpdateView', @( src, evt )updateView( viewModelObj( i ), self.ViewModel ) );
                setModel( viewModelObj( i ), self.Model );
            end

            addlistener( self.ViewModel, 'UpdateView', @( src, evt )updateView( self, self.ViewModel ) );
            addlistener( self.ViewModel, 'UpdateView', @( src, evt )updateView( self.TreeView, self.ViewModel ) );


            normalView = [ self.TreeView, self.ValidationView ];
            self.Controller = cad.Controller( normalView, self.Model );



            addlistener( self.Model, 'ModelChanged', @( src, evt )modelChanged( self, evt ) );

            addlistener( self.Model, 'ModelChanged', @( src, evt )modelChanged( self.ViewModel, evt ) );
            addlistener( self.Model, 'ActionStarted', @( src, evt )setModelBusy( self ) );
            addlistener( self.Model, 'ActionEnded', @( src, evt )resetModelBusy( self ) );

            addlistener( self.Model, 'ActionEnded', @( src, evt )actionEnded( self.ViewModel ) );
            addlistener( self.Model, 'ActionStarted', @( src, evt )actionStarted( self.ViewModel ) );


            addlistener( self.ViewModel, 'SessionCleared', @( src, evt )sessionCleared( self.Layer3DView ) );
            addlistener( self.ViewModel, 'SessionCleared', @( src, evt )sessionCleared( self.CanvasView ) );
            addlistener( self.ViewModel, 'SessionCleared', @( src, evt )sessionCleared( self.PropertiesView ) );

            currentLayerChanged( self.Model );

            addlistener( self.SettingsView, 'DialogClosed', @( src, evt )self.bringToFront(  ) );
            addlistener( self.ValidationView, 'DialogClosed', @( src, evt )self.bringToFront(  ) );
            addlistener( self.AnalysisSettingsView, 'DialogClosed', @( src, evt )self.bringToFront(  ) );
            addlistener( self.GerberExportView, 'DialogClosed', @( src, evt )self.bringToFront(  ) );
            self.VariablesView.AdditionalCallback = @(  )self.bringToFront(  );
        end

        function updatePlotsEnabled( self )

        end

        function val = getVisibleAnalysisPlotsIndex( self )
            val = zeros( 1, 7 );
            if ~self.ImpedanceDocument.Phantom
                val( 1 ) = 1;
            end
            if ~self.SparameterDocument.Phantom
                val( 2 ) = 1;
            end
            if ~self.CurrentDocument.Phantom
                val( 3 ) = 1;
            end
            if ~self.MeshDocument.Phantom
                val( 4 ) = 1;
            end
            if ~self.PatternDocument.Phantom
                val( 5 ) = 1;
            end
            if ~self.ElevationDocument.Phantom
                val( 6 ) = 1;
            end
            if ~self.AzimuthDocument.Phantom
                val( 7 ) = 1;
            end

        end

        function sync( obj, varargin )















            p = inputParser;
            p.addOptional( 'Type', 'matlab.internal.yield', @ischar );
            p.addParameter( 'Item', [  ] );
            parse( p, varargin{ : } );
            switch p.Results.Type
                case 'matlab.internal.yield'

                    matlab.internal.yield;
                case 'update'
                    drawnow update;
                case 'waitfor'
                    waitfor( p.Results.Item );
                case 'App'
                    waitfor( obj.App, 'State', matlab.ui.container.internal.appcontainer.AppState.RUNNING );
            end
            matlab.internal.yield
        end


        function genPlot( self, src )
            Type = src.Tag;
            val = src.Value;
            switch Type
                case 'azimuth'
                    document = self.AzimuthDocument;
                    figHandle = self.AzimuthDocument.Figure;
                    freqVal = self.PlotFrequency;
                case 'elevation'
                    document = self.ElevationDocument;
                    figHandle = self.ElevationDocument.Figure;
                    freqVal = self.PlotFrequency;
                case 'pattern'
                    document = self.PatternDocument;
                    figHandle = self.PatternDocument.Figure;
                    freqVal = self.PlotFrequency;
                case 'impedance'
                    document = self.ImpedanceDocument;
                    figHandle = self.ImpedanceDocument.Figure;
                    freqVal = self.FrequencyRange;
                case 'sparameter'
                    document = self.SparameterDocument;
                    figHandle = self.SparameterDocument.Figure;
                    freqVal = self.FrequencyRange;
                case 'current'
                    document = self.CurrentDocument;
                    figHandle = self.CurrentDocument.Figure;
                    freqVal = self.PlotFrequency;
                case 'mesh'
                    document = self.MeshDocument;
                    figHandle = self.MeshDocument.Figure;
                    freqVal = [  ];
            end
            figHandle.AutoResizeChildren = 'off';
            if val
                pass = validateDesign( self.Model );
                if pass
                    document.Visible = true;
                    figHandle = document.Figure;

                    figHandle.Internal = false;
                    set( groot, 'CurrentFigure', figHandle );
                    figHandle.HandleVisibility = 'on';
                    if any( strcmpi( Type, { 'elevation', 'azimuth' } ) )
                        sync( self );
                    end
                    try
                        self.StatusLabel.Text = getString( message( "antenna:pcbantennadesigner:RunningAnalysis", Type ) );
                        generatePlot( self.Model, Type, freqVal )
                        if any( strcmpi( Type, 'mesh' ) )
                            addMeshCheckbox( self );
                        end
                        if any( strcmpi( Type, { 'elevation', 'azimuth' } ) )
                            sync( self, 'update' );
                            ax = gca;
                            disableDefaultInteractivity( ax );
                        end
                        figHandle.HandleVisibility = 'off';

                        self.ModelChanged = 0;

                        figHandle.notify( 'SizeChanged' );
                        switch Type
                            case 'impedance'
                                self.UpdateAnalysis( 1 ) = 0;
                            case 'sparameter'
                                self.UpdateAnalysis( 2 ) = 0;
                            case 'current'
                                self.UpdateAnalysis( 3 ) = 0;
                            case 'mesh'
                                self.UpdateAnalysis( 4 ) = 0;
                            case 'pattern'
                                self.UpdateAnalysis( 5 ) = 0;
                            case 'elevation'
                                self.UpdateAnalysis( 6 ) = 0;
                            case 'azimuth'
                                self.UpdateAnalysis( 7 ) = 0;
                        end
                        evt.EventType = '';
                        selectedInfo = [  ];
                        evt.ModelInfo = getInfo( self.Model );
                        modelChanged( self, evt );
                    catch me
                        figHandle.HandleVisibility = 'off';


                        clf( figHandle );

                        document.Visible = false;

                        src.Value = false;

                        h = errordlg( me.message, 'Error', 'modal' );

                    end


                else
                    clf( figHandle );
                    document.Visible = false;
                    src.Value = false;
                end
            else
                clf( figHandle );
                document.Visible = false;
                src.Value = false;
            end

            self.StatusLabel.Text = "";



        end

        function runMemoryEstimate( self )
            pass = validateDesign( self.Model );
            if pass
                pcbObj = getPCBObject( self.Model );
                memstr = memoryEstimate( pcbObj, max( [ self.PlotFrequency, max( self.FrequencyRange ) ] ) );
                h = helpdlg( [ 'The pcbStack requires a memory of ', memstr, newline,  ...
                    newline, '    *Change the Mesh parameters in settings ', newline, '        to decrease the memory required.' ], 'Memory Estimate' );
                h.WindowStyle = 'modal';
            else
            end
        end

        function analysisSettingsChanged( self, evt )
            data = evt.Data;





        end

        function canvasSelectionUpdated( self )
            if ~isempty( self.Model.SelectedObj )
            else
                setBooleanButtons( self, [ false, false, false, false ] );
            end
        end

        function updatePlots( self )
            pass = validateDesign( self.Model );
            if pass
                genPlot( self, self.VectorAnalysis.ImpedanceButton );
                genPlot( self, self.VectorAnalysis.SparameterButton );
                genPlot( self, self.ScalarAnalysis.PatternButton );
                genPlot( self, self.ScalarAnalysis.AzimuthButton );
                genPlot( self, self.ScalarAnalysis.ElevationButton );
                genPlot( self, self.ScalarAnalysis.CurrentButton );
                genPlot( self, self.MeshSection.MeshButton );

                self.UpdatePlots.Enabled = false;
            else
            end
        end

        function bringToFront( self )
            if isvalid( self.App )
                bringToFront( self.App );
            end
        end

        function addDesignTabListeners( self )
            addlistener( self.ShapeGallery.Rectangle, 'ItemPushed', @( src, evt )drawShape( self.CanvasView, 'Rectangle' ) );
            addlistener( self.ShapeGallery.Circle, 'ItemPushed', @( src, evt )drawShape( self.CanvasView, 'Circle' ) );
            addlistener( self.ShapeGallery.Ellipse, 'ItemPushed', @( src, evt )drawShape( self.CanvasView, 'Ellipse' ) );
            addlistener( self.ShapeGallery.Polygon, 'ItemPushed', @( src, evt )drawPolygon( self.CanvasView, src, evt ) );
            addlistener( self.BooleanOpns.Add, 'ButtonPushed', @( src, evt )addOperation( self.CanvasView, 'Add' ) );
            addlistener( self.BooleanOpns.Subtract, 'ButtonPushed', @( src, evt )addOperation( self.CanvasView, 'Subtract' ) );
            addlistener( self.BooleanOpns.Intersect, 'ButtonPushed', @( src, evt )addOperation( self.CanvasView, 'Intersect' ) );
            addlistener( self.BooleanOpns.Xor, 'ButtonPushed', @( src, evt )addOperation( self.CanvasView, 'Xor' ) );
            addlistener( self.LayerSection.AddLayer, 'ButtonPushed', @( src, evt )addLayer( self.CanvasView, 'Metal' ) );
            addlistener( self.LayerSection.MoveUp, 'ButtonPushed', @( src, evt )moveLayer( self.Layer3DView, 'Up' ) );
            addlistener( self.LayerSection.MoveDown, 'ButtonPushed', @( src, evt )moveLayer( self.Layer3DView, 'Down' ) );
            addlistener( self.LayerSection.MetalLayer, 'ItemPushed', @( src, evt )addLayer( self.CanvasView, 'Metal' ) );
            addlistener( self.LayerSection.DielectricLayer, 'ItemPushed', @( src, evt )addLayer( self.CanvasView, 'Dielectric' ) );
            addlistener( self.FeedViaSection.Feed, 'ButtonPushed', @( src, evt )addFeed( self.CanvasView, src, evt ) );
            addlistener( self.FeedViaSection.Via, 'ButtonPushed', @( src, evt )addVia( self.CanvasView, src, evt ) );
            addlistener( self.FeedViaSection.Load, 'ButtonPushed', @( src, evt )addLoad( self.CanvasView, src, evt ) );
            addlistener( self.Actions.Undo, 'ButtonPushed', @( src, evt )self.Model.undo(  ) );
            addlistener( self.Actions.Redo, 'ButtonPushed', @( src, evt )self.Model.redo(  ) );
            addlistener( self.Actions.Delete, 'ButtonPushed', @( src, evt )self.Model.deleteSelection(  ) );
            addlistener( self.Actions.Cut, 'ButtonPushed', @( src, evt )self.CanvasView.cut(  ) );
            addlistener( self.Actions.Copy, 'ButtonPushed', @( src, evt )self.CanvasView.copy(  ) );
            addlistener( self.Actions.Paste, 'ButtonPushed', @( src, evt )self.CanvasView.paste(  ) );
            addlistener( self.SettingsSection.Settings, 'ButtonPushed', @( src, evt )self.SettingsView.showSettingsDialog(  ) );
            addlistener( self.ValidationSection.Validate, 'ButtonPushed', @( src, evt )self.ValidationView.startValidationDialog(  ) );
            addlistener( self.FileSection.New.Button, 'ButtonPushed', @( src, evt )self.newSession(  ) );
            addlistener( self.FileSection.File.Button, 'ButtonPushed', @( src, evt )self.openFileDialog(  ) );
            addlistener( self.FileSection.Save.Button, 'ButtonPushed', @( src, evt )self.saveFile(  ) );
            addlistener( self.FileSection.SaveItem, 'ItemPushed', @( src, evt )self.saveFile(  ) );
            addlistener( self.FileSection.SaveAsItem, 'ItemPushed', @( src, evt )self.saveAsFileDialog(  ) );
            addlistener( self.FileSection.Import.Button, 'ButtonPushed', @( src, evt )self.importGerberDialog(  ) );
            addlistener( self.FileSection.Import.ImportGerber, 'ItemPushed', @( src, evt )self.importGerberDialog(  ) );
            addlistener( self.FileSection.Import.ImportMat, 'ItemPushed', @( src, evt )self.importMatFileDialog(  ) );
            addlistener( self.Export.Button, 'ButtonPushed', @( src, evt )self.exportToWorkspace(  ) );
            addlistener( self.Export.ExportToWorkspace, 'ItemPushed', @( src, evt )self.exportToWorkspace(  ) );
            addlistener( self.Export.ExportScript, 'ItemPushed', @( src, evt )self.exportScript(  ) );
            addlistener( self.Export.GerberExport, 'ItemPushed', @( src, evt )self.gerberExport(  ) );

            addlistener( self.AnalysisExport.Button, 'ButtonPushed', @( src, evt )self.exportToWorkspace(  ) );
            addlistener( self.AnalysisExport.ExportToWorkspace, 'ItemPushed', @( src, evt )self.exportToWorkspace(  ) );
            addlistener( self.AnalysisExport.ExportScript, 'ItemPushed', @( src, evt )self.exportScript(  ) );
            addlistener( self.AnalysisExport.GerberExport, 'ItemPushed', @( src, evt )self.gerberExport(  ) );

            addlistener( self.UpdatePlots, 'ButtonPushed', @( src, evt )self.updatePlots(  ) );
            addlistener( self.OptimizerBtn, 'ButtonPushed', @( src, evt )self.openOptimizationPane(  ) );
            addlistener( self.Settings, 'ButtonPushed', @( src, evt )self.AnalysisSettingsView.showSettingsDialog(  ) );
            addlistener( self.ScalarAnalysis.PatternButton, 'ValueChanged', @( src, evt )self.genPlot( src ) );
            addlistener( self.ScalarAnalysis.CurrentButton, 'ValueChanged', @( src, evt )self.genPlot( src ) );
            addlistener( self.VectorAnalysis.ImpedanceButton, 'ValueChanged', @( src, evt )self.genPlot( src ) );
            addlistener( self.VectorAnalysis.SparameterButton, 'ValueChanged', @( src, evt )self.genPlot( src ) );
            addlistener( self.ScalarAnalysis.AzimuthButton, 'ValueChanged', @( src, evt )self.genPlot( src ) );
            addlistener( self.ScalarAnalysis.ElevationButton, 'ValueChanged', @( src, evt )self.genPlot( src ) );
            addlistener( self.MeshSection.MeshButton, 'ValueChanged', @( src, evt )self.genPlot( src ) );
            addlistener( self.MeshSection.MemoryEstimateButton, 'ButtonPushed', @( src, evt )self.runMemoryEstimate(  ) );
            addlistener( self.AnalysisSettingsView, 'ValueChanged', @( src, evt )self.analysisSettingsChanged( evt ) );
            addlistener( self.CanvasView, 'CanvasObjectsSelected', @( src, evt )self.canvasSelectionUpdated(  ) );
            addlistener( self.ViewSec.Button, 'ButtonPushed', @( src, evt )self.defaultLayout(  ) );



        end


        function openOptimizationPane( self )
            pass = validateDesign( self.Model );
            if ~pass
                return ;
            end
            panelOptions.Title = "Design Variables";
            panelOptions.Tag = "OptimizationDesignVariables";
            panelOptions.Opened = 0;
            panel = matlab.ui.internal.FigurePanel( panelOptions );

            self.DesignVarPanel = panel;
            self.DesignVarPanel.Opened = 0;
            self.App.add( panel );
            panel.Figure.Scrollable = 'on';

            v = self.generateViewStruct( self, self.App, self.TabGroup,  ...
                self.FrequencySection.PlotFrequencyEditField,  ...
                self.FrequencySection.FrequencyRangeEditField,  ...
                self.FrequencySection.PlotFrequencyUnitDropdown,  ...
                self.FrequencySection.FrequencyRangeUnitDropdown,  ...
                self.DesignVarPanel );
            self.generateModelStruct( self.Model.createModelCopy(  ) );

            v.Title = 'PCB Antenna Designer';
            v.StatusLabel = self.StatusLabel;
            v.StatusBar = self.StatusBar;
            v.ProgressBar = self.ProgressBar;

            self.App.Busy = 1;
            clearView( self );
            self.DesignVarPanel.Opened = 1;
            self.App.LeftWidth = 350;
            self.openOptimizer(  );
            self.TabGroup.SelectedTab = self.ViewStruct.OptimizerView.OptimizerTab;
            self.App.Busy = 0;

        end

        function resetView( self )
            self.TabGroup.add( self.DesignTab );
            self.TabGroup.add( self.AnalysisTab );
            self.TabGroup.SelectedTab = self.AnalysisTab;
            self.StatusLabel.Text = "";
            self.VariablesDocument.Index = 3;
            self.PropertiesDocument.Index = 2;
            self.TreeDocument.Index = 1;

            self.TreeDocument.Opened = true;
            self.PropertiesDocument.Opened = true;

            self.VariablesDocument.Opened = true;
            self.CanvasDocument.Visible = true;
            self.App.LeftWidth = 250;

            self.App.DocumentGridDimensions = [ 2, 1 ];
            pause( 1 );

            self.CanvasDocument.Tile = 1;
            self.Layer3DDocument.Tile = 2;
            self.App.DocumentColumnWeights = [ 0.6, 0.4 ];



        end

        function clearView( self )
            self.PropertiesDocument.Opened = 0;
            self.TreeDocument.Opened = 0;
            self.VariablesDocument.Opened = 0;
            self.CanvasDocument.Visible = 0;

            self.ExploreDocument.Visible = 0;
            self.TabGroup.remove( self.AnalysisTab );
            self.TabGroup.remove( self.DesignTab );
            self.ImpedanceDocument.Visible = 0;
            self.PatternDocument.Visible = 0;
            self.SparameterDocument.Visible = 0;
            self.AzimuthDocument.Visible = 0;
            self.ElevationDocument.Visible = 0;
            self.MeshDocument.Visible = 0;
            self.CurrentDocument.Visible = 0;

            self.ScalarAnalysis.AzimuthButton.Value = false;
            self.ScalarAnalysis.CurrentButton.Value = false;
            self.ScalarAnalysis.ElevationButton.Value = false;
            self.ScalarAnalysis.PatternButton.Value = false;
            self.VectorAnalysis.ImpedanceButton.Value = false;
            self.VectorAnalysis.SparameterButton.Value = false;
            self.MeshSection.MeshButton.Value = false;



        end

        function clearOptimizationView( self )

            self.DesignVarPanel.Opened = 0;



            self.TabGroup.remove( self.TabGroup.SelectedTab );
        end

        function updateModel( self )

            if isa( self.ModelStruct.MainObject, 'pcbStack' )
                pcbObj = self.ModelStruct.MainObject;
                data = pcbObj.h_getData(  );
                propNames = data.PropNames;
                propValues = data.PropValues;
                propIdx = data.Idx;
                for i = 1:numel( propNames )
                    varName = propNames{ i };
                    propVal = ( propValues( str2num( propIdx{ i } ) ) );

                    prevVal = mat2str( self.VariablesManager.get( varName ) );
                    evt = struct( 'Name', varName, 'Indices', [ 0, 3 ], 'NewData',  ...
                        mat2str( propVal ), 'PreviousData', prevVal );
                    self.VariablesView.notify( 'ChangeVariable', cad.events.VariableEventData(  ...
                        varName, prevVal, evt ) );
                end
            else
                modelCopyObj = self.ModelStruct.MainObject;
                varNames = modelCopyObj.VariablesManager.getIndepVarNames(  );

                for i = 1:numel( varNames )
                    if ~isequal( modelCopyObj.get( varNames{ i } ), modelCopyObj.InitialValue{ i } )
                        evt = struct( 'Name', varNames{ i }, 'Indices', [ 0, 3 ], 'NewData',  ...
                            mat2str( modelCopyObj.get( varNames{ i } ) ), 'PreviousData', mat2str( modelCopyObj.InitialValue{ i } ) );
                        self.VariablesView.notify( 'ChangeVariable', cad.events.VariableEventData(  ...
                            varNames{ i }, mat2str( modelCopyObj.InitialValue{ i } ), evt ) );
                    end
                end
            end
        end
    end
    events
    end
end


