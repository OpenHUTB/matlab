classdef Analysis < matlab.mixin.SetGet







    properties ( Constant = true, Hidden )


        UNITS = [ { 'Hz' };{ 'kHz' };{ 'MHz' };{ 'GHz' };{ 'THz' } ];
    end

    properties
        TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
        Frequency( 1, 1 )double{ mustBeNonempty, mustBeNonzero, mustBeNumeric } = 1e9;
    end

    properties

        Value
    end

    properties ( Hidden )
        Logger
    end

    methods

        function obj = Analysis( Logger )





            arguments
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj.Logger = Logger;
        end


        function update( obj )

            if isempty( obj.TransmissionLine )
                clear( obj );
            else
                compute( obj );
            end
        end

        function compute( obj, ComputeFcn, SuppressOutput )

            arguments
                obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Analysis{ mustBeNonempty };
                ComputeFcn( 1, 1 )function_handle{ mustBeNonempty }
                SuppressOutput( 1, 1 ){ mustBeNumericOrLogical } = false;
            end

            if SuppressOutput
                obj.Value = ComputeFcn(  );
            else
                ComputeFcn(  );
            end
        end


        function [ freqString, freqUnit ] = generateAppFrequency( obj )


            [ freqString, freqUnit ] = rfpcb.internal.apps.getNumUnit( obj.Frequency );
            freqString = num2str( freqString );
        end


        function clear( obj )
            obj.Value = [  ];
        end
    end
end

