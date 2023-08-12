function setTitle( p, titleStr, place )






hax = p.hAxes;
if isempty( hax ) || ~ishghandle( hax )
return 
end 

isNew = false;
if strcmpi( place, 'top' )
h = p.hTitleTop;
if isempty( h ) || ~ishghandle( h )
isNew = true;
h = local_createTitle( p, 'Top' );
p.hTitleTop = h;
va = 'bottom';
addlistener( h, 'String', 'PostSet',  ...
@( ~, ev )titleStringChanged( p, place ) );
end 
else 
h = p.hTitleBottom;
if isempty( h ) || ~ishghandle( h )
isNew = true;
h = local_createTitle( p, 'Bottom' );
p.hTitleBottom = h;
va = 'top';
addlistener( h, 'String', 'PostSet',  ...
@( ~, ev )titleStringChanged( p, place ) );
end 
end 
if isNew


set( h,  ...
'Color', p.pAngleTickLabelColor,  ...
'HorizontalAlignment', 'center',  ...
'VerticalAlignment', va );


updateTitleFont( p );
updateTitlePos( p, place );
end 


str = internal.polariCommon.xlatExtendedASCII( titleStr );




h.String = char( str );



end 

function h = local_createTitle( p, sel )



if strcmpi( sel, 'top' )
textInt = p.TitleTopTextInterpreter;
pname = 'TitleTopTextInterpreter';
else 
textInt = p.TitleBottomTextInterpreter;
pname = 'TitleBottomTextInterpreter';
end 

h = text( 'Parent', p.hAxes,  ...
'Interpreter', textInt,  ...
'Tag', sprintf( 'polariTitle%s%d', sel, p.pAxesIndex ) );

hc = uicontextmenu(  ...
'Parent', p.hFigure,  ...
'HandleVisibility', 'off' );


opts = { hc, 'Show Title',  ...
@( ~, ~ )delete_title( p, sel ) };
hs = internal.ContextMenus.createContext( opts );
hs.Checked = 'on';

internal.ContextMenus.createContextSubmenu( p, true, false, hc,  ...
'Interpreter', p.TitleInterpreterStrings, pname );


h.UIContextMenu = hc;

end 

function delete_title( p, sel )
switch lower( sel )
case 'top'
p.TitleTop = '';
case 'bottom'
p.TitleBottom = '';
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpM22mcQ.p.
% Please follow local copyright laws when handling this file.

