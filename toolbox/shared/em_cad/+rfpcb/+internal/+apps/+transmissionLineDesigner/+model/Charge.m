classdef Charge < rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots




    methods

        function obj = Charge( TransmissionLine, Logger )

            arguments
                TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots( TransmissionLine, Logger );
            obj.TransmissionLine = TransmissionLine;

            log( obj.Logger, '% Charge object created.' )
        end


        function compute( obj, options )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Charge{ mustBeNonempty }
                options.SuppressOutput = true;
            end


            chargeFcn = @(  )charge( obj.TransmissionLine, obj.Frequency );
            compute@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( obj, chargeFcn, options.SuppressOutput );


            log( obj.Logger, '% Charge plot computed.' )
        end
    end
end

