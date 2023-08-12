function updateAngleLimCursorContextMenu( p, hMenu, m )



delete( hMenu.Children );

str1 = 'ANGLE LIMITS';
cursorID = m.ID;
if strcmpi( cursorID, 'a1' )
str2 = 'START ANGLE';
else 
str2 = 'END ANGLE';
end 
label = [ '<html><b>', str1, '</b><br>' ...
, '<font size=3><i>', str2, '</i></font></html>' ];

headerOpts = { hMenu, label, '', 'Enable', 'off' };
internal.ContextMenus.createContext( headerOpts );



make = true;
sep = true;
internal.ContextMenus.createContextMenuChecked( p, make, sep, hMenu,  ...
'Show Angle Limits', 'AngleLimVisible' );
internal.ContextMenus.createContext( { hMenu,  ...
'Reset to defaults', @( ~, ~ )m_resetAngleLim( p ) } );

 ...
 ...
 ...
 ...
 ...
 ...
 ...

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYmj9zI.p.
% Please follow local copyright laws when handling this file.

