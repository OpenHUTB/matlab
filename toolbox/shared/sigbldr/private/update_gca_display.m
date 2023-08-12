function update_gca_display( currentAxes, tabAxesH )




persistent BoldAxesH

sigbuilder_tabselector( 'touch', tabAxesH );

if ~isempty( BoldAxesH ) & currentAxes == BoldAxesH
return ;
end 

axesH = currentAxes;
set( axesH, 'FontWeight', 'bold' )

if ~isempty( BoldAxesH ) & ishghandle( BoldAxesH, 'axes' )
set( BoldAxesH, 'FontWeight', 'normal' );
end 

BoldAxesH = axesH;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpbHItqM.p.
% Please follow local copyright laws when handling this file.

