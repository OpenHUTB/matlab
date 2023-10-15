classdef ExportSectionView < handle

    properties

        ExportSectionModel
    end

    properties
        ExportSection
        ExportSplitButton
        ExportScriptButton
        ExportWorkspaceButton
        ExportModelButton
        ExportFileS2P
    end

    properties ( Constant, Access = private )
        Width = 340;
        Height = 250;
    end

    methods

        function obj = ExportSectionView( ExportSectionModel, options )




            arguments
                ExportSectionModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.ExportSectionModel = rfpcb.internal.apps.transmissionLineDesigner.model.ExportSectionModel;
                options.Parent( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty } = matlab.ui.internal.toolstrip.Tab( 'Design' );
            end
            obj.ExportSectionModel = ExportSectionModel;


            create( obj, options.Parent )
            log( obj.ExportSectionModel.Logger, '% Export section created.' );
        end


        function update( obj )



            if isempty( obj.ExportSectionModel.TransmissionLine )

                obj.ExportSection.disableAll;
            else

                obj.ExportSection.enableAll;
            end
        end
    end

    methods ( Access = private )

        function create( obj, Tab )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.ExportSectionView{ mustBeNonempty };
                Tab( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty };
            end

            import matlab.ui.internal.toolstrip.*;


            obj.ExportSection = Section( 'Export' );
            obj.ExportSection.Tag = 'exportSection';
            Tab.add( obj.ExportSection );
            esBtnCol = obj.ExportSection.addColumn(  );
            esBtnCol.Tag = 'exportColumn';
            obj.ExportSplitButton = SplitButton( 'Export', Icon.CONFIRM_24 );
            obj.ExportSplitButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:ExportButton' ) );
            obj.ExportSplitButton.Tag = 'exportSplitButton';
            pExpList = PopupList(  );
            obj.ExportWorkspaceButton = ListItem( 'Export to workspace' );
            obj.ExportWorkspaceButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:ExportWorkspace' ) );
            obj.ExportWorkspaceButton.Tag = 'exportWorkspaceButton';
            pExpList.add( obj.ExportWorkspaceButton );
            obj.ExportScriptButton = ListItem( 'Export as script' );
            obj.ExportScriptButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:ExportScript' ) );
            obj.ExportScriptButton.Tag = 'exportScriptButton';
            pExpList.add( obj.ExportScriptButton );
            obj.ExportSplitButton.Popup = pExpList;
            esBtnCol.add( obj.ExportSplitButton );

            obj.ExportModelButton = ListItem( 'Export Model' );
            obj.ExportModelButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:ExportModelButton' ) );
            obj.ExportModelButton.Tag = 'exportModel';
            pExpList.add( obj.ExportModelButton );
            obj.ExportFileS2P = ListItem( 'Export .S2P File' );
            obj.ExportFileS2P.Description = getString( message( 'rfpcb:transmissionlinedesigner:ExportFileS2P' ) );
            obj.ExportFileS2P.Tag = 'exportFileS2P';
            pExpList.add( obj.ExportFileS2P );

            obj.ExportSection.disableAll;
        end
    end
end



