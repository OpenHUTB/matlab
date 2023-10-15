classdef AnalysisPlots < rfpcb.internal.apps.transmissionLineDesigner.model.Analysis

    properties

        FrequencyRange( 1, : )double{ mustBeNonempty, mustBeNonzero, mustBeNumeric } = ( 900:10:1100 ) .* 1e6;
    end

    properties ( Constant, Hidden )

        Entities = { 'Sparameters',  ...
            'Current',  ...
            'Charge' };
    end

    methods

        function obj = AnalysisPlots( TransmissionLine, Logger )

            arguments
                TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
            end
            obj@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( Logger );


            obj.TransmissionLine = TransmissionLine;


            log( obj.Logger, '% Analysis Plot model object created.' )
        end


        function [ rangeString, rangeUnit ] = generateFreqRange( obj )


            minFreq = obj.Frequency * 0.9;
            maxFreq = obj.Frequency * 1.1;
            step = ( maxFreq - obj.Frequency ) / 10;
            [ tmpMin, minUnit ] = rfpcb.internal.apps.getNumUnit( minFreq );
            tmpMax = rfpcb.internal.apps.getNumWithUnit( maxFreq, minUnit );
            tmpStep = rfpcb.internal.apps.getNumWithUnit( step, minUnit );
            rangeString = [ num2str( tmpMin ), ':', num2str( tmpStep ), ':', num2str( tmpMax ) ];
            rangeUnit = minUnit;
        end
    end
end

