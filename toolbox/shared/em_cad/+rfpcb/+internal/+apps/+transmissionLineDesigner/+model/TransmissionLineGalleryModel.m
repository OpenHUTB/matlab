classdef TransmissionLineGalleryModel < rfpcb.internal.apps.transmissionLineDesigner.model.Visualization





    properties ( Constant )

        Path = fullfile( matlabroot, 'toolbox', 'shared', 'em_cad', '+rfpcb', '+internal', '+apps', '+transmissionLineDesigner', '+src', '+galleryIcons' );

        MaxColumnCount = 1;

        MinColumnCount = 1;

        Tag = 'transmissionLineGallery'


        GalleryItemTextLineCount = 1;
    end

    properties


        Names = { 'microstripLine', 'microstripBuried' };


        NickNames = { 'MicrostripLine', 'Buried MicrostripLine' };

        Families = { 'Transmission Lines', 'Transmission Lines', 'Transmission Lines', 'Transmission Lines' };
    end

    methods

        function obj = TransmissionLineGalleryModel( TransmissionLine, Logger, options )


            arguments
                TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
                options.Names = { 'microstripLine', 'microstripBuried' };
                options.NickNames = { 'MicrostripLine', 'Buried MicrostripLine' };
                options.Families = { 'Transmission Lines', 'Transmission Lines', 'Transmission Lines', 'Transmission Lines' };
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.model.Visualization( Logger );


            obj.Names = options.Names;
            obj.NickNames = options.NickNames;
            obj.Families = options.Families;
            obj.TransmissionLine = TransmissionLine;


            log( obj.Logger, '% TransmissionLineGalleryModel object created.' )
        end


        function update( obj )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.View2DModel{ mustBeNonempty }
            end

            if ~isempty( obj.TransmissionLine )

            else
                clear( obj );
            end


            log( obj.Logger, '% View2D plot computed.' )
        end
    end
end


