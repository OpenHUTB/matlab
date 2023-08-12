function loadParamSet( this, fileName, page )
















R36
this
fileName
page = 0
end 


validateattributes( page, { 'numeric' }, { 'scalar' } );
if page < 0 || page >= this.getNumPages(  ) || ( floor( page ) ~= page )
this.throwError( 'slrealtime:target:invalidPageNum', num2str( page ) );
end 

try 
if ~this.isLoaded
this.throwError( 'slrealtime:paramSet:tgIsNotLoaded' );
end 

validateattributes( fileName, { 'char', 'string' }, { 'scalartext' } );
fileName = convertStringsToChars( fileName );

[ ~, fileName, fileExt ] = fileparts( fileName );
if isempty( fileName )
this.throwError( 'slrealtime:paramSet:invalidFileName' );
end 



appName = this.tc.ModelProperties.Application;
filelist = this.listParamSet( appName );
if ~contains( fileName, filelist )
this.throwError( 'slrealtime:paramSet:paramSetNotExist', fileName );
return ;
end 
catch ME
throwAsCaller( ME );
end 




loadComplete = false;
function cb( src, evnt )
if ~evnt.AffectedObject.isParamSetRunning
loadComplete = true;
end 
end 


try 

ps = this.importParamSet( fileName, appName );
[ blockPath, paramName, val ] = ps.getParamValueChangedEventNotifyList( this );

l1 = addlistener( this.tc, 'isParamSetRunning', 'PostSet', @cb );
c1 = onCleanup( @(  )delete( l1 ) );

this.tc.paramSetCommand( 'load', fileName, 0, page );
while ~loadComplete
pause( 0.01 );
end 

if ~isempty( this.tc.ParamSetProperties.Error )
this.throwError( 'slrealtime:paramSet:failOnLoad', this.tc.ParamSetProperties.Error );
end 

notify( this, 'ParamSetChanged', slrealtime.events.TargetParamSetData( blockPath, paramName, val, page ) );

catch ME
throwAsCaller( ME );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXGZUNS.p.
% Please follow local copyright laws when handling this file.

