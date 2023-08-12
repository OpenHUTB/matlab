function UD = update_channel_select( UD )







persistent LastChannelSelected

if isempty( LastChannelSelected )
LastChannelSelected = 0;
end 

chIdx = UD.current.channel;

UD = remove_all_unneeded_points( UD );

if chIdx == 0 || in_iced_state_l( UD )

menuHandles = get( UD.menus.figmenu.SignalMenu, 'Children' );
menuHandles( menuHandles == UD.menus.figmenu.SignalMenuNew ) = [  ];
menuHandles( menuHandles == UD.menus.figmenu.SignalMenuShow ) = [  ];
menuHandles( menuHandles == UD.menus.figmenu.SignalMenuOutput ) = [  ];
menuHandles = [ menuHandles( : )', UD.menus.figmenu.channelEnabled ];
set( menuHandles, 'Enable', 'off' );
set( [ UD.toolbar.cut, UD.toolbar.copy ], 'Enable', 'off' );

figbgcolor = get( UD.dialog, 'Color' );

UD = update_legend_line( UD, 'off', 0 );

set( UD.hgCtrls.chDispProp.labelEdit,  ...
'String', '',  ...
'Enable', 'off',  ...
'BackgroundColor', figbgcolor );

set( UD.hgCtrls.chDispProp.indexPopup,  ...
'String', ' ',  ...
'Value', 1,  ...
'Enable', 'off',  ...
'BackgroundColor', figbgcolor );
set( [ UD.hgCtrls.chDispProp.indexLabel, UD.hgCtrls.chDispProp.labelLabel ],  ...
'Enable', 'off' );


if ( LastChannelSelected <= UD.numChannels ) && LastChannelSelected > 0 &&  ...
~isempty( UD.channels( LastChannelSelected ).lineH ) &&  ...
ishghandle( UD.channels( LastChannelSelected ).lineH, 'line' )
set( UD.channels( LastChannelSelected ).lineH, 'Marker', 'none' );
end 
else 
if ~is_fastRestartIdle_l( UD )

menuHandles = get( UD.menus.figmenu.SignalMenu, 'Children' );
menuHandles( menuHandles == UD.menus.figmenu.SignalMenuShow ) = [  ];
menuHandles = [ menuHandles( : )', UD.menus.figmenu.channelEnabled ];
set( menuHandles, 'Enable', 'on' );
set( [ UD.toolbar.cut, UD.toolbar.copy ], 'Enable', 'on' );

set( UD.hgCtrls.chDispProp.labelEdit,  ...
'Enable', 'on',  ...
'BackgroundColor', 'w' );

set( [ UD.hgCtrls.chDispProp.indexLabel, UD.hgCtrls.chDispProp.labelLabel ],  ...
'Enable', 'on' );

set( UD.hgCtrls.chDispProp.indexPopup,  ...
'Enable', 'on',  ...
'BackgroundColor', 'w' );
else 

figbgcolor = get( UD.dialog, 'Color' );

menuHandles = get( UD.menus.figmenu.SignalMenu, 'Children' );
menuHandles( menuHandles == UD.menus.figmenu.SignalMenuShow ) = [  ];
menuHandles( menuHandles == UD.menus.figmenu.SignalMenuOutput ) = [  ];
menuHandles( menuHandles == UD.menus.figmenu.SignalMenuChanIndex ) = [  ];
menuHandles( menuHandles == UD.menus.figmenu.SignalMenuNew ) = [  ];
set( menuHandles, 'Enable', 'on' );

set( UD.hgCtrls.chDispProp.labelLabel, 'Enable', 'on' );
set( UD.hgCtrls.chDispProp.labelEdit,  ...
'Enable', 'on',  ...
'BackgroundColor', 'w' );

set( UD.hgCtrls.chDispProp.indexPopup,  ...
'String', ' ',  ...
'Value', 1,  ...
'Enable', 'off',  ...
'BackgroundColor', figbgcolor );

set( UD.hgCtrls.chDispProp.indexLabel, 'Enable', 'off' );
end 

lineH = UD.channels( chIdx ).lineH;


set( lineH, 'Marker', 'diamond', 'MarkerSize', 5 );



UD = update_legend_line( UD, 'on', chIdx );


set( UD.hgCtrls.chDispProp.labelEdit,  ...
'String', UD.channels( chIdx ).label );


set( UD.hgCtrls.chanListbox, 'Value', chIdx );


nums = 1:UD.numChannels;
set( UD.hgCtrls.chDispProp.indexPopup,  ...
'String', num2str( nums' ),  ...
'Value', chIdx );

if LastChannelSelected > 0 && ( LastChannelSelected <= UD.numChannels ) &&  ...
LastChannelSelected ~= chIdx &&  ...
~isempty( UD.channels( LastChannelSelected ).lineH ) &&  ...
ishghandle( UD.channels( LastChannelSelected ).lineH, 'line' )
set( UD.channels( LastChannelSelected ).lineH, 'Marker', 'none' );
end 


stepX = UD.channels( chIdx ).stepX;
stepY = UD.channels( chIdx ).stepY;

check_mark_matching_submenu( UD.menus.figmenu.AxesMenuYSnap, stepY );
check_mark_matching_submenu( UD.menus.figmenu.AxesMenuTSnap, stepX );
check_mark_matching_submenu( UD.menus.channelContext.SignalCntxtYSnap, stepY );
check_mark_matching_submenu( UD.menus.channelContext.SignalCntxtTSnap, stepX );
end 

update_selection_msg( UD )
if in_iced_state_l( UD )
LastChannelSelected = 0;
else 
LastChannelSelected = chIdx;
end 
sigbuilder_tabselector( 'touch', UD.hgCtrls.tabselect.axesH );
end 

function check_mark_matching_submenu( parentMenuH, value )



menusH = get( parentMenuH, 'Children' );
set( menusH, 'Checked', 'off' );

labels = get( menusH, 'Label' );
menuVals = str2double( labels );

matchingMenu = menusH( menuVals == value );
if ~isempty( matchingMenu )
set( matchingMenu, 'Checked', 'on' );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpWcchl9.p.
% Please follow local copyright laws when handling this file.

