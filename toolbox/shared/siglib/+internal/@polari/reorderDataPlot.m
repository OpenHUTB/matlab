function reorderDataPlot( p, dir, datasetIdx )










if nargin < 3




hp = p.hFigure.CurrentObject;
if isempty( hp )
return 
end 


iThis = getappdata( hp, 'polariDatasetIndex' );
if isempty( iThis )
return 
end 

else 
iThis = datasetIdx;
end 



plot_glow( p, true, iThis );


Nall = getNumDatasets( p );
iOther = 1:Nall;
iOther( iThis ) = [  ];


zOrig = getDataPlotZ( p );
zOther = zOrig( iOther );
[ ~, iSort ] = sort( zOther );

if dir ==  - 1

iAll = [ iThis, iOther( iSort ) ];
else 

iAll = [ iOther( iSort ), iThis ];
end 


zMin = 0.1;
zMax = 0.2;
del = zMax - zMin;
zAll = zMin + del * ( 0:Nall - 1 )' / Nall;
zNew( iAll ) = zAll;
setDataPlotZ( p, zNew );


changeActiveDataset( p, iAll( end  ) );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIodPuq.p.
% Please follow local copyright laws when handling this file.

