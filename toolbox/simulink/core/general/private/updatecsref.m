function updatecsref( varargin )



































argv = varargin;
[ openmodels, quitflag ] = displayIntroduction( argv );
if quitflag == 1
return ;
end 


disp( DAStudio.message( 'Simulink:tools:UpdatecsrefProgressMessage1' ) );

[ uniqueBaseCssets, csinBaseStruct, quitflag ] = analyzeModels( argv );
if quitflag == 1
return ;
end 


disp( DAStudio.message( 'Simulink:tools:UpdatecsrefProgressMessage2' ) );

if isempty( uniqueBaseCssets )
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefConfigSetRefNotFound' ) );
else 
updateCS = [  ];
updateMdl = [  ];
for i = 1:length( uniqueBaseCssets )
quitflag = compareSimulationTarget( uniqueBaseCssets{ i }, csinBaseStruct{ i } );
if quitflag == 0
[ updateCS, updateMdl ] = updatebaseCS( uniqueBaseCssets{ i }, csinBaseStruct{ i } );
end 
end 
displayResult( updateCS, updateMdl );
end 

disp( DAStudio.message( 'Simulink:tools:UpdatecsrefExitUpdatecsref' ) );


function displayResult( updateCS, updateMdl )
if ~isempty( updateMdl )
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefModelUpdated' ) );
disp( updateMdl );
end 

if ~isempty( updateCS )
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefWSVarUpdated' ) );
disp( updateCS );
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefUpdateMATFile' ) );
end 


function output = iswhitespace( str )
output = 1;
if ~isempty( str )
for i = 1:length( str )
c = str( i );
output = isspace( c );
if output == 0
return ;
end 
end 
end 


function [ updateCS, updateMdl ] = updatebaseCS( baseCS, csStruct )
cs = evalin( 'base', baseCS );
sfsim = cs.getComponent( 'Simulation Target' );
temp = csStruct{ 1 };
change = 0;
updateCS = [  ];
updateMdl = [  ];

change = showUpdate( change, baseCS, 'SimIntegrity', sfsim.SimIntegrity, temp.settings.SimIntegrity );
change = showUpdate( change, baseCS, 'SimCtrlC', sfsim.SimCtrlC, temp.settings.SimCtrlC );
change = showUpdate( change, baseCS, 'SFSimEcho', sfsim.SFSimEcho, temp.settings.SFSimEcho );
change = showUpdate( change, baseCS, 'SFSimEnableDebug', sfsim.SFSimEnableDebug, temp.settings.SFSimEnableDebug );
change = showUpdate( change, baseCS, 'SimCustomHeaderCode', sfsim.SimCustomHeaderCode, temp.settings.SimCustomHeaderCode );
change = showUpdate( change, baseCS, 'SimUserIncludeDirs', sfsim.SimUserIncludeDirs, temp.settings.SimUserIncludeDirs );
change = showUpdate( change, baseCS, 'SimUserLibraries', sfsim.SimUserLibraries, temp.settings.SimUserLibraries );
change = showUpdate( change, baseCS, 'SimCustomInitializer', sfsim.SimCustomInitializer, temp.settings.SimCustomInitializer );
change = showUpdate( change, baseCS, 'SimCustomTerminator', sfsim.SimCustomTerminator, temp.settings.SimCustomTerminator );
change = showUpdate( change, baseCS, 'SimUserSources', sfsim.SimUserSources, temp.settings.SimUserSources );

if ~isempty( temp.description ) && ~iswhitespace( temp.description )
change = 1;
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefAppendDescription', baseCS ) );
disp( temp.description );
end 

if change == 0
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefIgnoreWSVar', baseCS ) );
else 
choice = input( DAStudio.message( 'Simulink:tools:UpdatecsrefChangeWSVar', baseCS ), 's' );
if isempty( choice ) || choice( 1 ) == 'Y' || choice( 1 ) == 'y'
sfsim.SimIntegrity = temp.settings.SimIntegrity;
sfsim.SimCtrlC = temp.settings.SimCtrlC;
sfsim.SFSimEcho = temp.settings.SFSimEcho;
sfsim.SFSimEnableDebug = temp.settings.SFSimEnableDebug;
sfsim.SimCustomHeaderCode = temp.settings.SimCustomHeaderCode;
sfsim.SimUserIncludeDirs = temp.settings.SimUserIncludeDirs;
sfsim.SimUserLibraries = temp.settings.SimUserLibraries;
sfsim.SimCustomInitializer = temp.settings.SimCustomInitializer;
sfsim.SimCustomTerminator = temp.settings.SimCustomTerminator;
sfsim.SimUserSources = temp.settings.SimUserSources;
cs.description = [ cs.description, sprintf( '\n\n' ), temp.description ];
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefWSVarUpdatedSuccessfully', baseCS ) );
updateCS{ length( updateCS ) + 1 } = baseCS;
end 
end 

