classdef ExportSectionModel < matlab.mixin.SetGet

    properties
        TransmissionLine
        Logger
    end

    methods

        function obj = ExportSectionModel( TransmissionLine, Logger )

            arguments
                TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj.TransmissionLine = TransmissionLine;
            obj.Logger = Logger;

            log( obj.Logger, '% ExportSectionModel object created.' )
        end
    end
end

