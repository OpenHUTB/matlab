classdef ModelVariableResult < mlreportgen.finder.Result






































properties ( SetAccess = protected )



Object = [  ];




Name string












Source string











SourceType string




Users string
end 

properties ( Access = protected, Hidden )
Reporter = [  ];
end 

properties ( Access = public, Hidden )


HashLinkIDs = true;
end 

properties 




Tag;
end 

properties ( SetAccess = ?slreportgen.finder.ModelVariableFinder )





ModelBlockPath = [  ];
end 

methods ( Access = { ?slreportgen.finder.ModelVariableFinder, ?slreportgen.report.BusObject } )
function this = ModelVariableResult( varargin )
this = this@mlreportgen.finder.Result( varargin{ : } );
mustBeNonempty( this.Object );
mlreportgen.report.validators.mustBeInstanceOf( "Simulink.VariableUsage", this.Object );
initProperties( this );
end 
end 

methods 
function reporter = getReporter( this )










if isempty( this.Reporter )
reporter = slreportgen.report.ModelVariable( "Variable", this.Object );
reporter.ModelBlockPath = this.ModelBlockPath;
reporter.LinkTarget = getVariableID( this );
this.Reporter = reporter;
else 
reporter = this.Reporter;
end 
end 

function value = getVariableValue( this )







reporter = getReporter( this );
value = getVariableValue( reporter );
end 

function id = getVariableID( this )










id = compose( "%s-%s", this.Name, this.Source );
if ~isempty( this.ModelBlockPath )


id = compose( "%s-%s", id, this.ModelBlockPath );
end 
if this.HashLinkIDs
id = mlreportgen.utils.normalizeLinkID( id );
end 
end 

function title = getDefaultSummaryTableTitle( ~, varargin )






title = string( getString( message( "slreportgen:report:SummaryTable:modelVariables" ) ) );
end 

function props = getDefaultSummaryProperties( ~, varargin )











props = [ "Name", "Class", "Source", "SourceType" ];
end 

function propVals = getPropertyValues( this, propNames, options )































R36
this
propNames string
options.ReturnType( 1, 1 )string ...
{ mustBeMember( options.ReturnType, [ "native", "string", "DOM" ] ) } = "native"
end 


returnRawValue = strcmp( options.ReturnType, "native" );
returnDOMValue = strcmp( options.ReturnType, "DOM" );

nProps = numel( propNames );
propVals = cell( 1, nProps );



varVal = getVariableValue( this );
isSimParam = isa( varVal, "Simulink.Parameter" );
if isSimParam
paramVar = varVal;
varVal = paramVar.Value;
end 


for idx = 1:nProps
prop = propNames( idx );
normProp = lower( strrep( prop, " ", "" ) );



convertToString = ~returnRawValue;
switch normProp
case { "usedby", "users" }


rptr = getReporter( this );
val = rptr.getUsedByDOM( this.Users );


val = formatDOMPropertyValue( this, val, ConvertToString = ~returnDOMValue );

convertToString = false;
case "class"
if isSimParam
val = paramVar.DataType;
else 
val = string( class( varVal ) );
end 
case "value"
val = varVal;
case "bytes"
whosInfo = whos( 'varVal' );
val = whosInfo.bytes;
case "size"
if isSimParam
val = paramVar.Dimensions;
else 
val = size( varVal );
end 
case { "rtwstorageclass", "storageclass" }
if isSimParam
val = paramVar.CoderInfo.StorageClass;
else 
val = getRtwStorageClass( this );
end 
case "callingstring"
val = getCallingStrings( this );
if returnDOMValue && numel( val ) > 1
val = mlreportgen.dom.UnorderedList( val );
val.StyleName = this.SummaryTableListStyle;
end 

convertToString = false;
otherwise 
if isprop( this, prop )
val = this.( prop );
else 
try 
if isSimParam
val = paramVar.( prop );
else 
val = varVal.( prop );
end 
catch ME %#ok<NASGU>
val = "N/A";
end 
end 
end 


if convertToString && ~isempty( val )
val = mlreportgen.utils.toString( val );
end 
propVals{ idx } = val;
end 
end 

function id = getReporterLinkTargetID( this )







id = getReporterLinkTargetID@mlreportgen.finder.Result( this );
if isempty( id )
id = getVariableID( this );
end 
end 

function presenter = getPresenter( this )%#ok<MANU>
presenter = [  ];
end 
end 

methods ( Access = private )
function initProperties( this )
obj = this.Object;


this.Name = obj.Name;
this.Source = obj.Source;
this.SourceType = obj.SourceType;
this.Users = obj.Users;
end 

function storageClass = getRtwStorageClass( this )
storageClass = "Auto";


if isempty( this.Users )
return 
end 

hModel = bdroot( this.Users{ 1 } );

tunableVarsNames = get_param( hModel, 'TunableVars' );



if ~isempty( tunableVarsNames )
tunableVarsNames = strsplit( tunableVarsNames, ",", "CollapseDelimiters", false );
varIdx = find( strcmp( tunableVarsNames, this.Name ), 1 );

if ~isempty( varIdx )
nVarNames = numel( tunableVarsNames );


