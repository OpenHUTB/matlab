function simrfV2sparam_freq_domain_blockinit(  ...
block, sub1BlkName, MaskWSValues )

[ envfreq, ~, simWithNoise, envTempK, ~, step ] =  ...
simrfV2_find_solverparams( bdroot( block ), block );

if ( isempty( envfreq ) || isempty( envTempK ) || isempty( step ) )
return 
end 

if strcmpi( block, sub1BlkName )

Udata = get_param( block, 'UserData' );
else 
Udata = get_param( [ block, '/AuxData' ], 'UserData' );
end 
resampled = rfdata.data;
resampled.Freq = Udata.Spars.Frequencies;
resampled.S_Parameters = Udata.Spars.Parameters;

impulse_length = 0;

if isfield( MaskWSValues, 'AutoImpulseLength' )
if MaskWSValues.AutoImpulseLength

impulse_length = 128 * step;
else 
impulse_length = simrfV2convert2baseunit(  ...
MaskWSValues.ImpulseLength, MaskWSValues.ImpulseLength_unit );
if impulse_length < 0
error( message( 'simrf:simrfV2errors:NegativeImpulseLength' ) );
end 
end 
end 





variance = std( Udata.Spars.Parameters, [  ], 3 );
if sum( variance( : ) ) < 1e-8
impulse_length = 0;
end 

if impulse_length == 0
new_freqs = envfreq;
else 

new_freqs = unique( [ 0;resampled.Freq ] );
end 
analyze( resampled, new_freqs );

resampled.Z0 = Udata.Spars.Impedance;

dc_idx = find( abs( envfreq ) < 1e-3 );
resampled.S_Parameters( :, :, dc_idx ) =  ...
real( resampled.S_Parameters( :, :, dc_idx ) );

if ( isfield( MaskWSValues, 'DataSource' ) )


if strcmpi( block, sub1BlkName )

DataSource = get_param( get_param( block, 'Parent' ), 'DataSource' );
else 
DataSource = get_param( block, 'DataSource' );
end 
allowMagModeling = any( strcmpi( DataSource, { 'Data file',  ...
'Network-parameters' } ) );
if ( allowMagModeling )
if ( ( ~isfield( Udata, 'Spars' ) ) ||  ...
( ~strcmpi( Udata.Spars.OrigParamType, 's' ) ) )
allowMagModeling = false;
end 
end 
MagModeling = ( allowMagModeling &&  ...
( ( isfield( MaskWSValues, 'MagModeling' ) ) &&  ...
( MaskWSValues.MagModeling ) ) );
else 
MagModeling = false;
end 

if MagModeling
s_row = simrfV2_sparams3d_to_1d( abs( resampled.S_Parameters ) );
else 
s_row = simrfV2_sparams3d_to_1d( resampled.S_Parameters );
end 
numPorts = size( resampled.S_Parameters, 1 );
if ( length( resampled.Z0 ) == numPorts )
zo_vec = resampled.Z0;
else 
zo_vec = ones( 1, numPorts ) * resampled.Z0( 1 );
end 

if strcmpi( get_param( block, 'Classname' ), 'sparam_element' )

isCorrNoiseBlk = strcmpi( get_param( sub1BlkName, 'BlockType' ), 'SubSystem' );
blkName = char( regexp( sub1BlkName, 'f[1-8]port$', 'match' ) );
if strcmpi( get_param( block, 'AddNoise' ), 'on' ) &&  ...
simWithNoise == true && ~isempty( blkName )
if ~isCorrNoiseBlk
needNoise = true;
replaceCorrBlk( blkName, sub1BlkName, needNoise )
end 
RF_Const = simrfV2_constants(  );
KT = 4 * envTempK * value( RF_Const.Boltz, 'J/K' );


[ corrMatStr, isPassRatSpars ] =  ...
simrfV2corrnoise_freq_domain( resampled.S_Parameters, KT, block );
subBlkExt = [ '/', blkName, '_noise' ];
corrNoise = [ sub1BlkName, '/CorrNoise', blkName( 2 ) ];
if ~isPassRatSpars


warning( message( 'simrf:simrfV2errors:DataNotPassiveNoFile',  ...
block ) );
set_param( corrNoise,  ...
'freqs', '0',  ...
'covariance', sprintf( 'zeros(%d)', numPorts ),  ...
'impulse_length', '0' );
elseif MagModeling

warning( message( 'simrf:simrfV2errors:MagSparamNotPassive',  ...
block ) );
set_param( corrNoise,  ...
'freqs', '0',  ...
'covariance', sprintf( 'zeros(%d)', numPorts ),  ...
'impulse_length', '0' );
else 
set_param( corrNoise,  ...
'freqs', simrfV2vector2str( resampled.Freq ),  ...
'covariance', corrMatStr,  ...
'impulse_length', simrfV2vector2str( 2 *  ...
( 0.5 - MagModeling ) * impulse_length ) );
end 
else 
if isCorrNoiseBlk
blkName = char( regexp( sub1BlkName, 'f[1-8]port$', 'match' ) );
needNoise = false;
replaceCorrBlk( blkName, sub1BlkName, needNoise )
end 
subBlkExt = '';
end 
else 
subBlkExt = '';
end 

load_system( 'simrfV2_lib' )
set_param( [ sub1BlkName, subBlkExt ],  ...
'ZO', simrfV2vector2str( zo_vec ), 'ZO_unit', 'Ohm',  ...
'freqs', simrfV2vector2str( resampled.Freq ), 'freqs_unit', 'Hz',  ...
'S', simrfV2vector2str( s_row ),  ...
'Tau', simrfV2vector2str( 2 * ( 0.5 - MagModeling ) *  ...
impulse_length ) );

end 


function replaceCorrBlk( blkName, sub1BlkName, needNoise )

if needNoise
load_system( 'simrfV2private' )
repBlk = [ 'simrfV2private/', blkName, 'Noise' ];
else 
load_system( 'simrfV2_lib' )
repBlk = sprintf( 'simrfV2_lib/Sparameters/F%sPORT_RF', blkName( 2 ) );
end 
replace_block( sub1BlkName, 'Name', blkName, repBlk, 'noprompt' )
end 


