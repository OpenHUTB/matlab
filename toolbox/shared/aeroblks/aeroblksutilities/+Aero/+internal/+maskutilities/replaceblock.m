function replaceblock( blk, newblk, newblklibrary )








R36
blk
newblk( 1, 1 )string
newblklibrary( 1, 1 )string
end 

if matlab.lang.OnOffSwitchState( get_param( blk, "Mask" ) )




newblkNoSpace = sprintf( newblk ).erase( whitespacePattern );
FilterMaskTypeNoSpace = string( get_param( blk, 'MaskType' ) ).erase( whitespacePattern );
else 
FilterMaskTypeNoSpace = string( get_param( blk, "BlockType" ) );
newblkNoSpace = newblk;
end 






if FilterMaskTypeNoSpace == newblkNoSpace
return 
end 

origCurrBlk = gcb;
origCurrSys = gcs;
origCurrBlkName = get_param( origCurrBlk, 'Name' );
origBlockName = getfullname( blk );

pos = get_param( blk, 'Position' );
delete_block( blk );

libname = strtok( newblklibrary, '/' );


if ~strcmpi( libname, 'built-in' )
if ~bdIsLoaded( libname )
load_system( libname );
end 
end 

newCurrBlkHandle = add_block( newblklibrary + "/" + sprintf( newblk ), origBlockName, 'Position', pos );

if string( getfullname( newCurrBlkHandle ) ) == origCurrBlk
try 
newCurrSys = gcs;
set_param( 0, 'CurrentSystem', origCurrSys );
set_param( origCurrSys, 'CurrentBlock', origCurrBlkName );
catch e %#ok
set_param( 0, 'CurrentSystem', newCurrSys );
set_param( newCurrSys, 'CurrentBlock', get_param( newCurrBlkHandle, 'Name' ) );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLuQurS.p.
% Please follow local copyright laws when handling this file.

