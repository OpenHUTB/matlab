function fullFileName = getFileNameFromDialog( ~, filter )

arguments
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


