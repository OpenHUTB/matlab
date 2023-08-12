function result = saveToFile( this, fileChooser )




R36
this
fileChooser = CloneDetector.Utils.DefaultFileSaver(  )
end 

result = [  ];

this.updateBackend(  );

exclusionsObj = CloneDetector.Exclusions(  );
manager = exclusionsObj.getCloneDetectionFilterManager( this.model );




[ filename, pathname, ~ ] = fileChooser.chooseFile( { '*.xml';'*.*' },  ...
DAStudio.message( 'slcheck:filtercatalog:SaveExclusions' ),  ...
'' );


if ~isequal( filename, 0 ) && ~isequal( pathname, 0 )
filePath = fullfile( pathname, filename );
manager.saveToFile( filePath );

if ( this.isSaveToSlx )
save_system( this.model );
this.updateDialogForAction( this.UpdateDialogAction.Save, filePath );
end 
end 


this.isSaveToSlx = true;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpfkq7hz.p.
% Please follow local copyright laws when handling this file.

