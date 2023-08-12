function updateCursorsContextMenu( p, hMenu, m )




delete( hMenu.Children );




cursorIndex = m.Index;
str1 = sprintf( 'CURSOR %d', cursorIndex );
if m.Floating
str3 = '';
else 
str3 = sprintf( 'INDEX %d', m.DataIndex );
end 


if getNumDatasets( p ) > 1
didx = getDataSetIndex( m );
str2 = sprintf( 'DATASET %d', didx );
headerOpts = { hMenu,  ...
[ '<html><b>', str1, '</b><br>' ...
, '<font size=3><i>', str2, '</i><br>' ...
, '<i>', str3, '</i></font></html>' ], '', 'Enable', 'off' };
else 
headerOpts = { hMenu,  ...
[ '<html><b>', str1, '</b><br>' ...
, '<font size=3><i>', str3, '</i></font></html>' ], '', 'Enable', 'off' };
end 
internal.ContextMenus.createContext( headerOpts );




N = getNumDatasets( p );
if N > 1

vals = cell( N, 1 );
for i = 1:N
vals{ i } = sprintf( 'Dataset %d', i );
end 
ID = m.ID;
m = findCursorAngleMarkerByID( p, ID );
make = true;
sep = true;
hm = internal.ContextMenus.createContextSubmenu( m, make, sep, hMenu,  ...
'Connect to...', vals, 'DataSetConnect' );




hParent = hm( 1 ).Parent;
hParent.Enable = internal.LogicalToOnOff( ~m.Floating );
end 

make = true;
sep = N <= 1;
internal.ContextMenus.createContextMenuChecked( p, make, sep, hMenu,  ...
'Interpolate', { m, 'Floating' } );
sep = false;
internal.ContextMenus.createContextMenuChecked( m, make, sep, hMenu,  ...
'Show Readout', 'Visible' );








internal.ContextMenus.createContext( { hMenu,  ...
'Remove Cursor',  ...
@( ~, ~ )m_removeCursors( p, cursorIndex ),  ...
'separator', 'on' } );

internal.ContextMenus.createContext( { hMenu, 'Remove All Cursors', @( ~, ~ )m_removeCursors( p ) } );
internal.ContextMenus.createContext( { hMenu, 'Export All Cursors', @( ~, ~ )m_exportCursors( p ) } );

 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...


internal.ContextMenus.createContext( { hMenu, 'Bring to Front',  ...
@( ~, ~ )m_reorderAngleMarker( p, m.ID,  + 1 ), 'separator', 'on' } );
internal.ContextMenus.createContext( { hMenu, 'Send to Back',  ...
@( ~, ~ )m_reorderAngleMarker( p, m.ID,  - 1 ) } );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQC7G03.p.
% Please follow local copyright laws when handling this file.

