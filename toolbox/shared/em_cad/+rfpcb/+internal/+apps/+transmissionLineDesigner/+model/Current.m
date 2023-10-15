classdef Current < rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots

    methods

        function obj = Current( TransmissionLine, Logger )

            arguments
                TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots( TransmissionLine, Logger );
            obj.TransmissionLine = TransmissionLine;

            log( obj.Logger, '% Current object created.' )
        end


        function compute( obj, options )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Current{ mustBeNonempty }
                options.SuppressOutput = true;
            end


            currentFcn = @(  )current( obj.TransmissionLine, obj.Frequency );
            compute@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( obj, currentFcn, options.SuppressOutput );


            log( obj.Logger, '% Current computed.' );
        end
    end
end

