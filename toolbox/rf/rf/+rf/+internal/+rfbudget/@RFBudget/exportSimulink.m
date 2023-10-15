function varargout = exportSimulink( obj, options )

arguments
    obj( 1, 1 )
    options.ModelName{ mustBeTextScalar } = ""
    options.Rx( 1, 1 ){ mustBeInteger, mustBePositive } = 1
    options.Tx( 1, 1 ){ mustBeInteger, mustBePositive } = 1
end
if options.Rx > 1 && options.Tx > 1
    error( message( 'rf:rfsystem:NoMIMO' ) )
end

modelName = convertStringsToChars( options.ModelName );
num = options.Rx * options.Tx;

if ~obj.Computable
    return
end
v = ver;
installedProducts = { v( : ).Name };
haveSimulink = builtin( 'license', 'test', 'SIMULINK' ) &&  ...
    any( strcmp( 'Simulink', installedProducts ) );
haveRFBlockset = builtin( 'license', 'test', 'RF_Blockset' ) &&  ...
    any( strcmp( 'RF Blockset', installedProducts ) );
if ~haveSimulink || ~haveRFBlockset
    error( message( 'rf:rfbudget:NeedRFBLKS' ) )
end

load_system( 'simulink' )
load_system( 'simrfV2elements' )
load_system( 'simrfV2util1' )
load_system( 'simrfV2sources1' )
load_system( 'simrfV2systems' )
load_system( 'rfBudgetAnalyzer_lib' )



freqIdx = 1;
InputFreq = obj.InputFrequency( freqIdx );
OutputFreqs = obj.OutputFrequency( freqIdx, : );


inputIQ = ( InputFreq == 0 );
outputIQ = ( OutputFreqs( end  ) == 0 );
inOrOutputIQ = ( inputIQ || outputIQ );

if inputIQ && all( OutputFreqs == 0 )
    numConfigurations = 2;
else
    numConfigurations = 1;
end

if isempty( modelName )
    modelHandle = new_system( '', 'model' );
    modelName = get_param( modelHandle, 'Name' );
else
    new_system( modelName, 'model' );
    modelHandle = get_param( modelName, 'Handle' );
end