tunableVarsStorageClasses = get_param( hModel, 'TunableVarsStorageClass' );
tunableVarsStorageClasses = strsplit( tunableVarsStorageClasses, ",", "CollapseDelimiters", false );
nStorageClasses = numel( tunableVarsStorageClasses );
tunableVarsTypeQualifiers = get_param( hModel, 'TunableVarsTypeQualifier' );
tunableVarsTypeQualifiers = strsplit( tunableVarsTypeQualifiers, ",", "CollapseDelimiters", false );
nTypeQual = numel( tunableVarsTypeQualifiers );


storageClass = "";
if nStorageClasses ~= nVarNames
warning( getString( message( 'RptgenSL:rsl_csl_obj_fun_var:nameStorageClassMismatchWarning' ) ) );
return ;
elseif nTypeQual ~= nVarNames
warning( getString( message( 'RptgenSL:rsl_csl_obj_fun_var:nameQualifierMismatchWarning' ) ) );
return ;
elseif nTypeQual ~= nStorageClasses
warning( getString( message( 'RptgenSL:rsl_csl_obj_fun_var:storageQualifierMismatchWarning' ) ) );
return ;
end 

storageClass = string( strtrim( tunableVarsStorageClasses{ varIdx } ) );
typeQual = strtrim( tunableVarsTypeQualifiers{ varIdx } );


if ~isempty( typeQual )
storageClass = strcat( storageClass, " (", typeQual, ")" );
elseif strcmpi( storageClass, 'auto' )
storageClass = "SimulinkGlobal";
end 
end 
end 
end 

function val = getCallingStrings( this )
val = string.empty;
blks = this.Users;
nBlks = numel( blks );


isUnmasked = cellfun( 'isempty',  ...
mlreportgen.utils.safeGet( blks, 'MaskType', 'get_param' ) );


for idx = 1:nBlks
currBlk = blks{ idx };
if isUnmasked( idx )

if slprivate( 'is_stateflow_based_block', currBlk )
return ;
end 


dParams = getEvaluatedBlockParams( currBlk );


for j = 1:length( dParams )
try 
paramExpr = get_param( currBlk, dParams{ j } );
catch ME %#ok
paramExpr = '';
end 

if ~isempty( paramExpr ) && ischar( paramExpr ) && ~strcmpi( paramExpr, 'inf' )


wordsInExpr = getVarAndFuncNames( paramExpr );


if ~isempty( wordsInExpr ) && ismember( this.Name, wordsInExpr )
val( end  + 1 ) = paramExpr;%#ok<AGROW>
end 
end 
end 
else 
maskValues = get_param( currBlk, 'MaskValues' );
maskStyles = get_param( currBlk, 'MaskStyles' );
maskVisbility = get_param( currBlk, 'MaskVisibilities' );




maskVarTypes = regexp( get_param( currBlk, 'MaskVariables' ),  ...
'=([^;]*)\d+;', 'tokens' );

if ~isempty( maskVarTypes )
for i = 1:length( maskValues )
if strcmp( maskStyles{ i }, 'edit' ) &&  ...
strcmpi( maskVisbility{ i }, 'on' ) &&  ...
strcmpi( maskVarTypes{ i }{ 1 }, '@' )


wordsInExpr = getVarAndFuncNames( maskValues{ i } );


if ~isempty( wordsInExpr ) && ismember( wordsInExpr, this.Name )
val( end  + 1 ) = maskValues{ i };%#ok<AGROW>
end 
end 
end 
end 

end 
end 
end 
end 
end 

function dParams = getEvaluatedBlockParams( blk )
blkType = mlreportgen.utils.safeGet( blk, 'blocktype', 'get_param' );
dParams = cell.empty;
if ~ismember( blkType, { 'Scope', 'ToWorkspace', 'ToFile', 'Display', '', 'N/A' } )

paramStruct = get_param( blk, 'intrinsicdialogparameters' );
if isstruct( paramStruct )
pNames = fieldnames( paramStruct );
evalDialogParams = cell.empty;


for j = 1:length( pNames )
pInfo = paramStruct.( pNames{ j } );
if strcmp( pInfo.Type, 'string' ) ...
 && ~any( strcmp( pInfo.Attributes, 'dont-eval' ) )
evalDialogParams{ end  + 1 } = pNames{ j };%#ok<AGROW>
end 
end 
dParams = evalDialogParams;
end 
end 
end 


function allWords = getVarAndFuncNames( valStr )
allWords = cell.empty;

if ~isempty( valStr )

validVarNamePattern = asManyOfPattern( alphanumericsPattern | "_" | "." );
valStr = extract( valStr, validVarNamePattern );

invalidStartPattern = digitsPattern( 1 ) | ".";
for i = 1:length( valStr )
wordToken = valStr{ i };

if ~isempty( wordToken ) && ~startsWith( wordToken, invalidStartPattern )
if contains( wordToken, "." )
wordToken = extractBefore( wordToken, "." );
end 
allWords{ end  + 1, 1 } = wordToken;%#ok<AGROW>
end 
end 
end 

allWords = unique( allWords );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpK3AwsS.p.
% Please follow local copyright laws when handling this file.

