classdef MixerIMT < rf.internal.rfbudget.RFElement




    properties ( Dependent )
        FileName
        UseDataFile( 1, 1 )logical
        ReferenceInputPower{ mustBeNumeric, mustBeNonempty, mustBeScalarOrEmpty,  ...
            mustBeFinite, mustBeReal }
        NominalOutputPower{ mustBeNumeric, mustBeNonempty, mustBeScalarOrEmpty,  ...
            mustBeFinite, mustBeReal }
    end

    properties ( Access = private )
        RFPlotFreq
    end

    properties ( Access = private )
        PrivateUseDataFile = mixerIMT.DefaultPrivateUseDataFile
        PrivateFileName = mixerIMT.DefaultPrivateFileName
        PrivateReferenceInputPower = mixerIMT.DefaultPrivateReferenceInputPower;
        PrivateNominalOutputPower = mixerIMT.DefaultPrivateNominalOutputPower;
    end

    properties ( Hidden, Constant )
        DefaultPrivateUseDataFile = false
        DefaultPrivateFileName = [  ]
        DefaultPrivateReferenceInputPower =  - 15;
        DefaultPrivateNominalOutputPower =  - 5;
    end

    properties

        LO{ mustBeNumeric, mustBeNonempty, mustBeScalarOrEmpty,  ...
            mustBeFinite, mustBeReal, mustBeNonnegative } = 0.1e9;
        ConverterType
        IMT{ mustBeNumeric, mustBeNonempty, mustBeSquareMatrix,  ...
            mustBeFinite, mustBeReal, mustBeNonnegative } = [ 99, 99, 99;99, 0, 99;99, 99, 99 ];
    end

    properties ( Constant, Access = protected )
        HeaderDescription = 'MixerIMT'
        DefaultName = 'MixerIMT';
    end

    properties ( Hidden, Constant )

        ConverterTypeValues = { 'Up', 'Down' };
    end

    methods
        function obj = MixerIMT( varargin )
            parserObj = makeParser( obj );
            parse( parserObj, varargin{ : } );
            setProperties( obj, parserObj );


            filename = obj.FileName;
            if ~isempty( filename )
                obj = read( obj, filename );
            end
        end
    end

    methods ( Access = protected, Hidden )
        function p = makeParser( obj )

            p = inputParser;
            p.CaseSensitive = false;
            addParameter( p, 'Name', obj.DefaultName );
            addParameter( p, 'LO', 0.1e9 );
            addParameter( p, 'NominalOutputPower',  - 5 );
            addParameter( p, 'ReferenceInputPower',  - 15 );
            addParameter( p, 'NF', 0 );
            addParameter( p, 'Zin', 50 );
            addParameter( p, 'Zout', 50 );
            addParameter( p, 'ConverterType', 'Up' );
            addParameter( p, 'IMT', [ 99, 99, 99;99, 0, 99;99, 99, 99 ] );
            addParameter( p, 'UseDataFile', 0 );
            addParameter( p, 'FileName', '' );
        end


        function setProperties( obj, p )
            obj.Name = p.Results.Name;
            obj.LO = p.Results.LO;
            obj.ReferenceInputPower = p.Results.ReferenceInputPower;
            obj.NominalOutputPower = p.Results.NominalOutputPower;
            obj.NF = p.Results.NF;
            obj.Zin = p.Results.Zin;
            obj.Zout = p.Results.Zout;
            obj.ConverterType = p.Results.ConverterType;
            obj.IMT = p.Results.IMT;
            obj.UseDataFile = p.Results.UseDataFile;
            obj.FileName = p.Results.FileName;
        end
    end

    methods

        function set.FileName( obj, value )
            validateattributes( value,  ...
                { 'char', 'string' }, { 'scalartext' }, '', 'FileName' )
            value = convertStringsToChars( value );

            if ~isempty( value )
                [ ~, ~, ext ] = fileparts( value );
                validatestring( ext, { '.s2d' }, '', 'FileName' );
            end
            if isequal( value, obj.FileName )
                return
            end
            if ~isempty( value )

                fd = read( obj, value );
                obj.IMT = fd.IMT;
                obj.PrivateNominalOutputPower = fd.NominalOutputPower;
                obj.PrivateReferenceInputPower = fd.ReferenceInputPower;
            end
            obj.PrivateFileName = value;
        end

        function value = get.FileName( obj )
            if isempty( obj.PrivateFileName )
                value = [  ];
            else
                value = obj.PrivateFileName;
            end
        end

        function set.IMT( obj, value )
            if isempty( value )
                error( message( 'rf:shared:InvalidIMTEntries',  ...
                    'Spur table' ) )
            end
            validateattributes( value,  ...
                { 'numeric' },  ...
                { 'nonempty', 'square', '>=', 0, '<=', 99, 'real', 'nonnegative' },  ...
                '', 'Spur table' );
            if numel( value ) < 4
                error( message( 'rf:shared:InvalidSize' ) )
            end
            if value( 2, 2 ) ~= 0
                error( message( 'rf:shared:ValidRange',  ...
                    'Spur value(2,2)', value( 2, 2 ), 'Zero' ) );
            end
            obj.IMT = value;
        end

        function set.UseDataFile( obj, value )
            validateattributes( value, { 'logical', 'numeric' },  ...
                { 'nonempty', 'scalar', 'finite' }, '', 'UseDataFile' )
            obj.PrivateUseDataFile = value;
        end

        function value = get.UseDataFile( obj )
            value = obj.PrivateUseDataFile;
        end

        function set.ConverterType( obj, value )
            value = validatestring( value, { 'Down', 'Up' } );
            obj.ConverterType = value;
        end

        function value = get.ReferenceInputPower( obj )
            value = obj.PrivateReferenceInputPower;
        end

        function set.ReferenceInputPower( obj, value )
            if obj.UseDataFile
                error( message( 'rf:shared:ReadOnly' ) )
            else
                validateattributes( value, { 'logical', 'numeric' },  ...
                    { 'nonempty', 'scalar', 'finite' }, '', 'ReferenceInputPower' )
                obj.PrivateReferenceInputPower = value;
            end
        end

        function value = get.NominalOutputPower( obj )
            value = obj.PrivateNominalOutputPower;
        end

        function set.NominalOutputPower( obj, value )
            if obj.UseDataFile
                error( message( 'rf:shared:ReadOnly' ) )
            else
                validateattributes( value, { 'logical', 'numeric' },  ...
                    { 'nonempty', 'scalar', 'finite' }, '', 'NominalOutputPower' )
                obj.PrivateNominalOutputPower = value;
            end
        end
    end

    methods
        function s = sparameters( obj, freq, Z0 )

            arguments
                obj( 1, 1 )
                freq double{ mustBeNumeric, mustBeNonempty,  ...
                    mustBeFinite, mustBeReal, mustBeNonnegative, mustBeVector }
                Z0{ mustBeNumeric, mustBeNonempty, mustBeScalarOrEmpty,  ...
                    mustBeFinite, mustBeReal, mustBePositive } = 50;
            end

            freq = freq( : );

            Gain = obj.NominalOutputPower - obj.ReferenceInputPower;

            s11 = ( obj.Zin - Z0 ) / ( obj.Zin + Z0 ) * ones( size( freq ) );
            s22 = ( obj.Zout - Z0 ) / ( obj.Zout + Z0 ) * ones( size( freq ) );
            s12 = zeros( size( freq ) );


            s21 = 10 ^ ( Gain / 20 ) *  ...
                4 * sqrt( real( obj.Zout ) / real( obj.Zin ) ) *  ...
                real( obj.Zin ) / abs( obj.Zin ) /  ...
                ( ( 1 + Z0 / obj.Zin ) * ( 1 + obj.Zout / Z0 ) ) * ones( size( freq ) );

            parameters( 1, 1, : ) = s11;
            parameters( 1, 2, : ) = s12;
            parameters( 2, 1, : ) = s21;
            parameters( 2, 2, : ) = s22;

            s = sparameters( parameters, freq, Z0 );
        end

        function varargout = rfplot( obj, varargin )

            validateattributes( varargin{ 1 }, { 'numeric' },  ...
                { 'nonempty', 'vector', 'nonnan', 'finite', 'real', 'positive' },  ...
                'mixerIMT', 'Frequency' );
            fin = varargin{ 1 };

            if obj.UseDataFile
                if isempty( obj.FileName )
                    error( message( 'rf:shared:NotEmpty' ) );
                end
            end

            pin = obj.ReferenceInputPower;

            if nargin >= 3
                parent = varargin{ 3 };
            else
                parent = gca;
            end

            index = 1;
            sizeSpurs = size( obj.IMT );
            bigSpurs = ones( sizeSpurs( 1 ) + 2, sizeSpurs( 2 ) + 2 ) * 99;
            bigSpurs( 1:sizeSpurs( 1 ), 1:sizeSpurs( 2 ) ) = obj.IMT;
            spurs.Data = bigSpurs;

            obj.IMT = [ spurs.Data ];

            data1 = nport( 'default.s2p' );
            data = data1.NetworkData;

            z0 = 50;

            if convertfreq( obj, fin, false ) < 0
                error( message( 'rf:shared:FinIsTooSmall', fin ) )
            end
            spurdata = [  ];
            spurdata.NMixers = 1;
            spurdata.TotalNMixers = 1;
            spurdata.Fin( 1 ) = fin;
            spurdata.Pin( 1 ) = pin;
            spurdata.Idxin{ 1 } = 'Desired signal';
            spurdata.Freq{ 1 }( 1 ) = fin;
            spurdata.Pout{ 1 }( 1 ) = pin;
            spurdata.Indexes{ 1 }{ 1 } = 'Desired signal';
            spurdata.Freq{ 2 } = [  ];
            spurdata.Pout{ 2 } = [  ];
            spurdata.Indexes{ 2 }{ 1 } = '';
            zl = z0;
            zs = z0;
            spurdata = calcemixspur( obj, spurdata, zl, zs, z0, 1 );
            spurdata.Fin( 1 ) = [  ];
            spurdata.Fin( 1 ) = fin;
            spurdata.Pin( 1 ) = [  ];
            spurdata.Pin( 1 ) = pin;
            spurdata.Indexes{ 1 }{ 1 } = 'Input signal';

            hlines = obj.mixerimtspurplot( data, spurdata, index, pin, fin, parent );

            if nargout == 1
                varargout{ 1 } = hlines;
            end

        end

    end

    methods ( Hidden )
        varargout = mixerimtspurplot( varargin )
        spurdata = addmixerimtspur( h, spurdata, zl, zs, z0, cktindex )
    end

    methods ( Static, Hidden )
        function obj = loadobj( s )
            if isstruct( s )
                obj = mixerIMT;
                p = properties( obj );
                for k = 1:length( p )
                    if isfield( s, p{ k } ) && ~isempty( s.( p{ k } ) )
                        obj.( p{ k } ) = s.( p{ k } );
                    end
                end
            else
                obj = loadobj@rf.internal.rfbudget.RFElement( s );

            end
        end
    end

    methods ( Hidden, Access = protected )
        function plist1 = getLocalPropertyList( obj )
            plist1.Name = obj.Name;
            plist1.UseDataFile = obj.UseDataFile;
            if obj.UseDataFile
                plist1.FileName = obj.FileName;
                plist1.ReferenceInputPower = obj.ReferenceInputPower;
                plist1.NominalOutputPower = obj.NominalOutputPower;
            else
                plist1.ReferenceInputPower = obj.ReferenceInputPower;
                plist1.NominalOutputPower = obj.NominalOutputPower;
                plist1.NF = obj.NF;
                plist1.ConverterType = obj.ConverterType;
                plist1.LO = obj.LO;
                plist1.Zin = obj.Zin;
                plist1.Zout = obj.Zout;
                plist1.IMT = obj.IMT;
                plist1.UseDataFile = obj.UseDataFile;
            end
        end

        function initializeTerminalsAndPorts( obj )
            obj.Ports = { 'p1', 'p2' };
            obj.Terminals = { 'p1+', 'p2+', 'p1-', 'p2-' };
        end

        function out = localClone( in )
            out = mixerIMT( 'Name', in.Name, 'LO', in.LO,  ...
                'ConverterType', in.ConverterType,  ...
                'NF', in.NF,  ...
                'Zin', in.Zin, 'Zout', in.Zout,  ...
                'IMT', in.IMT );
            copyProperties( in, out )
            out.PrivateFileName = in.FileName;
            out.PrivateUseDataFile = in.UseDataFile;
            out.PrivateReferenceInputPower = in.ReferenceInputPower;
            out.PrivateNominalOutputPower = in.NominalOutputPower;
        end
    end

    methods ( Hidden )
        function rStr = convertVectorToString( ~, val )


            [ y, e ] = engunits( val );


            if numel( val ) ~= 1
                rStr = mat2str( y, 7 );
            else
                rStr = sprintf( '%.15g', y );
            end

            if e ~= 1
                rStr = sprintf( '%s*1e%d', rStr, round( log10( 1 / e ) ) );
            end

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
            gain = obj.NominalOutputPower - obj.ReferenceInputPower;
        end

        function NF = getNF( obj, ~ )
            if obj.UseDataFile
                NF = 0;
            else
                NF = obj.NF;
            end
        end

        function OIP3 = getOIP3( obj )%#ok<MANU>
            OIP3 = Inf;
        end
    end

    methods ( Hidden )

        function out = convertfreq( h, in, varargin )




            p = inputParser;
            addOptional( p, 'throwmessage', true );
            addParameter( p, 'isspurcalc', false );
            parse( p, varargin{ : } );

            throwmsg = p.Results.throwmessage;
            spurbool = p.Results.isspurcalc;

            switch h.ConverterType
                case 'Down'
                    out = in - h.LO;
                    negidx = out <= 0;
                    if spurbool
                        out( negidx ) =  - 1 * out( negidx );
                    else
                        if all( negidx )
                            out =  - out;
                        end
                    end
                case 'Up'
                    out = in + h.LO;
            end
            out = sort( out );
            if throwmsg
                index = find( out == 0.0 );
                if any( index )
                    out( index ) = 1.0;
                end
                if any( out < 0 )
                    rferrhole = '';
                    if isempty( h.Block )
                        rferrhole = [ h.Name, ': ' ];
                    end
                    error( message( 'rf:shared:MixerNegativeOutFrequency', rferrhole ) );
                end
            end
        end

        function spurdata = calcemixspur( h, spurdata, zl, zs, z0, cktindex )




            narginchk( 6, 7 );

            fin = spurdata.Fin;
            fin( fin == 0.0 ) = eps;
            pin = spurdata.Pin;
            idxin = spurdata.Idxin;
            [ pl, freq ] = calcpout( h, pin, fin, zl, zs, z0 );
            k = 1;
            if isempty( spurdata.Pout{ k + cktindex } )
                psignal = max( pl );
            else
                psignal = spurdata.Pout{ k + cktindex }( 1 );
            end
            idx = find( pl > ( psignal - 99 ) );
            if ~isempty( idx )
                freq = freq( idx );
                pl = pl( idx );
                idxin = idxin( idx );
                n = length( spurdata.Freq{ k + cktindex } );
                m = length( freq );
                spurdata.Freq{ k + cktindex } = [ spurdata.Freq{ k + cktindex };freq ];
                spurdata.Pout{ k + cktindex } = [ spurdata.Pout{ k + cktindex };pl ];
                for ii = 1:m
                    spurdata.Indexes{ cktindex + 1 }{ n + ii, 1 } = idxin{ ii };
                end
            end


            spurdata.Fin = spurdata.Freq{ k + 1 }( 1 );
            spurdata.Pin = spurdata.Pout{ k + 1 }( 1 );
            spurdata = addmixerimtspur( h, spurdata, zl, zs, z0, cktindex );
        end

        function [ pl, freqout ] = calcpout( h, pavs, freq, zl, zs, z0, varargin )




            p = inputParser;
            addParameter( p, 'isspurcalc', false );
            parse( p, varargin{ : } );


            freqout = convertfreq( h, freq, false, 'isSpurCalc', p.Results.isspurcalc );
            idx = find( freqout >= 0 );
            freq = freq( idx );
            nfreq = length( freq );
            if ~isscalar( pavs );pavs = pavs( idx );end
            if ~isscalar( zl );zl = zl( idx );end
            if ~isscalar( zs );zs = zs( idx );end
            if ~isscalar( z0 );z0 = z0( idx );end

            sparam = sparameters( h, freq, z0 );

            s3d = sparam.Parameters;
            gammas = z2gamma( zs, z0 );
            gammal = z2gamma( zl, z0 );
            gammaout = s3d( 2, 2, : ) + s3d( 1, 2, : ) .* s3d( 2, 1, : ) .* gammas ./  ...
                ( 1 - s3d( 1, 1, : ) .* gammas );
            gammaout = reshape( gammaout, [ nfreq, 1 ] );
            temp = ( abs( 1 - reshape( s3d( 1, 1, : ), [ nfreq, 1 ] ) .* gammas ) .^ 2 );
            temp2 = temp .* ( abs( 1 - gammaout .* gammal ) .^ 2 );
            temp3 = ( 1 - abs( gammas ) .^ 2 ) .* ( abs( reshape( s3d( 2, 1, : ), [ nfreq, 1 ] ) ) .^ 2 );
            temp2( temp2 == 0 ) = eps;
            gt = ( temp3 .* ( 1 - abs( gammal ) .^ 2 ) ) ./ temp2;
            pl = 10 * log10( abs( gt ) ) + pavs;
        end

        function h = read( h, filename, varargin )


            if nargin == 1
                filename = '';
            end

            data = rfdata.data;
            data = read( data, 'default.s2p' );

            if ~isa( data, 'rfdata.data' )
                setrfdata( h, rfdata.data );
                data = get( h, 'AnalyzedResult' );
            end
            if hasreference( data )
                data.Reference.Date = '';
            end

            if isempty( h.RFPlotFreq ) && isempty( varargin )
                h.RFPlotFreq = 1e9;
                data = read( data, filename );
                filedata = data.getreference.MixerSpurData;
                if isempty( filedata ) || isempty( data.getreference.NetworkData ) ||  ...
                        isempty( data.getreference.NoiseData ) || isempty( data.getreference.MixerSpurData )
                    error( message( 'rf:shared:NoIMTSpurData' ) );
                end
                sparam = sparameters( data.S_Parameters, data.Freq );
                new_Sparam = rfinterp1( sparam, h.RFPlotFreq, 'extrap' );
                sparam_value = new_Sparam.Parameters( 2, 1 );
                d = 20 * log10( abs( sparam_value ) );

                h.IMT = filedata.Data;
                h.PrivateReferenceInputPower = filedata.PinRef;
                h.PrivateNominalOutputPower = ( filedata.PinRef + d );

            else
                if isempty( varargin )
                    h.RFPlotFreq = 2.1e9;
                else
                    h.RFPlotFreq = varargin{ 1 };
                end
                sparam = sparameters( data.S_Parameters, data.Freq );
                new_Sparam = rfinterp1( sparam, h.RFPlotFreq, 'extrap' );
                sparam_value = new_Sparam.Parameters( 2, 1 );
                d = 20 * log10( abs( sparam_value ) );
                h.PrivateNominalOutputPower = ( h.PrivateReferenceInputPower + d );
            end

            h.UseDataFile = 1;

            if all( data.NF == 0 )
                restore( h );
            end
        end
    end
end

function mustBeSquareMatrix( a )
[ n, m ] = size( a );
if ( n ~= m )
    error( message( 'rf:shared:NotSquareMatrix' ) );
end
end