for i = 1:length( csStruct )
temp = csStruct{ i };
openmodels = loadModelwithWarningOff( temp.modelName, true );
for j = 1:length( openmodels )
if strcmp( temp.modelName, which( openmodels{ j } ) )
cs = getActiveConfigSet( openmodels{ j } );
if ~strcmp( cs.Name, temp.csrefName )
choice = input( DAStudio.message( 'Simulink:tools:UpdatecsrefSetActiveConfigSet',  ...
temp.csrefName, temp.modelName ), 's' );
if isempty( choice ) || choice( 1 ) == 'Y' || choice( 1 ) == 'y'
setActiveConfigSet( openmodels{ j }, temp.csrefName );
save_system( openmodels{ j } );
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefModelUpdatedSuccessfully', temp.modelName ) );
updateMdl{ length( updateMdl ) + 1 } = temp.modelName;
end 
else 
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefModelUpdatedSuccessfully', temp.modelName ) );
end 
end 
bdclose( openmodels{ j } );
end 
end 


function change = showUpdate( change, baseCS, field, oriVal, newVal )
if ~strcmp( oriVal, newVal )
change = 1;
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefUpdateParameter', field, baseCS, oriVal, newVal ) );
end 


function quitflag = compareSimulationTarget( baseCS, csStruct )
quitflag = 0;

disp( DAStudio.message( 'Simulink:tools:UpdatecsrefWSVarUsedBy', baseCS ) );
for i = 1:length( csStruct )
temp = csStruct{ i };
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefConfigSetRefinMdl', temp.csrefName, temp.modelName ) );
end 

if length( csStruct ) == 1
return ;
end 

base = csStruct{ 1 };

for i = 2:length( csStruct )
temp = csStruct{ i };
if ~strcmp( base.settings.SimIntegrity, temp.settings.SimIntegrity )
quitflag = paramDiff( base, temp, 'SimIntegrity' );
end 
if ~strcmp( base.settings.SimCtrlC, temp.settings.SimCtrlC )
quitflag = paramDiff( base, temp, 'SimCtrlC' );
end 
if ~strcmp( base.settings.SFSimEcho, temp.settings.SFSimEcho )
quitflag = paramDiff( base, temp, 'SFSimEcho' );
end 
if ~strcmp( base.settings.SFSimEnableDebug, temp.settings.SFSimEnableDebug )
quitflag = paramDiff( base, temp, 'SFSimEnableDebug' );
end 
if ~strcmp( base.settings.SimCustomHeaderCode, temp.settings.SimCustomHeaderCode )
quitflag = paramDiff( base, temp, 'SimCustomHeaderCode' );
end 
if ~strcmp( base.settings.SimUserIncludeDirs, temp.settings.SimUserIncludeDirs )
quitflag = paramDiff( base, temp, 'SimUserIncludeDirs' );
end 
if ~strcmp( base.settings.SimUserLibraries, temp.settings.SimUserLibraries )
quitflag = paramDiff( base, temp, 'SimUserLibraries' );
end 
if ~strcmp( base.settings.SimCustomInitializer, temp.settings.SimCustomInitializer )
quitflag = paramDiff( base, temp, 'SimCustomInitializer' );
end 
if ~strcmp( base.settings.SimCustomTerminator, temp.settings.SimCustomTerminator )
quitflag = paramDiff( base, temp, 'SimCustomTerminator' );
end 
if ~strcmp( base.settings.SimUserSources, temp.settings.SimUserSources )
quitflag = paramDiff( base, temp, 'SimUserSources' );
end 
if ~strcmp( base.description, temp.description )
quitflag = paramDiff( base, temp, 'description' );
end 
end 
if quitflag == 1
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefResolveDiffParam' ) );
end 


