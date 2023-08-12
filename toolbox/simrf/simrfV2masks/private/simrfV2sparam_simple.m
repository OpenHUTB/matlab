function simrfV2sparam_simple( newBlock, block, s_idx, isTimeDomainFit, gain )






origAuxData = get_param( [ block, '/AuxData' ], 'UserData' );
origCacheData = get_param( block, 'UserData' );
cacheData = origCacheData;
cacheData.NumPorts = 3;
cacheData.FitOpt = 3;

if ( s_idx == 1 )






alphay = [ 1, 0, 0;0, 0, 0;0, 0, 0 ];
alphax = [ 1, 0, 0;0, 0, 0;0, 0, 0 ];
beta = [ 0, 0, 1;1, 0, 0;0, 0, 0 ];
gamma = [ 1, 1, 1;1, 1, 1;1, 1, 1 ];
else 




if nargin > 4
alphay = [ 0, 0, 0;2, 2, 0;0, 1, 0 ];
alphax = [ 0, 0, 0;1, 2, 0;0, 2, 0 ];
beta = [ 0, 0, 0;0, 0, 0;0, 0, 0 ];
gamma = [ 1, 1, 1;1 / gain, 1, 1;1, 1, 1 ];

else 
alphay = [ 0, 0, 0;2, 2, 0;0, 1, 0 ];
alphax = [ 0, 0, 0;1, 2, 0;0, 2, 0 ];
beta = [ 0, 0, 0;1, 0, 0;0, 0, 0 ];
gamma = [ 1, 1, 1;0, 1, 1;1, 1, 1 ];
end 
end 
cacheData.Spars.Parameters =  ...
zeros( 3, 3, size( origAuxData.Spars.Parameters, 3 ) );
[ ayInd, axInd ] = find( alphax );
for aElemInd = 1:length( ayInd )
cacheData.Spars.Parameters( ayInd( aElemInd ), axInd( aElemInd ), : ) =  ...
origAuxData.Spars.Parameters( alphay( ayInd( aElemInd ),  ...
axInd( aElemInd ) ), alphax( ayInd( aElemInd ), axInd( aElemInd ) ), : ) *  ...
gamma( ayInd( aElemInd ), axInd( aElemInd ) );
end 
[ byInd, bxInd ] = find( beta );
for bElemInd = 1:length( byInd )
cacheData.Spars.Parameters( byInd( bElemInd ), bxInd( bElemInd ), : ) =  ...
cacheData.Spars.Parameters( byInd( bElemInd ), bxInd( bElemInd ), : ) +  ...
beta( byInd( bElemInd ), bxInd( bElemInd ) );
end 
if isTimeDomainFit
cacheData.RationalModel.D = zeros( 1, 9 );
for aElemInd = 1:length( ayInd )
ColumnInd = ayInd( aElemInd ) + ( axInd( aElemInd ) - 1 ) * 3;
ColumnOrigInd = alphay( ayInd( aElemInd ), axInd( aElemInd ) ) +  ...
( alphax( ayInd( aElemInd ), axInd( aElemInd ) ) - 1 ) * 2;
if iscell( origCacheData.RationalModel.D( ColumnOrigInd ) )
cacheData.RationalModel.D( ColumnInd ) =  ...
origCacheData.RationalModel.D{ ColumnOrigInd } *  ...
gamma( ColumnInd );
else 
cacheData.RationalModel.D( ColumnInd ) =  ...
origCacheData.RationalModel.D( ColumnOrigInd ) *  ...
gamma( ColumnInd );
end 
end 
for bElemInd = 1:length( byInd )
ColumnInd = byInd( bElemInd ) + ( bxInd( bElemInd ) - 1 ) * 3;
cacheData.RationalModel.D( ColumnInd ) =  ...
cacheData.RationalModel.D( ColumnInd ) +  ...
beta( byInd( bElemInd ), bxInd( bElemInd ) );
end 


