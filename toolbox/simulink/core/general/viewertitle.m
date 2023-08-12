function viewerTitle = viewertitle( viewer, fullpath )












names = [  ];





iorec = get_param( viewer, 'iosignals' );




nSets = length( iorec );




for i = 1:nSets
ioset = iorec{ i };
nSigs = length( ioset );




for j = 1:nSigs
name = '';






if isempty( ioset( j ).RelativePath )




h = ioset( j ).Handle;
if ( h ~=  - 1 )
line = get( h, 'line' );
if ( line ~=  - 1 )
name = get( line, 'name' );
end 
end 




if ~isempty( name )
if isempty( names )
names = name;
else 
names = [ names, ', ', name ];
end 
end 
end 
end 
end 




if fullpath
viewerName = getfullname( viewer );
else 
viewerName = get_param( viewer, 'name' );
end 

if isempty( names )
viewerTitle = [ 'Viewer: ', viewerName ];
else 
viewerTitle = [ 'Viewer: ', viewerName, ' (', names, ')' ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmprj8QNW.p.
% Please follow local copyright laws when handling this file.

