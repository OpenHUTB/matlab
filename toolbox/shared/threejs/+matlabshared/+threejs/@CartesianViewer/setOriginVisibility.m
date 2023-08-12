function setOriginVisibility( viewer, visibility )
R36
viewer( 1, 1 )matlabshared.threejs.CartesianViewer
visibility( 1, 1 )logical
end 
originMessage = struct( 'Visibility', visibility );
viewer.request( 'setOriginVisibility', originMessage );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp9T2oCt.p.
% Please follow local copyright laws when handling this file.