function quitflag = paramDiff( base, compare, param )
quitflag = 1;
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefDifferentParameterValue', base.modelName, compare.modelName, param ) );


function [ uniqueBaseCssets, csinBaseStruct, quitflag ] = analyzeModels( argv )
quitflag = 0;
uniqueModelNames = [  ];
uniqueBaseCssets = [  ];
csinBaseStruct = [  ];


for i = 1:length( argv )
if isa( argv{ i }, 'char' )

openmodels = loadModelwithWarningOff( argv{ i }, false );

for j = length( openmodels ): - 1:1

if quitflag == 0 && isempty( strmatch( openmodels{ j }, uniqueModelNames, 'exact' ) )
uniqueModelNames{ length( uniqueModelNames ) + 1 } = openmodels{ j };

if validsf( openmodels{ j } )

[ quitflag, csrefname, wsvar ] = analyzeOneModel( openmodels{ j } );
if quitflag == 0 && ~isempty( csrefname )

cstemp1 = getActiveConfigSet( openmodels{ j } );
if isa( cstemp1, 'Simulink.ConfigSetRef' )
cstemp = evalin( 'base', cstemp1.WSVarName );
else 
cstemp = cstemp1;
end 


temp.modelName = which( openmodels{ j } );
temp.csrefName = csrefname;
temp.settings = cstemp.getComponent( 'any', 'Simulation Target' );
temp.description = cstemp.description;



pos = strmatch( wsvar, uniqueBaseCssets, 'exact' );
if isempty( pos )

uniqueBaseCssets{ length( uniqueBaseCssets ) + 1 } = wsvar;
pos = length( uniqueBaseCssets );
csinBaseStruct{ length( csinBaseStruct ) + 1 } = { temp };
else 
temp1 = csinBaseStruct{ pos };
temp1{ length( temp1 ) + 1 } = temp;
csinBaseStruct{ pos } = temp1;
end 
end 
else 
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefNoStateflow', openmodels{ j } ) );
end 
end 
bdclose( openmodels{ j } );
end 

if quitflag == 1
return ;
end 
end 
end 


function [ quitflag, csrefname, wsvar ] = analyzeOneModel( modelName )











wsvar = [  ];
quitflag = 0;
csrefname = [  ];
csrefnames = [  ];
csrefstates = [  ];
csrefWSVarNames = [  ];
hasValidcsref = false;
hasInvalidcsref = false;