y = 150;
dx = 40;
dy = 100;
kIn = 1;
kIn2 = 1;
kNoise = 1;
kOut = 1;
kOut2 = 1;
kAnt = 1;
for k = 1:num
    x = 100;
    RxAnt = 0;
    if k == 1 || ( options.Rx > 1 )
        src = 'simulink/Sources/In1';
        p = get_param( src, 'Position' );
        pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - inputIQ ) * dy / 2 );
        h = add_block( src, sprintf( '%s/In%d', modelName, kIn ),  ...
            'Position', pos, 'SignalType', 'complex', 'Interpolate', 'off' );
        kIn = kIn + 1;
        ph = get_param( h, 'PortHandles' );
        outport( 1 ) = ph.Outport;
        if inputIQ
            pos = obj.newPos( p, x, y + dy * ( 0.6 + 1 ) / 2 );
            h = add_block( src, sprintf( '%s/In%d', modelName, kIn ),  ...
                'Position', pos, 'SignalType', 'complex', 'Interpolate', 'off' );
            kIn = kIn + 1;
            ph = get_param( h, 'PortHandles' );
            outport( 2 ) = ph.Outport;
        end
        x = pos( 3 ) + dx;
        freqdelta = 0;

        RxAnt = isa( obj.Elements( 1 ), 'rfantenna' ) && strcmpi( obj.Elements( 1 ).Type, 'Receiver' );
        if RxAnt
            src = 'rfBudgetAnalyzer_lib/Available Input Power';
            p = get_param( src, 'Position' );
            pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - inputIQ ) * dy / 2 );
            h = add_block( src, sprintf( '%s/Available \nInput Power%d', modelName, kAnt ), 'Position', pos );
            kAnt = kAnt + 1;
            InputPower = obj.AvailableInputPower - obj.Elements( 1 ).Gain;
            set( h, 'InputPower', sprintf( '%.15g', InputPower ) );
            ph = get( h, 'PortHandles' );
            add_line( modelName, outport( 1 ), ph.Inport, 'autorouting', 'on' )
            outport( 1 ) = ph.Outport;
            freq = InputFreq;
            elem = obj.Elements( 1 );
            if inputIQ
                pos = obj.newPos( p, x, y + dy * ( 0.6 + 1 ) / 2 );
                h = add_block( src, sprintf( '%s/Available \nInput Power%d', modelName, kAnt ), 'Position', pos );
                kAnt = kAnt + 1;
                set( h, 'InputPower', sprintf( '%.15g', InputPower ) );
                ph = get( h, 'PortHandles' );
                add_line( modelName, outport( 2 ), ph.Inport, 'autorouting', 'on' )
                outport( 2 ) = ph.Outport;
            end
            x = pos( 3 ) + dx;
            [ x, rconn ] = rbBlocks( elem, modelName, x,  ...
                y + ( nargin < 2 ) * inOrOutputIQ * 0.6 * dy / 2,  ...
                dx, dy, outport, freq, obj, 1, freqdelta, freqIdx );
        else
            [ freq, ~, freq_prefix ] = obj.engunitsGLimited( InputFreq );

            src = 'simrfV2util1/Inport';
            p = get_param( src, 'Position' );
            pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - inputIQ ) * dy / 2 );
            h = add_block( src, sprintf( '%s/Inport%d', modelName, kIn2 ),  ...
                'Position', pos );
            kIn2 = kIn2 + 1;
            set_param( h,  ...
                'SimulinkInputSignalType', 'Power',  ...
                'CarrierFreq', sprintf( '%.15g', freq ),  ...
                'CarrierFreq_unit', [ freq_prefix, 'Hz' ],  ...
                'ZS', '50' );
            ph = get_param( h, 'PortHandles' );
            rconn = ph.RConn;
            add_line( modelName, outport( 1 ), ph.Inport, 'autorouting', 'on' )
            if inputIQ
                pos = obj.newPos( p, x, y + dy * ( 0.6 + 1 ) / 2 );
                h = add_block( src, sprintf( '%s/Inport%d', modelName, kIn2 ),  ...
                    'Position', pos );
                kIn2 = kIn2 + 1;
                set_param( h,  ...
                    'SimulinkInputSignalType', 'Power',  ...
                    'CarrierFreq', sprintf( '%.15g', freq ),  ...
                    'CarrierFreq_unit', [ freq_prefix, 'Hz' ],  ...
                    'ZS', '50' );
                ph = get_param( h, 'PortHandles' );
                rconn( 2 ) = ph.RConn;
                add_line( modelName, outport( 2 ), ph.Inport, 'autorouting', 'on' )
            end
        end
    end

    if k == 1
        src = 'simrfV2util1/Configuration';
        p = get_param( src, 'Position' );
        pos = obj.newPos( p, x, y - dy + ( inOrOutputIQ * 0.6 - inputIQ ) * dy / 2 );
        h = add_block( src, sprintf( '%s/Configuration%d', modelName, 1 ),  ...
            'Position', pos );
        set_param( h,  ...
            'AutoFreq', 'on',  ...
            'NormalizeCarrierPower', 'on',  ...
            'StepSize', [ '(1/', sprintf( '%.15g', obj.SignalBandwidth ), ')/8' ],  ...
            'StepSize_unit', 's',  ...
            'AddNoise', 'on',  ...
            'Orientation', 'left' )
        phConfig1 = get_param( h, 'PortHandles' );
        add_line( modelName, rconn( 1 ), phConfig1.LConn, 'autorouting', 'on' )


        if numConfigurations == 2
            pos = obj.newPos( p, x, y + dy + dy * ( 0.6 + 1 ) / 2 );
            h = add_block( src, sprintf( '%s/Configuration%d', modelName, 2 ),  ...
                'Position', pos );
            set_param( h,  ...
                'AutoFreq', 'on',  ...
                'NormalizeCarrierPower', 'on',  ...
                'StepSize', [ '(1/', sprintf( '%.15g', obj.SignalBandwidth ), ')/8' ],  ...
                'StepSize_unit', 's',  ...
                'AddNoise', 'on',  ...
                'Orientation', 'left' )
            phConfig2 = get_param( h, 'PortHandles' );
            add_line( modelName, rconn( 2 ), phConfig2.LConn, 'autorouting', 'on' )
        end
    else
        pos = get_param( sprintf( '%s/Configuration1', modelName ), 'Position' );
    end
    x = pos( 3 ) + dx;

    if k == 1 || ( options.Rx > 1 )
        if ~RxAnt
            src = 'simrfV2sources1/Noise';
            p = [ 0, 0, 50, 50 ];
            pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - inputIQ ) * dy / 2 );
            h = add_block( src, sprintf( '%s/Thermal Noise%d', modelName, kNoise ), 'Position', pos );
            kNoise = kNoise + 1;
            set_param( h,  ...
                'InternalGrounding', 'off',  ...
                'Orientation', 'left',  ...
                'SimulinkInputSignalType', 'Ideal voltage',  ...
                'NoiseType', 'White',  ...
                'NoisePSD', '4*rf.physconst(''Boltzmann'')*290*50' );
            set_param( h, 'Position', pos );

            ph = get_param( h, 'PortHandles' );
            add_line( modelName, rconn( 1 ), ph.RConn, 'autorouting', 'on' )
            newRConn = ph.LConn;
            if inputIQ
                pos = obj.newPos( p, x, y + dy * ( 0.6 + 1 ) / 2 );
                h = add_block( src, sprintf( '%s/Thermal Noise%d', modelName, kNoise ), 'Position', pos );
                kNoise = kNoise + 1;
                set_param( h,  ...
                    'InternalGrounding', 'off',  ...
                    'Orientation', 'left',  ...
                    'SimulinkInputSignalType', 'Ideal voltage',  ...
                    'NoiseType', 'White',  ...
                    'NoisePSD', '4*rf.physconst(''Boltzmann'')*290*50' );
                set_param( h, 'Position', pos );

                ph = get_param( h, 'PortHandles' );
                add_line( modelName, rconn( 2 ), ph.RConn, 'autorouting', 'on' )
                newRConn( 2 ) = ph.LConn;
            end
            rconn = newRConn;
            x = pos( 3 ) + dx;
        end
    end

    if num > 1 && ( options.Tx > 1 )
        if k == 1
            p = [ 0, 0, 70, 70 ];
            pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - inputIQ ) * dy / 2 );
            h = add_divider( num, modelName, 'WilkinsonDivider1', pos );
            phDivider = get_param( h, 'PortHandles' );
            add_line( modelName, rconn( 1 ), phDivider.LConn, 'autorouting', 'on' )
            if inputIQ
                pos = obj.newPos( p, x, y + dy * ( 0.6 + 1 ) / 2 );
                h = add_divider( num, modelName, 'WilkinsonDivider2', pos );
                phDivider2 = get_param( h, 'PortHandles' );
                add_line( modelName, rconn( 2 ), phDivider2.LConn, 'autorouting', 'on' )
            end
        end
        rconn = phDivider.RConn( k );
        if inputIQ
            rconn( 2 ) = phDivider2.RConn( k );
        end
        x = pos( 3 ) + 3 * dx;
    end


    writeMissingNportFiles( obj )
    freq = InputFreq;
    freqdelta = 0;
    if k == 1
        xchain = x;
    else
        x = xchain;
    end
    for i = 1:numel( obj.Elements )
        if isa( obj.Elements( i ), 'rfantenna' ) && i == 1
            if numel( obj.Elements ) > 1 && ~strcmpi( obj.Elements( i ).Type, 'TransmitReceive' )
                continue ;
            elseif RxAnt
                break ;
            end
        end
        elem = obj.Elements( i );
        [ x, rconn ] = rbBlocks( elem, modelName, x,  ...
            y + inOrOutputIQ * 0.6 * dy / 2,  ...
            dx, dy, rconn, freq, obj, i, freqdelta, freqIdx );
        freq = OutputFreqs( i );
    end

    if num > 1 && ( options.Rx > 1 )
        if k == 1
            x = x + 2 * dx;
            p = [ 0, 0, 70, 70 ];
            pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - outputIQ ) * dy / 2 );
            h = add_combiner( num, modelName, 'WilkinsonCombiner1', pos );
            phCombiner = get_param( h, 'PortHandles' );
            if outputIQ
                pos = obj.newPos( p, x + 70 + dx, y + dy * ( 0.6 + 1 ) / 2 );
                h = add_combiner( num, modelName, 'WilkinsonCombiner2', pos );
                phCombiner2 = get_param( h, 'PortHandles' );
            end
        end
        add_line( modelName, rconn( 1 ), phCombiner.LConn( k ), 'autorouting', 'on' )
        if outputIQ
            add_line( modelName, rconn( 2 ), phCombiner2.LConn( k ), 'autorouting', 'on' )
        end
        rconn = phCombiner.RConn;
        if outputIQ
            rconn( 2 ) = phCombiner2.RConn;
        end
        x = pos( 3 ) + dx;
    end

    if k == 1 || ( options.Tx > 1 )

        ant = zeros( 1, length( obj.Elements ), 'logical' );
        for i = 1:length( obj.Elements )
            ant( i ) = isa( obj.Elements( i ), 'rfantenna' );
        end
        if ~isempty( ant ) && any( ant )
            if strcmpi( obj.Elements( ant ).Type, 'TransmitReceive' )
                RxAnt = 1;
            end
        end
        if any( ant )
            if strcmpi( obj.Elements( ant ).Type, 'TransmitReceive' )
                RxAnt = 1;
                src = 'simrfV2util1/Configuration';
                p = get_param( src, 'Position' );
                pos = obj.newPos( p, x, y - dy + ( inOrOutputIQ * 0.6 - inputIQ ) * dy / 2 );
                if k > 1
                    pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - inputIQ ) * dy / 2 );
                    y = y + dy;
                end
                h = add_block( src, [ modelName, '/Configuration' ], 'Position', pos, 'MakeNameUnique', 'on' );
                set( h,  ...
                    'AutoFreq', 'on',  ...
                    'NormalizeCarrierPower', 'on',  ...
                    'StepSize', [ '(1/', sprintf( '%.15g', obj.SignalBandwidth ), ')/8' ],  ...
                    'StepSize_unit', 's',  ...
                    'AddNoise', 'on',  ...
                    'Orientation', 'right' )
                ph = get( h, 'PortHandles' );
                add_line( modelName, rconn( 1 ), ph.LConn, 'autorouting', 'on' )
                if all( OutputFreqs( find( ant ):end  ) == 0 )
                    pos = obj.newPos( p, x, y + dy + dy * ( 0.6 + 1 ) / 2 );
                    h = add_block( src, [ modelName, '/Configuration' ],  ...
                        'Position', pos, 'MakeNameUnique', 'on' );
                    set( h,  ...
                        'AutoFreq', 'on',  ...
                        'NormalizeCarrierPower', 'on',  ...
                        'StepSize', [ '(1/', sprintf( '%.15g', obj.SignalBandwidth ), ')/8' ],  ...
                        'StepSize_unit', 's',  ...
                        'AddNoise', 'on',  ...
                        'Orientation', 'right' )
                    ph = get( h, 'PortHandles' );
                    add_line( modelName, rconn( 2 ), ph.LConn, 'autorouting', 'on' )
                end
            end
        end
        if ~any( ant ) || RxAnt
            src = 'simrfV2util1/Outport';
            p = get_param( src, 'Position' );
            pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - outputIQ ) * dy / 2 );
            h = add_block( src, sprintf( '%s/Outport%d', modelName, kOut ),  ...
                'Position', pos );
            kOut = kOut + 1;
            [ freq, ~, freq_prefix ] = obj.engunitsGLimited( abs( OutputFreqs( :, end  ) ) );
            set_param( h,  ...
                'SensorType', 'Power',  ...
                'CarrierFreq', sprintf( '%.15g', freq ),  ...
                'CarrierFreq_unit', [ freq_prefix, 'Hz' ],  ...
                'ZL', '50' );
            phOut = get_param( h, 'PortHandles' );
            add_line( modelName, rconn( 1 ), phOut.LConn, 'autorouting', 'off' )
            outport( 1 ) = phOut.Outport;
            if outputIQ
                pos = obj.newPos( p, x, y + dy * ( 0.6 + 1 ) / 2 );
                h = add_block( src, sprintf( '%s/Outport%d', modelName, kOut ),  ...
                    'Position', pos );
                kOut = kOut + 1;
                set_param( h,  ...
                    'SensorType', 'Power',  ...
                    'CarrierFreq', sprintf( '%.15g', freq ),  ...
                    'CarrierFreq_unit', [ freq_prefix, 'Hz' ],  ...
                    'ZL', '50' );
                phOut2 = get_param( h, 'PortHandles' );
                add_line( modelName, rconn( 2 ), phOut2.LConn, 'autorouting', 'off' )
                outport( 2 ) = phOut2.Outport;
            end
            x = pos( 3 ) + dx;
        else
            outport( 1 ) = rconn( 1 );
            if outputIQ
                outport( 2 ) = rconn( 2 );
            end
        end
        if any( ant ) && ~RxAnt
            src = 'rfBudgetAnalyzer_lib/EIRPCalculation';
            p = get_param( src, 'Position' );
            pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - outputIQ ) * dy / 2 );
            h = add_block( src, sprintf( '%s/EIRP Calculation%d', modelName, kAnt ), 'Position', pos );
            kAnt = kAnt + 1;
            ph = get( h, 'PortHandles' );
            add_line( modelName, outport( 1 ), ph.Inport, 'autorouting', 'on' )
            outport( 1 ) = ph.Outport;
            if outputIQ
                pos = obj.newPos( p, x, y + dy * ( 0.6 + 1 ) / 2 );
                h = add_block( src, sprintf( '%s/EIRP Calculation%d', modelName, kAnt ), 'Position', pos );
                kAnt = kAnt + 1;
                ph = get( h, 'PortHandles' );
                add_line( modelName, outport( 2 ), ph.Inport, 'autorouting', 'on' )
                outport( 2 ) = ph.Outport;
            end
            x = pos( 3 ) + dx;
        end
        src = 'simulink/Sinks/Out1';
        p = get_param( src, 'Position' );
        pos = obj.newPos( p, x, y + ( inOrOutputIQ * 0.6 - outputIQ ) * dy / 2 );
        h = add_block( src, sprintf( '%s/Out%d', modelName, kOut2 ), 'Position', pos );
        kOut2 = kOut2 + 1;
        ph = get_param( h, 'PortHandles' );
        add_line( modelName, outport( 1 ), ph.Inport, 'autorouting', 'on' )
        if outputIQ
            pos = obj.newPos( p, x, y + dy * ( 0.6 + 1 ) / 2 );
            h = add_block( src, sprintf( '%s/Out%d', modelName, kOut2 ), 'Position', pos );
            kOut2 = kOut2 + 1;
            ph = get_param( h, 'PortHandles' );
            add_line( modelName, outport( 2 ), ph.Inport, 'autorouting', 'on' )
        end
    end

    extra = 0;
    if ( inputIQ && ( options.Rx > 1 ) ) || ( outputIQ && ( options.Tx > 1 ) ) || any( OutputFreqs( 1:end  - 1 ) == 0 )
        extra = dy;
    end
    y = y + dy + extra + ( k == 1 ) * ( numConfigurations == 2 ) * ( options.Rx > 1 ) * dy;
