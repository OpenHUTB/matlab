function update_axes_label( axes )






labelOff = [ 15, 5 ];

axesH = axes.handle;
labelH = axes.labelH;
labelPos = axes.labelPos;
xyoff = fig_2_ax_ext( labelOff, axesH );

xlim = get( axesH, 'XLim' );
ylim = get( axesH, 'YLim' );

switch ( labelPos )
case 'BR'
xpos = xlim( 2 ) - xyoff( 1 );
ypos = ylim( 1 ) + xyoff( 2 );
labelH.VerticalAlignment = 'bottom';
case 'BL'
xpos = xlim( 1 ) + xyoff( 1 );
ypos = ylim( 1 ) + xyoff( 2 );
labelH.VerticalAlignment = 'bottom';
case 'TR'
xpos = xlim( 2 ) - xyoff( 1 );
ypos = ylim( 2 ) - xyoff( 2 );
labelH.VerticalAlignment = 'top';
case 'TL'
xpos = xlim( 1 ) + xyoff( 1 );
ypos = ylim( 2 ) - xyoff( 2 );
labelH.VerticalAlignment = 'top';
end 

set( labelH, 'Position', [ xpos, ypos, 0 ] );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZWCWnE.p.
% Please follow local copyright laws when handling this file.

