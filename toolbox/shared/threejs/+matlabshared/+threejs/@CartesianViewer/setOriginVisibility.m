function setOriginVisibility( viewer, visibility )
arguments
    viewer( 1, 1 )matlabshared.threejs.CartesianViewer
    visibility( 1, 1 )logical
end
originMessage = struct( 'Visibility', visibility );
viewer.request( 'setOriginVisibility', originMessage );
end