end

if nargout == 2
    varargout{ 1 } = modelName;
    varargout{ 2 } = modelHandle;
elseif nargout == 1
    varargout{ 1 } = modelName;
else
    open_system( modelName )
end
end

function h = add_combiner( num, modelName, name, pos )

sparTerm =  - 1i / sqrt( num );
phaseSummer = zeros( num + 1, num + 1 );
phaseSummer( num + 1, 1:num ) = sparTerm;
phaseSummer( 1:num, num + 1 ) = sparTerm;
src = 'simrfV2elements/S-parameters';
h = add_block( src, sprintf( '%s/SumPhases', modelName ),  ...
    'DataSource', 'Network-parameters',  ...
    'Paramtype', 'S-parameters',  ...
    'Sparam', mat2str( phaseSummer ),  ...
    'SparamRepresentation', 'Frequency domain' );
Simulink.BlockDiagram.createSubsystem( h, 'Name', name )
blk = sprintf( '%s/%s', modelName, name );
for idx = 1:num
    set_param( sprintf( '%s/%d+', blk, idx ), 'Side', 'left' )
end
set_param( sprintf( '%s/%d+', blk, num + 1 ), 'Side', 'right' )
h = get_param( blk, 'Handle' );
set_param( h,  ...
    'Selected', 'off',  ...
    'Position', pos )
end

function h = add_divider( num, modelName, name, pos )

sparTerm =  - 1i / sqrt( num );
phaseSummer = zeros( num + 1, num + 1 );
phaseSummer( num + 1, 1:num ) = sparTerm;
phaseSummer( 1:num, num + 1 ) = sparTerm;
src = 'simrfV2elements/S-parameters';
h = add_block( src, sprintf( '%s/SumPhases', modelName ),  ...
    'DataSource', 'Network-parameters',  ...
    'Paramtype', 'S-parameters',  ...
    'Sparam', mat2str( phaseSummer ),  ...
    'SparamRepresentation', 'Frequency domain' );
Simulink.BlockDiagram.createSubsystem( h, 'Name', name )
blk = sprintf( '%s/%s', modelName, name );
for idx = 1:num
    set_param( sprintf( '%s/%d+', blk, idx ), 'Side', 'right' )
end
set_param( sprintf( '%s/%d+', blk, num + 1 ), 'Side', 'left' )
h = get_param( blk, 'Handle' );
set_param( h,  ...
    'Selected', 'off',  ...
    'Position', pos )
end
