function result = saveToFile( this, fileChooser )

arguments
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


