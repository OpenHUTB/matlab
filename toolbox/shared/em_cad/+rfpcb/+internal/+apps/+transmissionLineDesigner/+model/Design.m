classdef Design < rfpcb.internal.apps.transmissionLineDesigner.model.Analysis

    properties

        Impedance( 1, 1 )double{ mustBeNonempty, mustBeScalarOrEmpty, mustBeNonNan, mustBeFinite, mustBeReal, mustBePositive } = 50;
    end

    methods

        function obj = Design( TransmissionLine, Logger )


            arguments
                TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( Logger );
            obj.TransmissionLine = TransmissionLine;

            log( obj.Logger, '% Design object created.' )
        end


        function rtn = compute( obj, options )


            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Design{ mustBeNonempty }
                options.SuppressOutput = true;%#ok<INUSA>
            end


            rtn = design( obj.TransmissionLine, obj.Frequency, 'Z0', obj.Impedance );


            log( obj.Logger, '% Design computed.' );
        end
    end
end


