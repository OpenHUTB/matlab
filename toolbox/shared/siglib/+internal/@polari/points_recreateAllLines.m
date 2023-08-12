function [ Zplane, hline, hglow ] = points_recreateAllLines( p, Nd )





delete( p.hDataLine );



Zmin = 0.1;
Zmax = 0.2;
del = Zmax - Zmin;
Zplane = Zmin + del * ( 0:Nd - 1 )' / Nd;

for datasetIndex = 1:Nd
ht_i = line(  ...
'Parent', p.hAxes,  ...
'Tag', sprintf( 'PolarData%d', p.pAxesIndex ),  ...
'HandleVisibility', 'on',  ...
'Visible', 'off' );
set( ht_i, 'uicontextmenu', p.UIContextMenu_Data );
setappdata( ht_i, 'polariDatasetIndex', datasetIndex );
setappdata( ht_i, 'polariZPlane', Zplane( datasetIndex ) );



b = hggetbehavior( ht_i, 'DataCursor' );
b.UpdateFcn = @( h, e )figureDataCursorUpdateFcn( p, e );
b = hggetbehavior( ht_i, 'Plotedit' );
b.Enable = false;

if datasetIndex == 1
hline = ht_i;
else 
hline = [ hline;ht_i ];%#ok<AGROW>
end 
end 
p.hDataLine = hline;



delete( p.hDataLineGlow );
hglow = line(  ...
'Parent', p.hAxes,  ...
'HandleVisibility', 'off',  ...
'Tag', sprintf( 'PolarData%d', p.pAxesIndex ),  ...
'Visible', 'off' );
p.hDataLineGlow = hglow;


b = hggetbehavior( hglow, 'DataCursor' );
b.Enable = false;
b = hggetbehavior( hglow, 'Plotedit' );
b.Enable = false;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLynoKR.p.
% Please follow local copyright laws when handling this file.

