classdef UpDownStage < dsp.internal.MultirateAnalysis.MultirateStage

    properties
        n = 1;
    end

    methods
        function obj = UpDownStage( n )
            if nargin > 0
                if n == 0
                    error( message( 'dsp:MultirateAnalysis:invalidUpDownInit' ) );
                end
                obj.n = n;
            end
        end

        function uobj = horzcat( obj, a )
            if isa( a, 'dsp.internal.MultirateAnalysis.UpDownStage' )
                m = a.n;
                if obj.n * m < 0
                    error( message( 'dsp:MultirateAnalysis:oppositeUpDownConcat' ) );
                end
                uobj = dsp.internal.MultirateAnalysis.UpDownStage( obj.n * abs( m ) );
            else
                error( message( 'dsp:MultirateAnalysis:invalidUpDownConcat', class( a ) ) )
            end
        end


        function uobj = mrdivide( obj, m )
            arguments
                obj
                m( 1, 1 ){ mustBeReal, mustBePositive, mustBeInteger }
            end

            if mod( obj.n, m )
                error( message( 'dsp:MultirateAnalysis:notDivisible', obj.n, m ) );
            end
            uobj = dsp.internal.MultirateAnalysis.UpDownStage( obj.n / m );
        end

        function s = str( obj )

            if obj.n > 0
                s = sprintf( '(¡ü%d)', obj.n );
            else
                s = sprintf( '(¡ý%d)',  - obj.n );
            end
        end

        function b = isTrivial( obj )

            b = abs( obj.n ) == 1;
        end
    end
end

