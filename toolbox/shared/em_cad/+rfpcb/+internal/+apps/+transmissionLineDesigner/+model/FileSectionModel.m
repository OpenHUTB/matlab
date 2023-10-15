classdef FileSectionModel < matlab.mixin.SetGet

    properties
        TransmissionLine
        Logger
    end

    properties ( Hidden )
        RecentlySaved( 1, 1 ){ mustBeNumericOrLogical } = false;
    end

    methods

        function obj = FileSectionModel( TransmissionLine, Logger )


            arguments
                TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj.TransmissionLine = TransmissionLine;
            obj.Logger = Logger;

            log( obj.Logger, '% FileSectionModel object created.' )
        end


        function new(  )
        end


        function open(  )

        end


        function save( obj, AppSession )
            [ filename, pathname ] = uiputfile( '*.mat', 'Save To Disk' );
            if ~( isequal( filename, 0 ) || isequal( pathname, 0 ) )
                save( fullfile( pathname, filename ), 'AppSession' );
            end
            obj.RecentlySaved = true;
        end


        function import(  )
        end
    end
end


