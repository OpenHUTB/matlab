function files = getUnpackedResourcesFiles( model )




unpackedFolder = get_param( model, 'UnpackedLocation' );


files = dir( fullfile( unpackedFolder, '/simulink/resources' ) );
files = { files.name };

files( ismember( files, '.' ) ) = [  ];
files( ismember( files, '..' ) ) = [  ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgbhA2c.p.
% Please follow local copyright laws when handling this file.