Dmat = reshape( cacheData.RationalModel.D, 3, 3 );
cacheData.RationalModel.DCell = { 'D'; ...
simrfV2vector2str( reshape( Dmat.', 1, [  ] ) ) };
cacheData.RationalModel.Z0Cell =  ...
{ 'Z0';simrfV2vector2str( real( origAuxData.Spars.Impedance ) *  ...
[ 1, 1, 1 ] ) };
if any( ~cellfun( 'isempty', origCacheData.RationalModel.C ) )
cacheData.RationalModel.A = cell( 9, 1 );
cacheData.RationalModel.ACell = [  ];
cacheData.RationalModel.C = cell( 9, 1 );
cacheData.RationalModel.CCell = [  ];
for aElemInd = 1:length( ayInd )


ColumnInd = ayInd( aElemInd ) + ( axInd( aElemInd ) - 1 ) * 3;
ColumnOrigInd = alphay( ayInd( aElemInd ), axInd( aElemInd ) ) +  ...
( alphax( ayInd( aElemInd ), axInd( aElemInd ) ) - 1 ) * 2;
matPosOrigStr =  ...
[ num2str( alphay( ayInd( aElemInd ), axInd( aElemInd ) ) ) ...
, num2str( alphax( ayInd( aElemInd ), axInd( aElemInd ) ) ) ];
matPosStr = [ num2str( ayInd( aElemInd ) ) ...
, num2str( axInd( aElemInd ) ) ];

cacheData.RationalModel.A( ColumnInd ) =  ...
origCacheData.RationalModel.A( ColumnOrigInd );

Added_Acolumn = origCacheData.RationalModel.ACell( :,  ...
strcmpi( origCacheData.RationalModel.ACell( 1, : ),  ...
[ 'P', matPosOrigStr ] ) );
if ~isempty( Added_Acolumn )
Added_Acolumn{ 1, 1 } = [ 'P', matPosStr ];
cacheData.RationalModel.ACell =  ...
[ cacheData.RationalModel.ACell, Added_Acolumn ];
end 

cacheData.RationalModel.C( ColumnInd ) =  ...
{ origCacheData.RationalModel.C{ ColumnOrigInd } *  ...
gamma( ColumnInd ) };

Added_Ccolumn = origCacheData.RationalModel.CCell( :,  ...
strcmpi( origCacheData.RationalModel.CCell( 1, : ),  ...
[ 'R', matPosOrigStr ] ) );
if ~isempty( Added_Ccolumn )
Added_Cdata = reshape( str2num( Added_Ccolumn{ 2 } ), 2, [  ] );%#ok<ST2NM>
Added_Cdata = ( Added_Cdata( 1, : ) + 1j * Added_Cdata( 2, : ) ) *  ...
gamma( ColumnInd );
Added_Ccolumn{ 2 } = simrfV2vector2str(  ...
reshape( [ real( Added_Cdata );imag( Added_Cdata ) ], 1, [  ] ) );
Added_Ccolumn{ 1, 1 } = [ 'R', matPosStr ];
cacheData.RationalModel.CCell =  ...
[ cacheData.RationalModel.CCell, Added_Ccolumn ];
end 
end 
end 
else 
cacheData.Spars.Impedance = origAuxData.Spars.Impedance;
cacheData.Spars.Frequencies = origAuxData.Spars.Frequencies;
cacheData.Spars.OrigParamType = origAuxData.Spars.OrigParamType;
end 

cacheData.ConnectUnderAmplifier = true;

set_param( newBlock, 'UserData', cacheData );
if ~strcmpi( get_param( bdroot( block ), 'SimulationStatus' ), 'stopped' )
if isTimeDomainFit
simrfV2sparamblockinit( newBlock )
else 
simrfV2sparam_freq_domain_blockinit( newBlock, newBlock,  ...
simrfV2getblockmaskwsvalues( block ) );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpN5fYKn.p.
% Please follow local copyright laws when handling this file.

