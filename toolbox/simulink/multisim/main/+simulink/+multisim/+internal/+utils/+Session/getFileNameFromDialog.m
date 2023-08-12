function fullFileName = getFileNameFromDialog( ~, filter )


R36
~
filter( 1, 1 )string
end 

saveAsDialogTitle = getString( message( 'multisim:SetupGUI:SaveAsDialogTitle' ) );
[ fileName, pathName ] = uiputfile( filter, saveAsDialogTitle );

if ( fileName ~= 0 )
fullFileName = fullfile( pathName, fileName );
else 
fullFileName = [  ];
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDHQpnd.p.
% Please follow local copyright laws when handling this file.

