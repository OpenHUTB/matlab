classdef ( Sealed, Hidden )Component < simscape.battery.internal.sscinterface.StringItem




properties ( Constant )
Type = "Component";
end 

properties ( Access = private )
SectionsContainer = simscape.battery.internal.sscinterface.SectionsContainer;
ComponentName;
ComponentDescription;
end 

methods 
function obj = Component( componentName, componentDescription )


R36
componentName string{ mustBeTextScalar, mustBeNonzeroLengthText }
componentDescription string{ mustBeTextScalar, mustBeNonzeroLengthText }
end 
obj.ComponentName = componentName;
obj.ComponentDescription = simscape.battery.internal.sscinterface.Comment( componentDescription );
end 

function obj = addSection( obj, section )

obj.SectionsContainer = obj.SectionsContainer.addSection( section );
end 

function obj = addIfStatement( obj, ifStatement )

obj.SectionsContainer = obj.SectionsContainer.addIfStatement( ifStatement );
end 

function obj = addForLoop( obj, forLoop )

obj.SectionsContainer = obj.SectionsContainer.addForLoop( forLoop );
end 

function componentName = getName( obj )

componentName = obj.ComponentName;
end 

function writeToFile( obj, fullFile )


R36
obj
fullFile string{ mustBeTextScalar, mustBeNonzeroLengthText }
end 


assert( ~isfile( fullFile ), message( "physmod:battery:sscinterface:FileExists" ) );


[ filepath, ~, fileExtension ] = fileparts( fullFile );
assert( isfolder( filepath ), message( "physmod:battery:sscinterface:FilePathMissing" ) );


assert( isequal( fileExtension, ".ssc" ), message( "physmod:battery:sscinterface:WrongFileExtension" ) );


componentFileId = fopen( fullFile, "w" );



componentString = obj.getString(  );
commentComponentString = strrep( componentString, "%", "%%" );


drawnow;


indentedComponentString = indentcode( commentComponentString, 'simscape' );


fprintf( componentFileId, indentedComponentString );
fclose( componentFileId );
end 
end 

methods ( Access = protected )
function children = getChildren( obj )

children = obj.ComponentDescription;
children = [ children, obj.SectionsContainer.getContent ];
end 

function str = getOpenerString( obj )

str = "component " + obj.ComponentName + newline;
end 

function str = getTerminalString( ~ )

str = "end";
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpJx6VQS.p.
% Please follow local copyright laws when handling this file.

