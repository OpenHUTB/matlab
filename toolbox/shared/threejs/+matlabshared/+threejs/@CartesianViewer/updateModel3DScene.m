function updateModel3DScene( viewer, ID, NameValueArgs )

R36
viewer matlabshared.threejs.CartesianViewer
ID
NameValueArgs.Opacity
end 
message = struct(  ...
"ID", ID,  ...
"Opacity", NameValueArgs.Opacity );
viewer.request( 'updateGltfScene', message );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpOIl9d_.p.
% Please follow local copyright laws when handling this file.

