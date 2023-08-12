function validateModel( modelName )





try 
if isstring( modelName ) && isscalar( modelName )
modelName = char( modelName );
end 

isLoaded = bdIsLoaded( modelName );
catch 

isLoaded = false;
end 
if ( ~ischar( modelName ) && ~( isstring( modelName ) && isscalar( modelName ) ) ) ...
 || ( ~exist( [ modelName, '.mdl' ], 'file' ) && ~exist( [ modelName, '.slx' ], 'file' ) && ~isLoaded )
DAStudio.error( 'sl_inputmap:inputmap:apiModel' );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpMpwZ_X.p.
% Please follow local copyright laws when handling this file.

