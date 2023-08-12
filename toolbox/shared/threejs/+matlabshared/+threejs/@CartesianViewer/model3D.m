function ID = model3D( viewer, model, position, NameValueArgs )




R36
viewer matlabshared.threejs.CartesianViewer
model globe.internal.Geographic3DModel
position
NameValueArgs.Size = 0.01
NameValueArgs.Transparency = 0.5
NameValueArgs.Rotation = [ 0, 0, 0 ]
NameValueArgs.ID = viewer.Controller.getID
NameValueArgs.Animation = "none"
end 
ID = NameValueArgs.ID;
tName = tempname;
filename = strcat( tName, '.glb' );
writer = globe.internal.GLBFileWriter( filename, model.Model,  ...
'YUpCoordinate', model.YUpCoordinate,  ...
'EnableLighting', false,  ...
'VertexColors', model.VertexColors,  ...
'MetallicFactor', model.MetallicFactor,  ...
'RoughnessFactor', model.RoughnessFactor );
write( writer );
connectorFileName = viewer.getResourceURL( filename, 'myModel' );
viewer.request( 'gltfModel', struct(  ...
'File', connectorFileName,  ...
'Position', position,  ...
'Size', NameValueArgs.Size,  ...
'Transparency', NameValueArgs.Transparency,  ...
'ID', NameValueArgs.ID,  ...
'Rotation', NameValueArgs.Rotation,  ...
'Animation', NameValueArgs.Animation ) );
if ~viewer.Queue


try 
delete( filename );
catch 

end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUZV8EO.p.
% Please follow local copyright laws when handling this file.

