classdef FileSectionView < handle






    properties

        FileSectionModel
    end

    properties
        NewButton
        OpenButton
        SaveButton
        SaveItem
        SaveToDisk
        ImportButton
        ImportMATFile
        ImportModel
    end

    properties ( Constant, Access = private )
        Width = 340;
        Height = 250;
    end

    methods

        function obj = FileSectionView( FileSectionModel, options )



            arguments
                FileSectionModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.FileSectionModel = rfpcb.internal.apps.transmissionLineDesigner.model.FileSectionModel;
                options.Parent( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty } = matlab.ui.internal.toolstrip.Tab( 'Design' );
            end
            obj.FileSectionModel = FileSectionModel;


            create( obj, options.Parent )
            log( obj.FileSectionModel.Logger, '% File section created.' );
        end


        function update( obj )


            import matlab.ui.internal.toolstrip.*;
            val = ~isempty( obj.FileSectionModel.TransmissionLine );

            obj.NewButton.Enabled = val;
            obj.SaveButton.Enabled = val;
            if obj.FileSectionModel.RecentlySaved
                obj.SaveButton.Icon = Icon.SAVE_24;
                obj.FileSectionModel.RecentlySaved = false;
            else
                obj.SaveButton.Icon = Icon.SAVE_DIRTY_24;
            end
        end
    end

    methods ( Access = private )

        function create( obj, Tab )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.FileSectionView{ mustBeNonempty };
                Tab( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty };
            end

            import matlab.ui.internal.toolstrip.*;

            fileSection = Section( 'File' );
            fileSection.Tag = 'fileSection';
            Tab.add( fileSection );

            newBtnCol = fileSection.addColumn( 'Width', 50 );
            newBtnCol.Tag = 'newColumn';
            obj.NewButton = Button( 'New Session', Icon.NEW_24 );
            obj.NewButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:NewButton' ) );
            obj.NewButton.Tag = 'newButton';
            obj.NewButton.Enabled = false;
            newBtnCol.add( obj.NewButton );

            openBtnCol = fileSection.addColumn( 'Width', 50 );
            openBtnCol.Tag = 'openColumn';
            obj.OpenButton = Button( 'Open Session', Icon.OPEN_24 );
            obj.OpenButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:OpenButton' ) );
            obj.OpenButton.Tag = 'openButton';
            openBtnCol.add( obj.OpenButton );

            saveBtnCol = fileSection.addColumn( 'Width', 50 );
            saveBtnCol.Tag = 'saveColumn';
            obj.SaveButton = SplitButton( 'Save Session', Icon.SAVE_24 );
            obj.SaveButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:SaveButton' ) );
            obj.SaveButton.Tag = 'saveButton';
            saveBtnCol.add( obj.SaveButton );
            obj.SaveButton.Popup = PopupList;
            obj.SaveItem = ListItem( 'Save', Icon.SAVE_16 );
            obj.SaveItem.ShowDescription = false;
            obj.SaveToDisk = ListItem( 'Save As', Icon.SAVE_AS_16 );
            obj.SaveToDisk.ShowDescription = false;
            obj.SaveButton.Popup.add( obj.SaveItem );
            obj.SaveButton.Popup.add( obj.SaveToDisk );
            saveBtnCol.disableAll;

            importCol = fileSection.addColumn( 'Width', 50 );
            importCol.Tag = 'importColumn';
            obj.ImportButton = SplitButton( 'Import', Icon.IMPORT_24 );
            obj.ImportButton.Tag = 'importButton';
            obj.ImportButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:ImportButton' ) );
            add( importCol, obj.ImportButton );
            obj.ImportButton.Popup = PopupList;
            obj.ImportMATFile = ListItem( 'Import .mat file' );
            obj.ImportMATFile.ShowDescription = false;
            obj.ImportModel = ListItem( 'Import Model' );
            obj.ImportModel.ShowDescription = false;
            obj.ImportButton.Popup.add( obj.ImportMATFile );
            obj.ImportButton.Popup.add( obj.ImportModel );
        end
    end
end

