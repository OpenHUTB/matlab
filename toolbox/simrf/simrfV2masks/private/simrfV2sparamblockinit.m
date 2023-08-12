function simrfV2sparamblockinit( block, varargin )






MaskWSValues = simrfV2getblockmaskwsvalues( block );
if isfield( MaskWSValues, 'CacheLevel' )
levels = MaskWSValues.CacheLevel;
else 
levels = 0;
end 
cacheData = simrfV2_getcachedata( block, levels, false );











subBlkExt = '';


if nargin == 2
RepBlk = varargin{ 1 };
numPortsStr = int2str( cacheData.NumPorts );


isCorrNoiseBlk = strcmpi( get_param( [ block, '/', RepBlk ], 'BlockType' ),  ...
'SubSystem' );
if strcmpi( get_param( block, 'AddNoise' ), 'off' )


if isCorrNoiseBlk
needNoise = false;
replaceCorrBlk( block, RepBlk, needNoise )
end 
else 



[ ~, ~, simWithNoise, envTempK ] =  ...
simrfV2_find_solverparams( bdroot( block ), block, 1 );
if simWithNoise == true



auxData = get_param( [ block, '/AuxData' ], 'UserData' );
if ispassive_init( auxData.Spars.Parameters )
RF_Const = simrfV2_constants(  );
KT = 4 * envTempK * value( RF_Const.Boltz, 'J/K' );

[ corrMatStr, freqs, isPassCorrNoise ] =  ...
simrfV2corrnoise( cacheData, auxData, KT, block );
if isPassCorrNoise

if ~isCorrNoiseBlk
needNoise = true;
replaceCorrBlk( block, RepBlk, needNoise )
end 

set_param( [ block, '/', RepBlk, '/CorrNoise', numPortsStr ],  ...
'freqs', simrfV2vector2str( freqs ),  ...
'covariance', corrMatStr )
subBlkExt = [ '/', RepBlk, '_noise' ];
else 
if isCorrNoiseBlk
needNoise = false;
replaceCorrBlk( block, RepBlk, needNoise )
end 
warning( message(  ...
'simrf:simrfV2errors:CovarianceNotPassive' ) )
end 
else 


if isCorrNoiseBlk
needNoise = false;
replaceCorrBlk( block, RepBlk, needNoise )
end 
switch get_param( block, 'DataSource' )
case 'Rational model'
warning( message(  ...
'simrf:simrfV2errors:RatModelNotPassive', block ) )
case 'Data file'
warning( message(  ...
'simrf:simrfV2errors:DataNotPassive',  ...
cacheData.filename, block ) )
otherwise 
warning( message(  ...
'simrf:simrfV2errors:DataNotPassiveNoFile', block ) )
end 
end 
else 

if isCorrNoiseBlk
needNoise = false;
replaceCorrBlk( block, RepBlk, needNoise )
end 
end 
end 
end 

if all( cellfun( 'isempty', cacheData.RationalModel.C ) )
sboxparam = [ cacheData.RationalModel.DCell( : ); ...
cacheData.RationalModel.Z0Cell( : ) ]';
fmtStr = '%s/d%dport%s';
elseif cacheData.NumPorts <= 8
sboxparam = [ cacheData.RationalModel.ACell( : ); ...
cacheData.RationalModel.CCell( : ); ...
cacheData.RationalModel.DCell( : ); ...
cacheData.RationalModel.Z0Cell( : ); ...
'FITOPT';int2str( cacheData.FitOpt ) ];
fmtStr = '%s/s%dport%s';
else 
Pterms = cellfun( @( x )str2num( x ), cacheData.RationalModel.ACell( 2, : ),  ...
'UniformOutput', false );%#ok<*ST2NM>
Pvec = [ Pterms{ : } ];
numPterms = cellfun( 'size', Pterms, 2 );
termsIdx = [ 0, cumsum( numPterms / 2 ) ];
Rterms = cellfun( @( x )str2num( x ), cacheData.RationalModel.CCell( 2, : ),  ...
'UniformOutput', false );
Rvec = [ Rterms{ : } ];
sboxparam = [ cacheData.RationalModel.Z0Cell( : ); ...
'P1dr';mat2str( Pvec( :, 1:2:end  ), 16 ); ...
'P1di';mat2str( Pvec( :, 2:2:end  ), 16 ); ...
'R1dr';mat2str( Rvec( :, 1:2:end  ), 16 ); ...
'R1di';mat2str( Rvec( :, 2:2:end  ), 16 ); ...
cacheData.RationalModel.DCell( : ); ...
'termsIdx';mat2str( termsIdx ); ...
'FITOPT';int2str( cacheData.FitOpt ) ];
fmtStr = '%s/s%dport%s';
end 


if isfield( cacheData, 'ConnectUnderAmplifier' ) &&  ...
cacheData.ConnectUnderAmplifier
actblock = block;
else 
actblock = sprintf( fmtStr, block, cacheData.NumPorts, subBlkExt );
end 
set_param( actblock, sboxparam{ : } )

end 


function replaceCorrBlk( block, subBlk, needNoise )

if needNoise
load_system( 'simrfV2private' )
repBlk = [ 'simrfV2private/', subBlk, 'Noise' ];
else 
load_system( 'simrfV2_lib' )
if regexp( subBlk, '^s[1-8]port$' )
repBlk = sprintf( 'simrfV2_lib/Sparameters/S%sPORT_RF', subBlk( 2 ) );
else 
repBlk = sprintf( 'simrfV2_lib/Sparameters/D%sPORT_RF', subBlk( 2 ) );
end 
end 

replace_block( block, 'FollowLinks', 'on', 'Name', subBlk, repBlk, 'noprompt' )
end 

function ispass = ispassive_init( spars )

s_idx = 1;
ispass = true;
while ispass && s_idx <= size( spars, 3 )
ispass = ~( norm( spars( :, :, s_idx ), 2 ) > 1 + 10 * eps );
s_idx = s_idx + 1;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp9IGU3f.p.
% Please follow local copyright laws when handling this file.

