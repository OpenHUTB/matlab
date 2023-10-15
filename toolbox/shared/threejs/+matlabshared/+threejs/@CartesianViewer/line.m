function ID = line( viewer, positions, args )
arguments
    viewer( 1, 1 )matlabshared.threejs.CartesianViewer
    positions( :, 3 )double
    args.Color( :, 3 )double = [ 1, 1, 1 ]
    args.Width( 1, 1 )double = 0.002
    args.ID = viewer.Controller.getID
    args.Name{ mustBeTextScalar } = ''
    args.Description{ mustBeTextScalar } = ''
    args.DepthTest( 1, 1 )logical = false
    args.Animation = "none"
end
if ischar( args.ID ) || isstring( args.ID )
    args.ID = cellstr( args.ID );
elseif ~iscell( args.ID )
    args.ID = num2cell( args.ID );
end
if numel( args.ID ) ~= 1 && numel( args.ID ) ~= size( positions, 1 ) - 1
    error( message( "shared_threejs:viewer:IncorrectNumIDsForLine" ) );
end

positions = positions';
msg = struct(  ...
    'Position', positions( : ),  ...
    'Color', args.Color,  ...
    'ID', { args.ID },  ...
    'Width', args.Width,  ...
    'Name', args.Name,  ...
    'Description', args.Description,  ...
    'DepthTest', args.DepthTest,  ...
    'Animation', args.Animation );
viewer.request( 'line', msg );
ID = args.ID;
end
