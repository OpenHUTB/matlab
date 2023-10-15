classdef PropagationDelay < rfpcb.internal.apps.transmissionLineDesigner.model.Analysis

    methods

        function obj = PropagationDelay( TransmissionLine, Logger )

            arguments
                TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( Logger );
            obj.TransmissionLine = TransmissionLine;
            log( obj.Logger, '% PropagationDelay object created.' );
        end


        function compute( obj, SuppressOutput )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.PropagationDelay{ mustBeNonempty }
                SuppressOutput = true;
            end

            log( obj.Logger, '% PropagationDelay computed.' );
        end
    end
end

