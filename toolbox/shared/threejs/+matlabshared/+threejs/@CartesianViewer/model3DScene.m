function ID = model3DScene( viewer, model, NameValueArgs )



R36
viewer( 1, 1 )matlabshared.threejs.CartesianViewer
model globe.internal.Geographic3DModel
NameValueArgs.ShowEdges( 1, 1 )logical = true
NameValueArgs.EnableTexture( 1, 1 )logical = false
NameValueArgs.ID = viewer.Controller.getID
NameValueArgs.Opacity( 1, 1 )double = 0.1
NameValueArgs.EnableLighting( 1, 1 )logical = false
NameValueArgs.Scale( 1, 1 )double = 1
NameValueArgs.Persistent( 1, 1 )logical = false
end 
ID = NameValueArgs.ID;
tName = tempname;
filename = strcat( tName, '.glb' );
writer = globe.internal.GLBFileWriter( filename, model.Model, 'YUpCoordinate', false, 'EnableLighting', false );
write( writer );
readerFcn = 'gltfScene';


connectorFileName = viewer.getResourceURL( filename, 'myModel' );
message = struct(  ...
'Filename', connectorFileName,  ...
'Opacity', NameValueArgs.Opacity,  ...
'EnableTexture', NameValueArgs.EnableTexture,  ...
'ShowEdges', NameValueArgs.ShowEdges,  ...
'EnableLighting', NameValueArgs.EnableLighting,  ...
'Scale', NameValueArgs.Scale,  ...
'Persistent', NameValueArgs.Persistent,  ...
'ID', NameValueArgs.ID );
viewer.Figure.Visible = true;
viewer.request( readerFcn, message );
try 
delete( filename );
catch 

end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpmxDNP1.p.
% Please follow local copyright laws when handling this file.

