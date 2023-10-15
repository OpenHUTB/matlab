classdef ( Abstract )RFElement < rf.internal.rfbudget.Element




    properties ( SetObservable )
        Gain = rf.internal.rfbudget.RFElement.DefaultGain
        NF = rf.internal.rfbudget.RFElement.DefaultNF
        OIP2 = rf.internal.rfbudget.RFElement.DefaultOIP2
        OIP3 = rf.internal.rfbudget.RFElement.DefaultOIP3
        Zin = rf.internal.rfbudget.RFElement.DefaultZin
        Zout = rf.internal.rfbudget.RFElement.DefaultZout
    end

    properties ( Hidden, Constant )
        DefaultGain = 0
        DefaultNF = 0
        DefaultOIP2 = Inf
        DefaultOIP3 = Inf
        DefaultZin = 50
        DefaultZout = 50
    end

    methods ( Access = protected, Hidden )
        function p = makeInputParser( obj )
            p = inputParser;
            p.CaseSensitive = false;
            addParameter( p, 'Name', obj.DefaultName );
            addParameter( p, 'Gain', obj.DefaultGain );
            addParameter( p, 'NF', obj.DefaultNF );
            addParameter( p, 'OIP2', obj.DefaultOIP2 );
            addParameter( p, 'OIP3', obj.DefaultOIP3 );
            addParameter( p, 'Zin', obj.DefaultZin );
            addParameter( p, 'Zout', obj.DefaultZout );
        end

        function setParsedProperties( obj, p )
            if ~isvarname( p.Results.Name )
                error( message( 'rf:shared:ValidateMLNameNotAVarName',  ...
                    'element name', p.Results.Name ) )
            end
            obj.Name = p.Results.Name;
            obj.Gain = p.Results.Gain;
            obj.NF = p.Results.NF;
            obj.OIP2 = p.Results.OIP2;
            obj.OIP3 = p.Results.OIP3;
            obj.Zin = p.Results.Zin;
            obj.Zout = p.Results.Zout;
        end

        function setParsedOptions( obj, options )

            if isfield( options, 'Name' )
                obj.Name = options.Name;
            end
            if isfield( options, 'Gain' )
                obj.Gain = options.Gain;
            end
            if isfield( options, 'NF' )
                obj.NF = options.NF;
            end
            if isfield( options, 'OIP2' )
                obj.OIP2 = options.OIP2;
            end
            if isfield( options, 'OIP3' )
                obj.OIP3 = options.OIP3;
            end
            if isfield( options, 'Zin' )
                obj.Zin = options.Zin;
            end
            if isfield( options, 'Zout' )
                obj.Zout = options.Zout;
            end
        end
    end

    methods
        function obj = RFElement( options )
            arguments
                options.Name( 1, 1 )string{ mustBeValidVariableName }
                options.Gain( 1, 1 )double{ mustBeReal, mustBeFinite }
                options.NF( 1, 1 )double{ mustBeFinite, mustBeNonnegative }
                options.OIP2( 1, 1 )double{ mustBeReal, mustBeNonNan }
                options.OIP3( 1, 1 )double{ mustBeReal, mustBeNonNan }
                options.Zin( 1, 1 )double{ mustBeFinite }
                options.Zout( 1, 1 )double{ mustBeFinite }
            end
            narginchk( 0, 14 )
            setParsedOptions( obj, options )
        end

        function set.Gain( obj, value )
            validateattributes( value, { 'numeric' },  ...
                { 'nonempty', 'scalar', 'real', 'finite' }, '', 'Gain' )
            obj.Gain = value;
        end

        function set.NF( obj, value )
            validateattributes( value, { 'numeric' },  ...
                { 'nonempty', 'real', 'finite', 'nonnegative' }, '', 'NF' )
            if isa( obj, 'amplifier' ) && length( value ) > 1
                error( message( 'rf:rfbudget:UseNoiseParameters' ) )
            else
                validateattributes( value, { 'numeric' },  ...
                    { 'scalar' }, '', 'NF' )
            end
            obj.NF = value;
        end

        function set.OIP2( obj, value )
            validateattributes( value, { 'numeric' },  ...
                { 'nonempty', 'scalar', 'real', 'nonnan' }, '', 'OIP2' )
            obj.OIP2 = value;
        end

        function set.OIP3( obj, value )
            validateattributes( value, { 'numeric' },  ...
                { 'nonempty', 'scalar', 'real', 'nonnan' }, '', 'OIP3' )
            obj.OIP3 = value;
        end



        function set.Zin( obj, value )
            validateattributes( value, { 'numeric' },  ...
                { 'nonempty', 'scalar', 'finite' }, '', 'Zin' )
            if real( value ) <= 0
                error( message( 'rf:rfbudget:BadZin' ) )
            end
            obj.Zin = value;
        end

        function set.Zout( obj, value )
            validateattributes( value, { 'numeric' },  ...
                { 'nonempty', 'scalar', 'finite' }, '', 'Zout' )
            if real( value ) <= 0
                error( message( 'rf:rfbudget:BadZout' ) )
            end
            obj.Zout = value;
        end
    end

    methods ( Access = protected )
        function value = getNetworkData( obj )

            Z0 = 50;
            s11 = ( obj.Zin - Z0 ) / ( obj.Zin + Z0 );
            s22 = ( obj.Zout - Z0 ) / ( obj.Zout + Z0 );
            s12 = 0;

            s21 = 10 ^ ( obj.Gain / 20 ) *  ...
                4 * sqrt( real( obj.Zout ) / real( obj.Zin ) ) *  ...
                real( obj.Zin ) / abs( obj.Zin ) /  ...
                ( ( 1 + Z0 / obj.Zin ) * ( 1 + obj.Zout / Z0 ) );
            value = sparameters( [ s11, s12;s21, s22 ], 1e9, Z0 );
        end

        function copyProperties( in, out )

            out.Gain = in.Gain;
            out.NF = in.NF;
            out.OIP2 = in.OIP2;
            out.OIP3 = in.OIP3;
            out.Zin = in.Zin;
            out.Zout = in.Zout;
        end
    end

    methods ( Access = protected )
        function op = objectProperties( obj )
            op = cell( 0, 2 );
            if ~strcmp( obj.Name, obj.DefaultName )
                op{ end  + 1, 1 } = 'Name';
                op{ end , 2 } = sprintf( '''%s''', obj.Name );
            end
            if obj.Gain ~= obj.DefaultGain
                op{ end  + 1, 1 } = 'Gain';
                op{ end , 2 } = sprintf( '%.15g', obj.Gain );
            end
            if obj.NF ~= obj.DefaultNF
                op{ end  + 1, 1 } = 'NF';
                op{ end , 2 } = sprintf( '%.15g', obj.NF );
            end
            if obj.OIP2 ~= obj.DefaultOIP2
                op{ end  + 1, 1 } = 'OIP2';
                op{ end , 2 } = sprintf( '%.15g', obj.OIP2 );
            end
            if obj.OIP3 ~= obj.DefaultOIP3
                op{ end  + 1, 1 } = 'OIP3';
                op{ end , 2 } = sprintf( '%.15g', obj.OIP3 );
            end
            if obj.Zin ~= obj.DefaultZin
                op{ end  + 1, 1 } = 'Zin';
                op{ end , 2 } = num2str( obj.Zin, '%.15g' );
            end
            if obj.Zout ~= obj.DefaultZout
                op{ end  + 1, 1 } = 'Zout';
                op{ end , 2 } = num2str( obj.Zout, '%.15g' );
            end
        end
    end

    methods ( Hidden )
        function exportScript( obj, sw, vn )
            op = objectProperties( obj );
            add( sw, '%s = %s', vn, class( obj ) )
            nrows = size( op, 1 );
            if nrows == 0
                addcr( sw, ';' )
            elseif nrows == 1
                addcr( sw, '(%s=%s);', op{ 1, 1 }, op{ 1, 2 } )
            else
                addcr( sw, '( ...' )
                for i = 1:nrows - 1
                    addcr( sw, '    %s=%s, ...', op{ i, 1 }, op{ i, 2 } )
                end
                addcr( sw, '    %s=%s);', op{ nrows, 1 }, op{ nrows, 2 } )
            end
        end
    end

    methods ( Static, Hidden )
        function obj = loadobj( s )



            obj = s;
            if isempty( obj.OIP2 )
                obj.OIP2 = rf.internal.rfbudget.RFElement.DefaultOIP2;
            end
        end
    end

    methods ( Static, Hidden )
        function str = nodeStr( node, stage )
            str = sprintf( '%d', node );
            if stage > 0
                str = sprintf( '%s_%d', str, stage );
            end
        end

        function lines = noiseSource( nf, z0, lines, idx, in, out, ckt )
            Fmin = 10 .^ ( nf / 10 );
            Rn = z0 * ( Fmin - 1 ) / 4;
            VnVariance = 4 * rfbudget.kT * Rn;


            Scorr = 0;
            freq = 0;
            S = sparameters( Scorr, freq, z0 );
            lines{ end  + 1, 1 } = sprintf( 'a1_yc%d %s 0', idx, in );
            if ~isempty( ckt )
                toks = split( lines{ end  } )';
                rf.internal.rfengine.elements.A1.add( ckt, toks{ : }, S )
            end

            lines{ end  + 1, 1 } = sprintf( 'av%d %s %s %.15g', idx, in, out, VnVariance );
            if ~isempty( ckt )
                toks = split( lines{ end  } )';
                rf.internal.rfengine.elements.AV.add( ckt, toks{ 1:end  - 1 }, VnVariance )
            end

            Scorr = 1e12;
            S = sparameters( Scorr, freq, z0 );
            lines{ end  + 1, 1 } = sprintf( 'a1_myc%d %s 0', idx, out );
            if ~isempty( ckt )
                toks = split( lines{ end  } )';
                rf.internal.rfengine.elements.A1.add( ckt, toks{ : }, S )
            end
        end

        function lines = shuntZ( name, z, z0, lines, idx, in, ckt )
            if isreal( z )
                lines{ end  + 1, 1 } = sprintf( 'r_%s%d %s 0 %.15g', name, idx, in, z );
                if ~isempty( ckt )
                    toks = split( lines{ end  } )';
                    rf.internal.rfengine.elements.R.add( ckt, toks{ : } )
                end
            else
                lines{ end  + 1, 1 } = sprintf( 'a1_%s%d %s 0', name, idx, in );
                zparams = [ real( z );z ];
                freqs = [ 0;1 ];
                S = sparameters( ( zparams - z0 ) ./ ( zparams + z0 ), freqs );
                if ~isempty( ckt )
                    toks = split( lines{ end  } )';
                    rf.internal.rfengine.elements.A1.add( ckt, toks{ : }, S )
                end
            end
        end

        function lines = seriesZ( name, z, z0, lines, idx, in, out, ckt )
            if isreal( z )
                lines{ end  + 1, 1 } = sprintf( 'r_%s%d %s %s %.15g', name, idx, in, out, z );
                if ~isempty( ckt )
                    toks = split( lines{ end  } )';
                    rf.internal.rfengine.elements.R.add( ckt, toks{ : } )
                end
            else
                lines{ end  + 1, 1 } = sprintf( 'a1_%s%d %s %s', name, idx, in, out );
                zparams = [ real( z );z ];
                freqs = [ 0;1 ];
                S = sparameters( ( zparams - z0 ) ./ ( zparams + z0 ), freqs );
                if ~isempty( ckt )
                    toks = split( lines{ end  } )';
                    rf.internal.rfengine.elements.A1.add( ckt, toks{ : }, S )
                end
            end
        end
    end

    methods ( Hidden )
        function lines = exportRFEngineElement( obj, idx, node1, node2, ckt, simulateNoise )


            if nargin < 5
                ckt = [  ];
            end

            lines = {  };
            stage = 0;
            z0 = 50;

            in = rf.internal.rfbudget.RFElement.nodeStr( node1, stage );
            if simulateNoise
                stage = stage + 1;
                out = rf.internal.rfbudget.RFElement.nodeStr( node1, stage );
                lines = rf.internal.rfbudget.RFElement.noiseSource(  ...
                    obj.NF, z0, lines, idx, in, out, ckt );
                in = out;
            end

            lines = rf.internal.rfbudget.RFElement.shuntZ(  ...
                'in', obj.Zin, z0, lines, idx, in, ckt );

            name = sprintf( 'aa%d', idx );
            if ~strcmpi( obj.Name, obj.DefaultName ) && ~strcmpi( obj.Name, name )
                name = sprintf( 'aa_%s%d', obj.Name, idx );
            end
            stage = stage + 1;
            out = rf.internal.rfbudget.RFElement.nodeStr( node1, stage );
            str = sprintf( '%s %s 0 %s 0', name, in, out );
            str = sprintf( '%s Gain=%.15g', str, obj.Gain );
            str = sprintf( '%s OIP2=%.15g', str, obj.OIP2 );
            str = sprintf( '%s OIP3=%.15g', str, obj.OIP3 );
            str = sprintf( '%s Zin=%s', str, num2str( obj.Zin, '%.15g' ) );
            str = sprintf( '%s Zout=%s', str, num2str( obj.Zout, '%.15g' ) );
            lines{ end  + 1, 1 } = str;
            if ~isempty( ckt )
                toks = split( lines{ end  } )';
                rf.internal.rfengine.elements.AA.add( ckt, toks{ : } )
            end

            lines = rf.internal.rfbudget.RFElement.seriesZ(  ...
                'out', obj.Zout, z0, lines, idx, out, sprintf( '%d', node2 ), ckt );
        end
    end



    methods ( Hidden )
        function Ca = getCa( obj, ~, ~ )
            Fm = 10 .^ ( obj.NF / 10 );
            z0 = 50;
            Rn = z0 * ( Fm - 1 ) / 4;
            y0 = 1 / z0;
            kT = rfbudget.kT;
            Ca = 4 * kT * [ Rn, ( Fm - 1 ) / 2 - Rn * conj( y0 );
                ( Fm - 1 ) / 2 - Rn * y0, Rn * abs( y0 ) ^ 2 ];
        end



        function gain = getGain( obj, ~ )
            gain = obj.Gain;
        end

        function NF = getNF( obj, ~ )
            NF = obj.NF;
        end

        function OIP2 = getOIP2( obj )
            OIP2 = obj.OIP2;
        end

        function OIP3 = getOIP3( obj )
            OIP3 = obj.OIP3;
        end
    end



    methods ( Hidden, Access = protected )
        function plist1 = getLocalPropertyList( obj )
            plist1.Name = obj.Name;
            plist1.Gain = obj.Gain;
            plist1.NF = obj.NF;
            plist1.OIP2 = obj.OIP2;
            plist1.OIP3 = obj.OIP3;
            plist1.Zin = obj.Zin;
            plist1.Zout = obj.Zout;
        end

        function initializeTerminalsAndPorts( obj )

            obj.Ports = { 'p1', 'p2' };
            obj.Terminals = { 'p1+', 'p2+', 'p1-', 'p2-' };
        end
    end
end
