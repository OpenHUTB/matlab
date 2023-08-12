function busInfo = slbus_get_struct( model, blks, term )





















busInfo = [  ];
bh = [  ];%#ok

ok = ( nargin == 2 || nargin == 3 );
if ~ok
DAStudio.error( 'Simulink:utility:invalidNumInputs' );
end 

if nargin == 2
term = true;
end 

if ( ischar( blks ) || isstring( blks ) )

blkHandles = get_param( blks, 'handle' );
elseif iscell( blks )

for idx = 1:length( blks )
blkHandles( idx ) = get_param( blks{ idx }, 'handle' );%#ok
end 
elseif ishandle( blks )
blkHandles = blks;
else 
DAStudio.error( 'Simulink:utility:slUtilityGetStructInvalidArgument' );
end 



[ isOk, blk ] = check_for_block_type_l( model, blkHandles );
if ~isOk
blkName = getfullname( blk );
DAStudio.error( 'Simulink:utility:slUtilityGetStructUnsupportedBlock', blkName );
end 


ports = [  ];


for idx = 1:length( blkHandles )
bType = get_param( blkHandles( idx ), 'BlockType' );
bpHandles = get_param( blkHandles( idx ), 'porthandles' );

if strcmpi( bType, 'Inport' )
ph = bpHandles.Outport;
elseif strcmpi( bType, 'Outport' )
ph = bpHandles.Inport;
elseif strcmpi( bType, 'BusCreator' )
ph = bpHandles.Outport;
end 

set_param( ph, 'CacheCompiledBusStruct', 'on' );
ports( end  + 1 ) = ph;%#ok
end 

feval( model, [  ], [  ], [  ], 'compileForSizes' );

for idx = 1:length( blkHandles )
busInfo( idx ).block = blkHandles( idx );%#ok
busInfo( idx ).bus = get_param( ports( idx ), 'CompiledBusStruct' );%#ok
busInfo( idx ).port = ports( idx );%#ok
end 

if term
feval( model, [  ], [  ], [  ], 'term' );
end 








function [ isOk, blk ] = check_for_block_type_l( model, blks )

isOk = true;
blk = '';

for idx = 1:length( blks )
blk = blks( idx );
blkType = get_param( blk, 'BlockType' );

if strcmpi( blkType, 'Inport' )
parent = get_param( blk, 'parent' );
isBEP = get_param( blk, 'IsBusElementPort' );


if strcmp( parent, model )
isOk = strcmp( isBEP, 'on' );
return ;
end 
elseif ~( strcmpi( blkType, 'Outport' ) || strcmpi( blkType, 'BusCreator' ) )
isOk = false;
return ;
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp37yxj6.p.
% Please follow local copyright laws when handling this file.

