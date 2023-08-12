function converted = replaceBasePath( files, origBase, newBase )







R36
files( :, 1 )cell
origBase( 1, : )char
newBase( 1, : )char
end 
converted = files;
subStart = numel( origBase ) + numel( filesep(  ) );
for i = find( startsWith( files, origBase ) )'
converted{ i } = fullfile( newBase, files{ i }( subStart:end  ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGPgFvv.p.
% Please follow local copyright laws when handling this file.

