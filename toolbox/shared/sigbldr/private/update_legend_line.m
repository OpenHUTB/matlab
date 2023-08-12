function [ UD ] = update_legend_line( UD, onoff, chIdx )








if nargin < 3
error( message( 'sigbldr_ui:update_legend_line:badNumOfInputArguments' ) )
end 

if nargin == 3
if ( chIdx == 0 )
set( UD.hgCtrls.chDispProp.legendLine, 'Visible', onoff );
else 
lineH = UD.channels( chIdx ).lineH;

if ~isempty( lineH )
props = { 'Color', 'LineStyle', 'LineWidth' };
vals = get( lineH, props );
set( UD.hgCtrls.chDispProp.legendLine, 'Visible', onoff, props, vals );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpcceWQc.p.
% Please follow local copyright laws when handling this file.

