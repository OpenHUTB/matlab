function UD = update_show_menu( UD )




parentMenuH = UD.menus.figmenu.SignalMenuShow;
submenus = get( parentMenuH, 'Children' );
delete( submenus );

if isfield( UD, 'disabledMenus' )

UD.disabledMenus = UD.disabledMenus.findobj;
end 

hiddenCount = 0;
for i = 1:length( UD.channels )
if ( UD.channels( i ).axesInd == 0 )
hiddenCount = hiddenCount + 1;
uimenu( 'Parent', parentMenuH,  ...
'Label', UD.channels( i ).label,  ...
'Callback', sprintf( 'sigbuilder(''show'',gcbf,[], %d);', i ) );
end 
end 

if ( hiddenCount == 0 )
set( parentMenuH, 'Enable', 'off' );
else 
set( parentMenuH, 'Enable', 'on' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp8mUZJo.p.
% Please follow local copyright laws when handling this file.

