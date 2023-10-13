function converted = replaceBasePath( files, origBase, newBase )

arguments
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


