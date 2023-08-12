function [ replace_complete, delete_complete ] = simrfV2repblk( this, block )











delete_complete = false;
replace_complete = false;
RepBlk = [ block, '/', this.RepBlk ];
DstBlk = [ block, '/', this.DstBlk ];
if ~isfield( this, 'Param' ) || isempty( this.Param )
Param = {  };
else 
Param = this.Param;
end 



tempDstBlk = find_system( block, 'LookUnderMasks', 'all', 'FollowLinks',  ...
'on', 'SearchDepth', 1, 'Name', this.DstBlk, 'Parent', block );
if ~isempty( tempDstBlk ) &&  ...
~( isfield( this, 'ReplaceIfDstBlkExist' ) &&  ...
this.ReplaceIfDstBlkExist )
if ~isempty( Param ) &&  ...
~( isfield( this, 'NoUpdateOnDstBlk' ) && this.NoUpdateOnDstBlk )
set_param( DstBlk, Param{ : } );
end 
return 
end 







tempRepBlk = find_system( block, 'LookUnderMasks', 'all', 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'Name', this.RepBlk, 'Parent', block );
if ~isempty( tempRepBlk )


phRepBlk = get_param( RepBlk, 'PortHandles' );

simrfV2deletelines( get( phRepBlk.LConn, 'Line' ) );

simrfV2deletelines( get( phRepBlk.RConn, 'Line' ) );



newPos = get_param( RepBlk, 'Position' );
delete_block( RepBlk );
delete_complete = true;
else 
newPos = [ 80, 67, 145, 123 ];
end 


if isfield( this, 'SrcLib' ) && isfield( this, 'DstBlk' ) &&  ...
~isempty( this.SrcLib ) && ~isempty( this.DstBlk )
load_system( this.SrcLib );
add_block( this.SrcBlk, DstBlk, 'Position', newPos, Param{ : } );
replace_complete = true;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDJXQW6.p.
% Please follow local copyright laws when handling this file.

