function backupPath = slImportFavoriteCommands( varargin )





fm = SLStudio.FavoriteCommands.Manager.get;
fm.reorderCategoriesByGalleryState(  );


prefs = fm.getPreferences(  );
importPath = varargin{ 1 };

if exist( importPath, 'file' ) ~= 2
DAStudio.error( 'Simulink:utility:SystemTargetFileNotFound', importPath );
end 

if nargin == 2 && strcmp( varargin{ 2 }, 'overwrite' )
fm.clearSavedPrefs(  );
fm.loadPreferences( importPath, true );
elseif nargin == 1
fm.mergePreferences( importPath );
elseif nargin > 2
DAStudio.error( 'Simulink:utility:invNumArgsWithRange', mfilename, 1, 2 );
else 
DAStudio.error( 'Simulink:utility:invalidInputArgs', mfilename );
end 

backupPath = fm.backupPreferences( prefs );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpR5NcEo.p.
% Please follow local copyright laws when handling this file.

