function showBannerMessage( p, msg )
if p.ToolTips
hb = p.hBannerMessage;
if ~isempty( hb ) && isvalid( hb )
start( hb, msg );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplzj04L.p.
% Please follow local copyright laws when handling this file.

