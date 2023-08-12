function tunablevars2parameterobjects( model, objClass )































if nargin > 0
model = convertStringsToChars( model );
end 

if nargin > 1
objClass = convertStringsToChars( objClass );
end 

if nargin < 1
DAStudio.error( 'Simulink:dialog:NoModelSpecified' );
elseif nargin == 1
objClass = 'Simulink.Parameter';
elseif nargin == 2

try 
tmpObj = eval( objClass );
if ~isa( tmpObj, 'Simulink.Parameter' )
l_ErrorForInvalidClass( objClass );
end 
catch 
l_ErrorForInvalidClass( objClass );
end 
end 

model = get_param( model, 'Name' );

dd = get_param( model, 'DataDictionary' );
if ~isempty( dd )
if ~isequal( exist( dd, 'file' ), 2 )
dispTxt = DAStudio.message( 'SLDD:sldd:DictionaryNotFound', dd );
disp( dispTxt );
return ;
end 
end 


mdlVars = get_param( model, 'TunableVars' );
mdlSCs = get_param( model, 'TunableVarsStorageClass' );
mdlTQs = get_param( model, 'TunableVarsTypeQualifier' );


if isempty( mdlVars )
dispTxt = DAStudio.message( 'Simulink:dialog:TunableVarNotSpecifiedInModel', model );
disp( dispTxt );
return ;
end 


try 
nameInfo = eval( [ '{''', strrep( mdlVars, ',', ''';''' ), '''}' ] );
scInfo = eval( [ '{''', strrep( mdlSCs, ',', ''';''' ), '''}' ] );
tqInfo = eval( [ '{''', strrep( mdlTQs, ',', ''';''' ), '''}' ] );

if ( ~isequal( size( nameInfo ), size( scInfo ) ) ||  ...
~isequal( size( nameInfo ), size( tqInfo ) ) )
DAStudio.error( 'Simulink:dialog:NumTunableVarsTypeQualsDoesNotMatch' );
end 

mdlInfo = struct(  ...
'Name', nameInfo,  ...
'StorageClass', scInfo,  ...
'TypeQualifier', tqInfo );
catch err
DAStudio.error( 'Simulink:dialog:TunableVarsInfoInvalid',  ...
model, err.message );
end 


idx = 1;
while ( idx <= length( mdlInfo ) )
tmpObj = eval( objClass );


thisName = mdlInfo( idx ).Name;
if existsInGlobalScope( model, thisName )
dataAccessor = Simulink.data.DataAccessor.createForExternalData( model );
varId = dataAccessor.identifyByName( thisName );

assert( ~isempty( varId ), 'Variable ID cannot be empty' );
tmpArray = dataAccessor.getVariable( varId );



if isa( tmpArray, 'Simulink.Parameter' )


mdlInfo( idx ) = [  ];

MSLDiagnostic( 'Simulink:dialog:DiscardInfoFromModelForTunableVar',  ...
model, thisName ).reportAsWarning;
continue ;
end 


try 
tmpObj.Value = tmpArray;
catch 


idx = idx + 1;

MSLDiagnostic( 'Simulink:dialog:SkipConvOfTunableVarForModelVarInBase',  ...
thisName, model ).reportAsWarning;
continue ;
end 
else 


idx = idx + 1;

MSLDiagnostic( 'Simulink:dialog:SkipConvOfTunableVarForMissingVar',  ...
thisName, model ).reportAsWarning;
continue ;
end 

try 

thisSC = mdlInfo( idx ).StorageClass;
if strcmp( thisSC, 'Auto' )
thisSC = 'SimulinkGlobal';
end 
tmpObj.CoderInfo.StorageClass = thisSC;
catch err


idx = idx + 1;

MSLDiagnostic( 'Simulink:dialog:SkipConvOfTunableVarForModelInvalidSC',  ...
thisName, model, thisSC, err.message ).reportAsWarning;
continue ;
end 

try 

thisTQ = strtrim( mdlInfo( idx ).TypeQualifier );
if ~isempty( thisTQ )
tmpObj.CoderInfo.TypeQualifier = thisTQ;
end 
catch err


idx = idx + 1;

MSLDiagnostic( 'Simulink:dialog:SkipConvOfTunableVarForModelInvalidTypeQual',  ...
thisName, model, thisTQ, err.message ).reportAsWarning;
continue ;
end 

try 

assigninGlobalScope( model, thisName, tmpObj );
catch err


idx = idx + 1;

MSLDiagnostic( 'Simulink:dialog:SkipConvOfTunableVarForModelUnableToAssignVarInBase',  ...
thisName, model, err.message ).reportAsWarning;
continue ;
end 




mdlInfo( idx ) = [  ];
end 



mdlVars = '';
mdlSCs = '';
mdlTQs = '';
if ~isempty( mdlInfo )
for idx = 1:length( mdlInfo )
mdlVars = [ mdlVars, ',', mdlInfo( idx ).Name ];%#ok
mdlSCs = [ mdlSCs, ',', mdlInfo( idx ).StorageClass ];%#ok
mdlTQs = [ mdlTQs, ',', mdlInfo( idx ).TypeQualifier ];%#ok
end 
mdlVars( 1 ) = '';
mdlSCs( 1 ) = '';
mdlTQs( 1 ) = '';
end 


set_param( model, 'TunableVars', mdlVars,  ...
'TunableVarsStorageClass', mdlSCs,  ...
'TunableVarsTypeQualifier', mdlTQs );






function l_ErrorForInvalidClass( objClass )

DAStudio.error( 'Simulink:dialog:InvalidParamClassNotSubClassOfSimParam',  ...
objClass, 'Simulink.Parameter' );




% Decoded using De-pcode utility v1.2 from file /tmp/tmphRPFLj.p.
% Please follow local copyright laws when handling this file.

