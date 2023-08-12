function insertAxes( fig, value )





if isprop( fig, 'MOLToolstripAxesListener' )
fig.MOLToolstripAxesListener.Enabled = false;
end 

try 


layoutObj = findall( fig, 'type', 'tiledlayout', '-depth', 1 );

if ~isempty( layoutObj )


if value.row == layoutObj.GridSize( 1 ) &&  ...
value.column == layoutObj.GridSize( 2 )
return ;
end 
end 

allAxes = findall( fig, 'Type', 'axes' );

hasChildren = zeros( numel( allAxes ), 1 );
for i = 1:numel( allAxes )
hasChildren( i ) = ~isempty( get( allAxes( i ), 'Children' ) );
end 


allAxes = allAxes( hasChildren == 1 );

lastAxesPositions = get( allAxes, { 'Position' } );
localInsertAxes( fig, allAxes, value )


cmd.Name = [ 'add axes' ];
cmd.Function = @( fig, ~ )localInsertAxes( fig, allAxes, value );
cmd.InverseFunction = @( fig, ~ )localInverse( fig, allAxes, lastAxesPositions );
cmd.Varargin = { fig };
cmd.InverseVarargin = { fig };
uiundo( fig, 'function', cmd );
catch e

end 


if isprop( fig, 'MOLToolstripAxesListener' )
fig.MOLToolstripAxesListener.Enabled = true;
end 

end 

function localInverse( fig, lastAxes, lastAxesPositions )


tiledLayout = findall( fig, 'type', 'tiledlayout', '-depth', 1 );
set( lastAxes, 'Parent', [  ] );
delete( tiledLayout );

for k = 1:numel( lastAxes )
lastAxes( k ).Position = lastAxesPositions{ k };
end 
set( lastAxes, 'Parent', fig );
end 

function localInsertAxes( fig, allAxes, value )


colorbars = findobj( fig, 'type', 'colorbar' );
set( colorbars, 'Parent', [  ] );


set( allAxes, 'Parent', [  ] );


l = findobj( fig, 'type', 'legend' );
set( l, 'Parent', [  ] );


delete( findobj( fig, 'type', 'tiledlayout' ) );



if value.row == 1 && value.column == 1
t = tiledlayout( fig, 'flow' );
else 

t = tiledlayout( fig, value.row, value.column );
end 


set( allAxes, 'Parent', t );

lastTile = 1;


for i = 1:numel( allAxes )
ax = allAxes( i );
ax.Layout.Tile = i;


if ~isempty( ax.Legend )
set( ax.Legend, 'Parent', t );
end 

for j = 1:numel( colorbars )
cBar = colorbars( j );


if isequal( cBar.Axes, ax )
colorbar( ax );
end 
end 

lastTile = i;
end 

numTiles = value.row * value.column;

for i = lastTile:numTiles
nexttile( i );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpFUbeHD.p.
% Please follow local copyright laws when handling this file.

