function inspectorHelper( selObj )
fig = get( groot, 'CurrentFigure' );


plotedit( fig, 'on' );

if ~isempty( selObj )
inspect( selObj );
elseif ~isempty( fig.CurrentAxes )
inspect( fig.CurrentAxes );
else 
inspect( fig );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpHW6JYq.p.
% Please follow local copyright laws when handling this file.