csets = getConfigSets( modelName );
for k = 1:length( csets )
cs = getConfigSet( modelName, csets{ k } );
if ~isempty( cs ) && isa( cs, 'Simulink.ConfigSetRef' ) && ~isempty( cs.WSVarName )
csrefnames{ length( csrefnames ) + 1 } = cs.Name;
csrefWSVarNames{ length( csrefWSVarNames ) + 1 } = cs.WSVarName;
if evalin( 'base', [ '~exist(''', cs.WSVarName, ''',''var'');' ] )
csrefstates{ length( csrefstates ) + 1 } = 2;
hasInvalidcsref = true;
else 
baseCS = evalin( 'base', cs.WSVarName );
if ~isa( baseCS, 'Simulink.ConfigSet' )
csrefstates{ length( csrefstates ) + 1 } = 3;
hasInvalidcsref = true;
else 
csrefstates{ length( csrefstates ) + 1 } = 1;
hasValidcsref = true;
end 
end 
end 
end 

if isempty( csrefnames )
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefNoConfigSetRef', modelName ) );
return ;
end 

if hasInvalidcsref


disp( DAStudio.message( 'Simulink:tools:UpdatecsrefInvalidConfigSetRef', modelName ) );
displayConfigSetRef( csrefnames, csrefstates, csrefWSVarNames, false );
end 

if ~hasValidcsref
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefNeedValidConfigSetRef', modelName ) );
quitflag = 1;
return ;
end 


disp( DAStudio.message( 'Simulink:tools:UpdatecsrefValidConfigSetRef', modelName ) );


validcount = displayConfigSetRef( csrefnames, csrefstates, csrefWSVarNames, true );

if validcount == 1
cs = getActiveConfigSet( modelName );
if strcmp( cs.Name, csrefnames{ 1 } )
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefOnlyConfigSetRefisActive' ) );
else 
choice = input( DAStudio.message( 'Simulink:tools:UpdatecsrefOnlyConfigSetRef' ), 's' );
if ~isempty( choice ) && choice( 1 ) ~= 'Y' && choice( 1 ) ~= 'y'
quitflag = 1;
return ;
end 
end 
choice = 1;
else 
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefQuit', int2str( validcount + 1 ) ) );
choice = input( DAStudio.message( 'Simulink:tools:UpdatecsrefChooseConfigSetRef' ) );
if isempty( choice ) || choice > validcount + 1
choice = 1;
end 

if choice == validcount + 1
quitflag = 1;
return ;
end 
end 

counter = 1;
for k = 1:length( csrefnames )
if csrefstates{ k } == 1
if counter == choice
csrefname = csrefnames{ k };
cs = getConfigSet( modelName, csrefname );
wsvar = cs.WSVarName;
return ;
else 
counter = counter + 1;
end 
end 
end 



function output = displayConfigSetRef( csrefnames, csrefstates, csrefWSVarNames, flag )
output = 0;
for k = 1:length( csrefnames )
if flag
if csrefstates{ k } == 1
output = output + 1;
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefConfigSetRefValue', int2str( output ), csrefnames{ k }, csrefWSVarNames{ k } ) );
end 
else 
message = [ '    ', DAStudio.message( 'Simulink:tools:UpdatecsrefConfigSetRefInfoBase', csrefnames{ k }, csrefWSVarNames{ k } ) ];

if csrefstates{ k } == 2
disp( [ message, DAStudio.message( 'Simulink:tools:UpdatecsrefInvalidConfigSetRef1', csrefWSVarNames{ k } ) ] );
elseif csrefstates{ k } == 3
disp( [ message, DAStudio.message( 'Simulink:tools:UpdatecsrefInvalidConfigSetRef2', csrefWSVarNames{ k } ) ] );
end 
end 
end 


function [ openmodels, quitflag ] = displayIntroduction( argv )



openmodels = find_system( 'type', 'block_diagram' );
openlibs = find_system( 'BlockDiagramType', 'library' );

openmodels = setdiff( openmodels, openlibs );

quitflag = 0;


disp( DAStudio.message( 'Simulink:tools:UpdatecsrefIntroduction' ) );

if isempty( argv ) || isempty( argv{ 1 } ) || ~isempty( openmodels )


disp( DAStudio.message( 'Simulink:tools:UpdatecsrefRequirements1' ) );
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefRequirements2' ) );
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefRequirements3' ) );
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefRequirements4' ) );
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefRequirements5' ) );
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefRequirements6' ) );
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefRequirements7' ) );


if isempty( argv ) || isempty( argv{ 1 } )
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefNeedModelFiles' ) );
end 


if ~isempty( openmodels )
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefNeedCloseModelFiles' ) );
disp( openmodels );
disp( ' ' );
end 
quitflag = 1;
end 



function output = validsf( modelname )
output = false;
hModel = get_param( modelname, 'Handle' );
machine = find( get_param( hModel, 'Object' ), '-isa', 'Stateflow.Machine' );
if ~isempty( machine )
allTargets = sf( 'TargetsOf', machine.id );
sfuntarget = sf( 'find', allTargets, 'target.name', 'sfun' );
output = ~isempty( sfuntarget );
end 


function output = loadModelwithWarningOff( model, update )
if isa( model, 'cell' )
modelname = char( model );
else 
modelname = model;
end 

if exist( modelname, 'file' )
if update
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefUpdatingModel', modelname ) );
else 
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefLoadingModel', modelname ) );
end 


warning( 'off', 'Simulink:tools:ConflictConfigSetRefStateflowTargets' );
warning( 'off', 'Simulink:tools:PotentialConflictConfigSetRefStateflowTargets' );
load_system( modelname );
warning( 'on', 'Simulink:tools:PotentialConflictConfigSetRefStateflowTargets' );
warning( 'on', 'Simulink:tools:ConflictConfigSetRefStateflowTargets' );

output = find_system( 'type', 'block_diagram' );
else 
output = [  ];
disp( DAStudio.message( 'Simulink:tools:UpdatecsrefUnknownFileName', modelname ) );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpvsAFmO.p.
% Please follow local copyright laws when handling this file.

