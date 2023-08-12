function tunableParamCheck( this )











numMdls = numel( this.AllModels );
if this.mdlIdx == 0

this.mdlIdx = numMdls;
end 

if numMdls > 1

accelModeUnderNormalMode = false;
hasNormalSimMode = false;
topAccelMode = strcmpi( get_param( this.ModelName, 'SimulationMode' ), 'accelerator' );

for ii = numMdls: - 1:1
mdlName = this.AllModels( ii ).modelName;
if ~bdIsLoaded( mdlName )
load_system( mdlName );
end 
simMode = get_param( mdlName, 'SimulationMode' );
if strcmpi( simMode, 'normal' )
hasNormalSimMode = true;
elseif hasNormalSimMode && strcmpi( simMode, 'accelerator' )

accelModeUnderNormalMode = true;
end 
end 



findvarMode = 'compiled';
if accelModeUnderNormalMode
topModel = this.ModelName;
usedVars = Simulink.findVars( topModel,  ...
'SourceType', 'base workspace',  ...
'SearchReferencedModels', 'on',  ...
'findusedvars', 'on' );


findvarMode = 'cached';
for ii = 1:numel( usedVars )
var = usedVars( ii );
obj = evalVar( var );
if isa( obj, 'Simulink.Parameter' ) && strcmp( obj.CoderInfo.StorageClass, 'Auto' )
error( message( 'hdlcoder:engine:unsupportedautotunableparam', var.Name, topModel ) );
end 
end 
end 



if topAccelMode
for ii = 1:numMdls - 1
this.mdlIdx = ii;
mdlName = this.AllModels( ii ).modelName;
usedVars = Simulink.findVars( mdlName,  ...
'SourceType', 'base workspace',  ...
'SearchReferencedModels', 'on',  ...
'findusedvars', 'on',  ...
'SearchMethod', findvarMode );
for jj = 1:numel( usedVars )
var = usedVars( jj );
obj = evalVar( var );
if ( ~isa( obj, 'Simulink.Parameter' ) ||  ...
strcmp( obj.CoderInfo.StorageClass, 'Auto' ) ) &&  ...
~isa( obj, 'Simulink.Bus' )


error( message( 'hdlcoder:engine:unsupportedtunableparam',  ...
var.Name, mdlName, this.ModelName ) );
end 
end 
end 
end 
this.mdlIdx = numMdls;
end 
end 


function obj = evalVar( var )
isDataDictionary = strcmpi( var.SourceType, 'data dictionary' );
if isDataDictionary
dictionaryObj = Simulink.data.dictionary.open( var.Source );
dataLoc = getSection( dictionaryObj, 'Design Data' );
else 
dataLoc = 'base';
end 
obj = evalin( dataLoc, var.Name );
if isDataDictionary
dictionaryObj.close;
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpU1RrRy.p.
% Please follow local copyright laws when handling this file.

