function [ x, y ] = getTickLabelRowCoordinates( ax )

arguments
    ax( 1, 1 )matlab.graphics.axis.Axes
end
textprimitives = ax.XAxis.IntervalTickLabelChildren.Children;
lineprimitive = ax.XAxis.IntervalLineChild;

numrows = numel( textprimitives );
x = repelem( ruler2num( ax.XLim( 2 ), ax.XAxis ) + .5, numrows )';

y = nan( numrows, 1 );
ind = 1;
for i = 1:numel( textprimitives )
    y_world = mean( lineprimitive.VertexData( 2, [ ind, ind + 1 ] ) );
    pt = matlab.graphics.internal.transformWorldToData(  ...
        ax.DataSpace, eye( 4 ), [ x( i );y_world;0 ] );
    y( i ) = pt( 2 );
    numtexts = numel( textprimitives( i ).String );
    ind = ind + ( 2 * numtexts - 1 ) * 8;
end

end
