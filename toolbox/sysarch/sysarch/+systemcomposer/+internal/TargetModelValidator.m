classdef TargetModelValidator < handle






properties ( GetAccess = public, SetAccess = protected )
targetModel;
modelPath;
modelDirty = false;
modelLoaded = false;
modelExists = false;
directoryExists = false;
end 

methods 
function this = TargetModelValidator( modelName, dirPath )



R36
modelName{ mustBeTextScalar }
dirPath{ mustBeTextScalar } = string( pwd );
end 

this.targetModel = convertStringsToChars( modelName );
if isempty( convertStringsToChars( dirPath ) )
this.modelPath = string( pwd );
else 
this.modelPath = dirPath;
end 
this.modelLoaded = bdIsLoaded( this.targetModel );
if this.modelLoaded
this.modelDirty = strcmp( get_param( this.targetModel, 'Dirty' ), 'on' );
end 
this.modelExists = ~isempty( dir( fullfile( this.modelPath, [ this.targetModel, '.slx' ] ) ) );
this.directoryExists = exist( this.modelPath, 'dir' ) == 7;
end 

function canBeConverted = validate( this, throwError )
R36
this
throwError{ mustBeNumericOrLogical } = false;
end 
canBeConverted = this.canConvert(  );
if throwError && ~canBeConverted
this.throwError(  );
end 
end 

function canBeConverted = canConvert( this )



canBeConverted = ~( this.modelLoaded || this.modelExists ) && this.directoryExists;
end 

function msg = getErrorMessage( this )


msg = "";
if this.modelLoaded
if this.modelDirty
msg = message( 'SystemArchitecture:SaveAndLink:ModelLoadedAndDirtyError', this.targetModel ).string;
return ;
end 
msg = message( 'SystemArchitecture:SaveAndLink:ModelLoadedError', this.targetModel ).string;
return ;
end 
if this.modelExists
msg = message( 'SystemArchitecture:SaveAndLink:ModelAlreadyExistsError', this.targetModel ).string;
return ;
end 
if ~this.directoryExists
msg = message( 'SystemArchitecture:SaveAndLink:DirectoryDoesNotExist', this.modelPath ).string;
return ;
end 
end 

function throwError( this )


[ ~, fileName ] = fileparts( this.targetModel );
if this.modelLoaded
if this.modelDirty
msgObj = message( 'SystemArchitecture:SaveAndLink:ModelLoadedAndDirtyError', fileName );
exception = MException( 'systemcomposer:SaveAndLink:ModelLoadedAndDirtyError',  ...
msgObj.getString );
throw( exception );
end 
msgObj = message( 'SystemArchitecture:SaveAndLink:ModelLoadedError', fileName );
exception = MException( 'systemcomposer:SaveAndLink:ModelLoadedError',  ...
msgObj.getString );
throw( exception );
end 
if this.modelExists
msgObj = message( 'SystemArchitecture:SaveAndLink:ModelAlreadyExistsError', fileName );
exception = MException( 'systemcomposer:SaveAndLink:ModelAlreadyExistsError',  ...
msgObj.getString );
throw( exception );
end 
if ~this.directoryExists
msgObj = message( 'SystemArchitecture:SaveAndLink:DirectoryDoesNotExist', this.modelPath );
exception = MException( 'SystemArchitecture:SaveAndLink:DirectoryDoesNotExist',  ...
replace( msgObj.getString, '\', '/' ) );
throw( exception );
end 
end 

function popupDialog( this )


if this.modelLoaded
if this.modelDirty
return ;
end 

answer = questdlg(  ...
message( 'SystemArchitecture:SaveAndLink:SaveNameLoadedCloseWarning', this.targetModel ).string,  ...
message( 'SystemArchitecture:SaveAndLink:CloseWarning' ).string,  ...
message( 'SystemArchitecture:SaveAndLink:Yes' ).string,  ...
message( 'SystemArchitecture:SaveAndLink:No' ).string,  ...
message( 'SystemArchitecture:SaveAndLink:No' ).string );

if isempty( answer ) || answer == message( 'SystemArchitecture:SaveAndLink:No' ).string
return ;
end 

assert( strcmp( answer, message( 'SystemArchitecture:SaveAndLink:Yes' ).string ),  ...
'Should only get here if user selected yes' );
close_system( this.targetModel );
this.modelLoaded = false;
end 

if this.modelExists
answer = questdlg(  ...
message( 'SystemArchitecture:SaveAndLink:SaveNameExistsWarning', this.targetModel ).string,  ...
message( 'SystemArchitecture:SaveAndLink:ReplaceWarning' ).string,  ...
message( 'SystemArchitecture:SaveAndLink:Yes' ).string,  ...
message( 'SystemArchitecture:SaveAndLink:No' ).string,  ...
message( 'SystemArchitecture:SaveAndLink:No' ).string );

if isempty( answer ) || answer == message( 'SystemArchitecture:SaveAndLink:No' ).string
return ;
end 

assert( strcmp( answer, message( 'SystemArchitecture:SaveAndLink:Yes' ).string ),  ...
'Should only get here if user selected yes' );
delete( fullfile( this.modelPath, [ this.targetModel, '.slx' ] ) );
this.modelExists = false;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKqzaYx.p.
% Please follow local copyright laws when handling this file.

