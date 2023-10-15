function updateModel3DScene( viewer, ID, NameValueArgs )

arguments
    viewer matlabshared.threejs.CartesianViewer
    ID
    NameValueArgs.Opacity
end
message = struct(  ...
    "ID", ID,  ...
    "Opacity", NameValueArgs.Opacity );
viewer.request( 'updateGltfScene', message );
end
