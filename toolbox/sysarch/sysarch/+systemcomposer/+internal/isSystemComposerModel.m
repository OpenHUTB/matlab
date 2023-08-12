function tf = isSystemComposerModel( modelName )









try 

tf = strcmpi( get_param( modelName, 'SimulinkSubDomain' ), 'Architecture' ) ||  ...
strcmpi( get_param( modelName, 'SimulinkSubDomain' ), 'SoftwareArchitecture' ) ||  ...
strcmpi( get_param( modelName, 'SimulinkSubDomain' ), 'AUTOSARArchitecture' );
return ;
catch 
end 



str = which( modelName, '-all' );
matches = contains( str, '.slx', 'IgnoreCase', true );
slxFile = str( matches );
if ( numel( slxFile ) == 0 )
msgObj = message( 'SystemArchitecture:API:ModelNotFound', modelName );
exception = MException( 'systemcomposer:API:ModelNotFound',  ...
msgObj.getString );
throw( exception );
elseif ( numel( slxFile ) > 1 )
msgObj = message( 'SystemArchitecture:API:ShadowedFile', modelName );
exception = MException( 'systemcomposer:API:ShadowedFile',  ...
msgObj.getString );
throw( exception );
else 
slxReader = Simulink.loadsave.SLXPackageReader( slxFile{ 1 } );
tf = slxReader.hasPart( '/simulink/systemcomposer/architecture.xml' );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpmQv0oO.p.
% Please follow local copyright laws when handling this file.

