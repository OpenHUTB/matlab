function ID = marker( viewer, position, icon, args )
arguments
    viewer( 1, 1 )matlabshared.threejs.CartesianViewer
    position( :, 3 )double
    icon
    args.ValidateIcon = true
    args.ID = viewer.Controller.getID
    args.Name = ''
    args.Description = ''
    args.ShowStem = true
    args.StemBase = 0
    args.IconSize = [ 36, 36 ]
    args.IconAlignment = "center"
    args.Animation = 'none'
end
if ( ~iscell( position ) )
    position = num2cell( position, 2 );
end
if ( ~iscell( args.StemBase ) )
    args.StemBase = num2cell( args.StemBase );
end
if ( ~iscell( args.ShowStem ) )
    args.ShowStem = num2cell( args.ShowStem );
end
if ( ~iscell( args.ID ) )
    if ischar( args.ID ) || isstring( args.ID )
        args.ID = cellstr( args.ID );
    else
        args.ID = num2cell( args.ID );
    end
end
if ( ~iscell( icon ) )
    icon = cellstr( icon );
end

if args.ValidateIcon
    iconUrls = cell( numel( icon ), 1 );
    for h = 1:numel( icon )
        if ~isempty( which( icon{ h } ) )
            iconUrls{ h } = viewer.getResourceURL(  ...
                which( icon{ h } ), [ 'marker', num2str( args.ID{ h } ) ] );
        elseif ( exist( icon{ h }, 'file' ) == 2 )
            iconUrls{ h } = viewer.getResourceURL(  ...
                icon{ h }, [ 'marker', num2str( args.ID{ h } ) ] );
        else
            iconUrls{ h } = icon{ h };
        end
    end
else
    iconUrls = icon;
end
if ~iscell( args.Name )
    args.Name = cellstr( args.Name );
end
if ~iscell( args.Description )
    args.Description = cellstr( args.Description );
end
if ~iscell( args.IconSize )
    args.IconSize = { args.IconSize };
end
if ~iscell( args.IconAlignment )
    args.IconAlignment = cellstr( args.IconAlignment );
end
msg = struct(  ...
    'Position', { position },  ...
    'Icon', { iconUrls },  ...
    'Name', { args.Name },  ...
    'Description', { args.Description },  ...
    'ID', { args.ID },  ...
    'StemBase', { args.StemBase },  ...
    'IconSize', { args.IconSize },  ...
    'IconAlignment', { args.IconAlignment },  ...
    'Animation', args.Animation,  ...
    'ShowStem', { args.ShowStem } );
viewer.request( 'marker', msg );
ID = args.ID;
end
