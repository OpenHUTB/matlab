function result = loadExclusionsFile( this, fileChooser )





R36
this
fileChooser = CloneDetector.Utils.DefaultFileChooser(  )
end 

result = [  ];
[ filename, pathname, ~ ] = fileChooser.chooseFile( { '*.xml' },  ...
DAStudio.message( 'slcheck:filtercatalog:OpenExclusionFile' ),  ...
'' );

filePath = fullfile( pathname, filename );


if ~isequal( filename, 0 ) && ~isequal( pathname, 0 )
[ ~, ~, ext ] = fileparts( filename );
if ~strcmpi( ext, '.xml' )
DAStudio.error( 'sl_pir_cpp:creator:Exclusions_InvalidFile' );
end 
this.setExternalFilePath( filePath );

this.isSaveToSlx = false;
this.isTableDataValid = false;
end 




try 
result = this.getTableData(  );
catch ex
if strcmp( ex.identifier, 'slcheck:filtercatalog:SerializationFileBadFormat' )
this.setExternalFilePath( '' );
DAStudio.error( 'sl_pir_cpp:creator:Exclusions_InvalidContentInFile', filePath );
end 
end 


window = Advisor.UIService.getInstance.getWindowById( this.AppID, this.windowId );
window.bringToFront(  );


this.isSaveToSlx = true;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpS_aRSJ.p.
% Please follow local copyright laws when handling this file.

