function ID = legend( viewer, title, colors, values, args )
arguments
    viewer( 1, 1 )matlabshared.threejs.CartesianViewer
    title
    colors
    values
    args.ID = viewer.Controller.getID
    args.ParentGraphicID =  - 1
    args.InfoboxLegend = false
end
legendMessage = struct(  ...
    'LegendTitle', title,  ...
    'LegendColors', colors,  ...
    'LegendColorValues', values,  ...
    'ParentGraphicID', args.ParentGraphicID,  ...
    'ID', args.ID );
if args.InfoboxLegend
    requestFcn = 'infoboxLegend';
else
    requestFcn = 'colorLegend';
end
viewer.request( requestFcn, legendMessage );
ID = args.ID;
end
