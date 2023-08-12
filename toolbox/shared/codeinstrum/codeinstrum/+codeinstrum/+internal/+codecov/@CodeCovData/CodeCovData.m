classdef ( Hidden = true )CodeCovData < matlab.mixin.Copyable










properties ( SetAccess = protected, GetAccess = public, Hidden = true )
CodeCovDataImpl

OrigModuleName


HtmlFiles = {  }

FilterCtx
end 

properties ( SetAccess = protected, GetAccess = public, Hidden = true, Dependent = true )
Name
McdcMode
end 

properties ( SetAccess = public, GetAccess = public, Hidden = true, Dependent = true )
Description
end 

properties ( SetAccess = private, GetAccess = public, Hidden = true, Dependent = true )
CodeTr
AggregatedTestInfo
end 

methods 




function this = CodeCovData( varargin )
funName = 'codeinstrum.internal.codecov.CodeCovData';


if nargin == 1
other = varargin{ 1 };
validateattributes( other, { funName }, { 'scalar' }, funName );
this.CodeCovDataImpl = other.CodeCovDataImpl;
this.OrigModuleName = other.OrigModuleName;
this.HtmlFiles = other.HtmlFiles;
this.FilterCtx = other.FilterCtx;
return 
end 


narginchk( 2, 24 );
opt = parseArgs( varargin );


if isempty( opt.traceabilityData )

if isempty( opt.traceabilityDbFilePath )
this.CodeCovDataImpl = internal.codecov.CodeCovData( internal.cxxfe.instrum.TraceabilityData.empty );
return 
else 
if exist( opt.traceabilityDbFilePath, 'file' ) ~= 2
error( message( 'CodeInstrumentation:utils:openForReadingError', opt.traceabilityDbFilePath, '' ) );
end 
end 

traceabilityDataObj = codeinstrum.internal.TraceabilityData( opt.traceabilityDbFilePath, opt.moduleName );
else 
traceabilityDataObj = opt.traceabilityData;
end 

this.CodeCovDataImpl = internal.codecov.CodeCovData( traceabilityDataObj );

this.Name = opt.name;
if iscell( opt.metricNames )
this.CodeCovDataImpl.setMetrics( opt.metricNames );
end 
this.McdcMode = opt.mcdcMode;
isInstanceBased = ( numel( opt.resHitsFilePath ) == numel( opt.instances ) );
this.CodeCovDataImpl.setResults( opt.resHitsFilePath, isInstanceBased, opt.forceNonEmptyResults );
if isInstanceBased
for ii = 1:numel( opt.instances )
res = this.getInstanceResults( ii );
if isfield( opt.instances, 'SID' )
sid = opt.instances( ii ).SID;
else 
sid = '';
end 
res.createIntoInstance( struct( 'metaClass', 'internal.codecov.InstanceInfo',  ...
'sid', sid,  ...
'name', opt.instances( ii ).name ) );
end 
end 




this.OrigModuleName = opt.origModuleName;


if ~isempty( opt.entryPointFunSigs )
this.addExclusion( opt.entryPointFunSigs );
end 

if isempty( opt.traceabilityData )
traceabilityDataObj.close(  );
end 

function opt = parseArgs( argv )
opt.traceabilityData = [  ];
opt.traceabilityDbFilePath = '';
opt.moduleName = '';
opt.name = '';
opt.resHitsFilePath = {  };
opt.instances = [  ];
opt.metricNames = [  ];
opt.mcdcMode = 'UniqueCause';
opt.forceNonEmptyResults = false;
opt.origModuleName = '';
opt.entryPointFunSigs = {  };

argc = numel( argv );
argvIn = 1;
while argvIn <= argc
arg = argv{ argvIn };
if ~ischar( arg )
error( message( 'MATLAB:InputParser:NameMustBeChar' ) );
end 
argvIn = argvIn + 1;
if argvIn > argc
error( message( 'MATLAB:InputParser:ParamMissingValue', arg ) );
end 
val = argv{ argvIn };
switch lower( strtrim( arg ) )
case 'forcenonemptyresults'
validateattributes( val, { 'numeric', 'logical' }, { 'scalar' }, funName, arg, argvIn );
opt.forceNonEmptyResults = logical( val );
case 'traceabilitydata'
if ~isempty( val )
validateattributes( val, { 'codeinstrum.internal.TraceabilityData' }, { 'scalar' }, funName, arg, argvIn );
end 
opt.traceabilityData = val;
case 'traceabilitydbfile'
if ~isempty( val )
validateattributes( val, { 'char' }, { 'row' }, funName, arg, argvIn );
end 
opt.traceabilityDbFilePath = strtrim( val );
case 'modulename'
if ~isempty( val )
validateattributes( val, { 'char' }, { 'row' }, funName, arg, argvIn );
end 
opt.moduleName = strtrim( val );
case 'origmodulename'
if ~isempty( val )
validateattributes( val, { 'char' }, { 'row' }, funName, arg, argvIn );
end 
opt.origModuleName = strtrim( val );
case 'name'
if ~isempty( val )
validateattributes( val, { 'char' }, { 'row' }, funName, arg, argvIn );
end 
opt.name = strtrim( val );
case 'reshitsfile'
if ~isempty( val )
validateattributes( val, { 'char' }, { 'row' }, funName, arg, argvIn );
end 
opt.resHitsFilePath = { strtrim( val ) };
case 'instances'
validateattributes( val, { 'struct' }, { 'vector' }, funName, arg, argvIn );
if isfield( val, 'resHitsFile' )
if ~isempty( opt.resHitsFilePath )
assert( isempty( opt.traceabilityDbFilePath ) &&  ...
isempty( opt.traceabilityData ) && ( numel( opt.resHitsFilePath ) == 1 ) );
opt.traceabilityDbFilePath = opt.resHitsFilePath{ 1 };
end 
opt.resHitsFilePath = { val.resHitsFile };
val = rmfield( val, 'resHitsFile' );
end 
opt.instances = val;
case 'metricnames'
if ~isempty( val )
validateattributes( val, { 'cell' }, { 'vector' }, funName, arg, argvIn );
end 
opt.metricNames = val;
case 'mcdcmode'
if ~isempty( val )
if ischar( val ) || isstring( val )
validateattributes( val, { 'char', 'string' }, { 'scalartext' }, funName, arg, argvIn );
else 
validateattributes( val, { 'SlCov.McdcMode', 'numeric' }, { 'scalar' }, funName, arg, argvIn );
end 
opt.mcdcMode = char( SlCov.McdcMode( val ) );
end 
case 'entrypointfunsigs'
if ~isempty( val ) && iscell( val )
opt.entryPointFunSigs = val;
end 
otherwise 
error( message( 'MATLAB:InputParser:UnmatchedParameter', arg, '' ) );
end 
argvIn = argvIn + 1;
end 

if isempty( opt.traceabilityDbFilePath ) && isempty( opt.traceabilityData ) && ~isempty( opt.resHitsFilePath )
assert( numel( opt.resHitsFilePath ) == 1 );
opt.traceabilityDbFilePath = opt.resHitsFilePath{ 1 };
end 

if ~isempty( opt.traceabilityData ) && isempty( opt.moduleName )
opt.moduleName = opt.traceabilityData.moduleName;
end 

if isempty( opt.name )
opt.name = opt.moduleName;
end 
end 
end 

function CodeTr = get.CodeTr( this )
CodeTr = this.CodeCovDataImpl.CodeTr;
end 

function set.Name( this, v )
this.CodeCovDataImpl.Name = v;
end 

function v = get.Name( this )
v = this.CodeCovDataImpl.Name;
end 

function set.McdcMode( this, v )
switch v
case 'UniqueCause'
this.CodeCovDataImpl.MCDCMode = internal.codecov.MCDCMode.UNIQUE_CAUSE;
otherwise 
this.CodeCovDataImpl.MCDCMode = internal.codecov.MCDCMode.MASKING;
end 
end 

function v = get.McdcMode( this )
switch this.CodeCovDataImpl.MCDCMode
case internal.codecov.MCDCMode.UNIQUE_CAUSE
v = 'UniqueCause';
case internal.codecov.MCDCMode.MASKING
v = 'Masking';
otherwise 
assert( false );
end 
end 

function set.Description( this, v )
this.CodeCovDataImpl.Description = v;
if this.CodeCovDataImpl.CodeCovDataCore.tests.Size(  ) == 1
testInfo = this.CodeCovDataImpl.CodeCovDataCore.tests( 1 );
testInfo.description = v;
end 
end 

function v = get.Description( this )
v = this.CodeCovDataImpl.Description;
end 

function v = get.AggregatedTestInfo( this )
v = codeinstrum.internal.codecov.CodeCovData.genAggregatedTestInfoStructure( this.CodeCovDataImpl.CodeCovDataCore.tests );
end 




function resObj = clone( this, skipResults )
if nargin < 2
skipResults = false;
end 

resObj = copy( this );

if skipResults
resObj.CodeCovDataImpl.CodeCovDataCore.instancesResults.clear(  );
resObj.CodeCovDataImpl.resetStats(  );
end 
end 





function state = hasResults( this )
state = ~isempty( this ) && ~isempty( this.CodeTr ) &&  ...
( this.getNumResults(  ) ~= 0 );
end 




function res = getNumTests( this )
res = this.CodeCovDataImpl.CodeCovDataCore.tests.Size(  );
end 




function res = isActive( this, metricKind )
res = this.CodeCovDataImpl.isActive( metricKind );
end 




function res = getNumInstances( this )
res = this.CodeCovDataImpl.getNumInstances(  );
end 




function res = getNumResults( this )
res = this.CodeCovDataImpl.getNumResults(  );
end 




function res = getInstanceSIDs( this )
res = this.CodeCovDataImpl.getInstanceSIDs(  );
end 




function res = getInstanceResults( this, instIdx )
if ischar( instIdx )
nameRslt = instIdx;
instInfo = this.getInstanceSIDs(  );
instIdx = find( strcmp( instInfo, instIdx ), 1 );
if isempty( instIdx )
error( message( 'MATLAB:InputParser:failedWithError', 'instIdx', nameRslt ) );
end 
end 
res = this.CodeCovDataImpl.getInstanceResults( instIdx );
end 




function res = getAggregatedResults( this )
res = this.CodeCovDataImpl.getAggregatedResults(  );
end 




function state = hasMetricsResults( this )
codeTr = this.CodeTr;
state = this.hasResults(  ) &&  ...
( ( this.isActive( internal.cxxfe.instrum.MetricKind.DECISION ) &&  ...
~isempty( codeTr.getDecisionPoints( codeTr.Root ) ) ) ||  ...
( this.isActive( internal.cxxfe.instrum.MetricKind.CONDITION ) &&  ...
~isempty( codeTr.getConditionPoints( codeTr.Root ) ) ) ||  ...
( this.isActive( internal.cxxfe.instrum.MetricKind.MCDC ) &&  ...
~isempty( codeTr.getMCDCPoints( codeTr.Root ) ) ) ||  ...
( this.isActive( internal.cxxfe.instrum.MetricKind.STATEMENT ) &&  ...
~isempty( codeTr.getStatementPoints( codeTr.Root ) ) ) ||  ...
( this.isActive( internal.cxxfe.instrum.MetricKind.FUN_CALL ) &&  ...
~isempty( codeTr.getCallPoints( codeTr.Root ) ) ) ||  ...
( this.isActive( internal.cxxfe.instrum.MetricKind.FUN_ENTRY ) &&  ...
~isempty( codeTr.getFunEntryPoints( codeTr.Root ) ) ) ||  ...
( this.isActive( internal.cxxfe.instrum.MetricKind.FUN_EXIT ) &&  ...
~isempty( codeTr.getFunExitPoints( codeTr.Root ) ) ) ||  ...
( this.isActive( internal.cxxfe.instrum.MetricKind.RELATIONAL_BOUNDARY ) &&  ...
~isempty( codeTr.getRelationalBoundaryPoints( codeTr.Root ) ) ) );
end 




function resObj = plus( resObj1, resObj2 )
resObj = codeinstrum.internal.codecov.CodeCovData.performOp( resObj1, resObj2, '+' );
end 




function resObj = minus( resObj1, resObj2 )
resObj = codeinstrum.internal.codecov.CodeCovData.performOp( resObj1, resObj2, '-' );
end 




function resObj = times( resObj1, resObj2 )
resObj = codeinstrum.internal.codecov.CodeCovData.performOp( resObj1, resObj2, '*' );
end 




function resObj = mtimes( resObj1, resObj2 )
resObj = codeinstrum.internal.codecov.CodeCovData.performOp( resObj1, resObj2, '*' );
end 




function resObj = extractInstance( resObj, instIdx )
resObj = resObj.clone(  );
cvdIntern = resObj.CodeCovDataImpl.extractInstance( instIdx );
assert( ~isempty( cvdIntern ) );
resObj.CodeCovDataImpl = cvdIntern;
if numel( resObj.HtmlFiles ) >= instIdx
resObj.HtmlFiles = resObj.HtmlFiles( instIdx );
else 
resObj.HtmlFiles = {  };
end 
end 




function res = saveobj( this )
res = copy( this );
jsonStr = res.CodeCovDataImpl.serializeToJSON(  );
res.CodeCovDataImpl = polyspace.internal.gzip.gzipString( jsonStr, true );
end 




function setFilterCtx( this, filterCtx )
this.FilterCtx = filterCtx;
end 




function filterCtx = getFilterCtx( this )
filterCtx = this.FilterCtx;
end 




function setTestRunInfo( this, value )
assert( isempty( value ) ||  ...
( isstruct( value ) &&  ...
numel( value ) == 1 &&  ...
isfield( value, 'runName' ) &&  ...
isfield( value, 'testId' ) ) ...
 );

if this.CodeCovDataImpl.CodeCovDataCore.tests.Size(  ) == 0
md5Eng = matlab.internal.crypto.BasicDigester( 'DeprecatedMD5' );
md5Eng.addData( getByteStreamFromArray( this ) );
digest = md5Eng.computeDigestFinalAndReset(  );
checksum = [  ...
prod( uint32( digest( 1:4 ) ) ); ...
prod( uint32( digest( 5:8 ) ) ); ...
prod( uint32( digest( 9:12 ) ) ); ...
prod( uint32( digest( 13:16 ) ) ) ...
 ];
testInfo = struct(  ...
'uniqueId', char( strjoin( string( checksum ), '-' ) ),  ...
'analyzedModel', this.Name,  ...
'description', this.Description,  ...
'date', this.CodeCovDataImpl.CodeCovDataCore.startTime,  ...
'testRunInfo', value );
this.setAggregatedTestInfo( testInfo );
end 
end 




function setAggregatedTestInfo( this, value )
if codeinstrumprivate( 'feature', 'enableAggregatedTestInfo' )
assert( isempty( value ) ||  ...
( isstruct( value ) &&  ...
numel( value ) >= 1 &&  ...
isfield( value( 1 ), 'uniqueId' ) && isfield( value( 1 ), 'analyzedModel' ) &&  ...
isfield( value( 1 ), 'description' ) && isfield( value( 1 ), 'date' ) &&  ...
isfield( value( 1 ), 'testRunInfo' ) && isstruct( value( 1 ).testRunInfo ) ) ...
 );
this.CodeCovDataImpl.setAggregatedTestInfo( value );
end 
end 




function resetFilters( this )
this.CodeCovDataImpl.resetFilters(  );
end 




function annotateAllFiles( this, isFilter, rationale, instIdx )
if nargin < 4
instIdx = 1;
elseif ischar( instIdx )
nameRslt = instIdx;
instInfo = this.getInstanceSIDs(  );
instIdx = find( strcmp( instInfo, instIdx ), 1 );
if isempty( instIdx )
error( message( 'MATLAB:InputParser:failedWithError', 'instIdx', nameRslt ) );
end 
end 
if nargin < 3
rationale = '';
end 
if nargin < 2
isFilter = true;
else 
isFilter = logical( isFilter );
end 

kind = internal.codecov.FilterKind.GLOBAL;
this.insertAnnotation( instIdx, this.CodeTr.Root, kind, isFilter, rationale );
end 




function annotateFile( this, isFilter, rationale, fileName, instIdx )
if nargin < 5
instIdx = 1;
elseif ischar( instIdx )
nameRslt = instIdx;
instInfo = this.getInstanceSIDs(  );
instIdx = find( strcmp( instInfo, instIdx ), 1 );
if isempty( instIdx )
error( message( 'MATLAB:InputParser:failedWithError', 'instIdx', nameRslt ) );
end 
end 

file = this.CodeTr.findFile( fileName );
kind = internal.codecov.FilterKind.FILE;
for ii = 1:numel( file )
this.insertAnnotation( instIdx, file( ii ), kind, isFilter, rationale );
end 
end 




function annotateFunction( this, isFilter, rationale, fileName, funName, instIdx )
if nargin < 6
instIdx = 1;
elseif ischar( instIdx )
nameRslt = instIdx;
instInfo = this.getInstanceSIDs(  );
instIdx = find( strcmp( instInfo, instIdx ), 1 );
if isempty( instIdx )
error( message( 'MATLAB:InputParser:failedWithError', 'instIdx', nameRslt ) );
end 
end 

kind = internal.codecov.FilterKind.FUNCTION;
fcns = this.CodeTr.findFunction( fileName, funName );
for ii = 1:numel( fcns )
this.insertAnnotation( instIdx, fcns( ii ), kind, isFilter, rationale );
end 
end 









































function annotateExpression( this, isFilter, rationale, fileName, funName, expr, exprIdx, cvMetricType, instIdx )
if nargin < 9
instIdx = 1;
elseif ischar( instIdx )
nameRslt = instIdx;
instInfo = this.getInstanceSIDs(  );
instIdx = find( strcmp( instInfo, instIdx ), 1 );
if isempty( instIdx )
error( message( 'MATLAB:InputParser:failedWithError', 'instIdx', nameRslt ) );
end 
end 

fcns = this.CodeTr.findFunction( fileName, funName );


outcomeIdx = [  ];
extraIdx = [  ];
if numel( exprIdx ) >= 2
outcomeIdx = exprIdx( 2 );
if numel( exprIdx ) == 3
extraIdx = exprIdx( 3 );
end 
exprIdx = exprIdx( 1 );
end 


if ~codeinstrumprivate( 'feature', 'enableOutcomeFilters' )
if ~isempty( outcomeIdx ) || ( cvMetricType == 2 ) || ( cvMetricType == 3 )
return 
end 
end 



if isempty( outcomeIdx ) && ( cvMetricType == 2 || cvMetricType == 3 )
return 
end 


compExprFcn = @( curr, ref )strcmp( curr, ref ) ||  ...
strcmp( regexprep( curr, '\s', '' ), regexprep( ref, '\s', '' ) );


foundExpr = '';

for ii = 1:numel( fcns )
fcn = fcns( ii );
decCovPts = this.CodeTr.getDecisionPoints( fcn );


switch cvMetricType
case 1

decIdx = exprIdx;


if numel( decCovPts ) < decIdx
return 
end 
decCovPt = decCovPts( decIdx );
foundExpr = decCovPt.getSourceCode(  );

if isempty( outcomeIdx )
kind = internal.codecov.FilterKind.DECISION;
relevantObj = decCovPt;
else 

if ( outcomeIdx < 1 ) || ( decCovPt.outcomes.Size(  ) < outcomeIdx )
return 
end 
kind = internal.codecov.FilterKind.DECISION_OUTCOME;
relevantObj = decCovPt.outcomes( outcomeIdx );
end 
case 0

condIdx = exprIdx;


if isempty( outcomeIdx )
kind = internal.codecov.FilterKind.CONDITION;
else 
if outcomeIdx < 1 || outcomeIdx > 2
return 
end 
kind = internal.codecov.FilterKind.CONDITION_OUTCOME;
end 

if isempty( extraIdx )

condCovPts = this.CodeTr.getStandaloneConditionPoints( fcn );
if numel( condCovPts ) < condIdx
return 
end 
condCovPt = condCovPts( condIdx );
foundExpr = condCovPt.getSourceCode(  );
else 

decIdx = extraIdx;
if numel( decCovPts ) < decIdx
return 
end 
decCovPt = decCovPts( decIdx );


if decCovPt.subConditions.Size(  ) < condIdx
return 
end 
condCovPt = decCovPt.subConditions( condIdx );
foundExpr = decCovPt.getSourceCode(  );
end 
if kind == internal.codecov.FilterKind.CONDITION_OUTCOME
relevantObj = condCovPt.outcomes( outcomeIdx );
else 
relevantObj = condCovPt;
end 
case 2

decIdx = exprIdx;

kind = internal.codecov.FilterKind.MCDC_OUTCOME;

if numel( decCovPts ) < decIdx
return 
end 
decCovPt = decCovPts( decIdx );
mcdcCovPt = decCovPt.mcdc;


if mcdcCovPt.outcomes.Size(  ) < outcomeIdx
return 
end 
relevantObj = mcdcCovPt.outcomes( outcomeIdx );
foundExpr = decCovPt.getSourceCode(  );
case 3
kind = internal.codecov.FilterKind.RELBOUND_OUTCOME;
parentCovPt = [  ];
if isempty( extraIdx )




decIdx = exprIdx;
if numel( decCovPts ) >= decIdx
decCovPt = decCovPts( decIdx );
foundExpr = decCovPt.getSourceCode(  );
if compExprFcn( foundExpr, expr )
parentCovPt = decCovPt;


if decCovPt.subConditions.Size(  ) > 1
return 
end 
end 
end 



if isempty( parentCovPt )

condIdx = exprIdx;

condCovPts = this.CodeTr.getStandaloneConditionPoints( fcn );
if numel( condCovPts ) >= condIdx
condCovPt = condCovPts( condIdx );
foundExpr = condCovPt.getSourceCode(  );
if ~compExprFcn( foundExpr, expr )
return 
end 
parentCovPt = condCovPt;
end 
end 


if isempty( parentCovPt )
return 
end 
else 



decIdx = exprIdx;
condIdx = extraIdx;


if numel( decCovPts ) < decIdx
return 
end 

decCovPt = decCovPts( decIdx );
if decCovPt.subConditions.Size(  ) < condIdx
return 
end 
foundExpr = decCovPt.getSourceCode(  );
condCovPt = decCovPt.subConditions( condIdx );
parentCovPt = condCovPt;
end 


relOpCovPt = parentCovPt.relationalOp;
if isempty( relOpCovPt )
return 
end 
if outcomeIdx > relOpCovPt.outcomes.Size(  )
return 
end 
relevantObj = relOpCovPt.outcomes( outcomeIdx );
otherwise 
return 
end 


if ~compExprFcn( foundExpr, expr )
return 
end 


this.insertAnnotation( instIdx, relevantObj, kind, isFilter, rationale );
end 
end 




function setHtmlFile( this, instIdx, htmlFile )
narginchk( 2, 3 );
if nargin < 3
htmlFile = [  ];
end 
validateattributes( instIdx, { 'numeric' }, { 'scalar' }, 'setHtmlFile', 'instIdx', 2 );
if ~isempty( htmlFile )
validateattributes( htmlFile, { 'char' }, { 'vector', 'nrows', 1 }, 'setHtmlFile', 'htmlFile', 3 );
end 
if instIdx <= this.getNumInstances(  )
if isempty( this.HtmlFiles )
this.HtmlFiles = cell( 1, this.getNumInstances(  ) );
end 
this.HtmlFiles{ instIdx } = htmlFile;
end 
end 




function htmlFile = getHtmlFile( this, instIdx )
narginchk( 2, 2 );
validateattributes( instIdx, { 'numeric' }, { 'scalar' }, 'getHtmlFile', 'instIdx', 2 );
if ( instIdx <= numel( this.HtmlFiles ) ) && ~isempty( this.HtmlFiles{ instIdx } )
htmlFile = this.HtmlFiles{ instIdx };
else 
htmlFile = '';
end 
end 


removeUncoveredFunctionsData( this )
res = toStruct( this, idx )
end 

methods ( Hidden = true )
function resetResults( this )
this.CodeCovDataImpl.resetStats(  );
end 


objs = findSourceLoc( this, fileName, fcnName )
end 

methods ( Access = protected )



function resObj = copyElement( this )
resObj = copyElement@matlab.mixin.Copyable( this );
resObj.CodeCovDataImpl = this.CodeCovDataImpl.copy(  );
end 


addExclusion( this, funSigs )




function insertAnnotation( this, instIdx, obj, kind, isFilter, rationale )


if isempty( rationale )
rationale = '';
end 

numInstances = this.getNumInstances(  );

if instIdx <  - 1
instIdx = 1:numInstances;
end 

if isFilter
filterMode = internal.codecov.FilterMode.EXCLUDED;
else 
filterMode = internal.codecov.FilterMode.JUSTIFIED;
end 

for ii = instIdx( : )'
this.CodeCovDataImpl.addFilter( ii,  ...
kind,  ...
internal.codecov.FilterSource.USER,  ...
filterMode, rationale, obj );
end 
end 
end 

methods ( Static = true, Hidden = true )



importCodeTrAndResultsStructs( obj, loadedObj );





function obj = loadobjFromImpl( implObj, className )
R36
implObj( 1, 1 )internal.codecov.CodeCovData
className( 1, : )char = 'codeinstrum.internal.codecov.CodeCovData'
end 
obj = feval( className, 'traceabilityDbFile', '' );
obj.CodeCovDataImpl = implObj;
end 
end 

methods ( Static = true )




function clear(  )
internal.codecov.CodeCovData.clearCodeTrRegistry(  );
end 




function obj = loadobj( this, obj )
if isstruct( this )

if nargin < 2
obj = codeinstrum.internal.codecov.CodeCovData( 'traceabilityDbFile', '' );
end 


codeinstrum.internal.codecov.CodeCovData.importCodeTrAndResultsStructs( obj, this );

fieldNames = { 'OrigModuleName', 'FilterCtx', 'HtmlFiles' };
for ii = 1:numel( fieldNames )
fldName = fieldNames{ ii };
if isfield( this, fldName )
obj.( fldName ) = this.( fldName );
end 
end 
else 
obj = this;
codeCovDataImpl = internal.codecov.CodeCovData( internal.cxxfe.instrum.TraceabilityData.empty );
if isa( obj.CodeCovDataImpl, 'int8' )
jsonStr = polyspace.internal.gzip.gunzipString( obj.CodeCovDataImpl, true );
else 
jsonStr = obj.CodeCovDataImpl;
end 
codeCovDataImpl.parseJSONString( jsonStr );
obj.CodeCovDataImpl = codeCovDataImpl;
end 
end 




function varargout = getComplexityInfo( covData, varargin )
narginchk( 1, 3 );
nargoutchk( 0, 1 );
[ varargout{ 1:nargout } ] = codeinstrum.internal.codecov.CodeCovData.getCoverageInfo(  ...
covData, "complexity", varargin{ : } );
end 




function varargout = getDecisionInfo( covData, varargin )
narginchk( 1, 3 );
nargoutchk( 0, 2 );
[ varargout{ 1:nargout } ] = codeinstrum.internal.codecov.CodeCovData.getCoverageInfo(  ...
covData, "decision", varargin{ : } );
end 




function varargout = getConditionInfo( covData, varargin )
narginchk( 1, 3 );
nargoutchk( 0, 2 );
[ varargout{ 1:nargout } ] = codeinstrum.internal.codecov.CodeCovData.getCoverageInfo(  ...
covData, "condition", varargin{ : } );
end 




function varargout = getMcdcInfo( covData, varargin )
narginchk( 1, 3 );
nargoutchk( 0, 2 );
[ varargout{ 1:nargout } ] = codeinstrum.internal.codecov.CodeCovData.getCoverageInfo(  ...
covData, "mcdc", varargin{ : } );
end 




function varargout = getExecutionInfo( covData, varargin )
narginchk( 1, 3 );
nargoutchk( 0, 2 );
[ varargout{ 1:nargout } ] = codeinstrum.internal.codecov.CodeCovData.getCoverageInfo(  ...
covData, "execution", varargin{ : } );
end 




function varargout = getRelationalBoundaryInfo( covData, varargin )
narginchk( 1, 3 );
nargoutchk( 0, 2 );
[ varargout{ 1:nargout } ] = codeinstrum.internal.codecov.CodeCovData.getCoverageInfo(  ...
covData, "relationalop", varargin{ : } );
end 




function varargout = getCoverageInfo( covData, metricName, fileName, funName )
R36
covData
metricName( 1, 1 )string{ mustBeMember( metricName,  ...
[ "decision", "condition", "mcdc", "execution", "relationalop", "complexity" ] ) }
fileName( 1, 1 )string = ""
funName( 1, 1 )string = ""
end 

fileName = char( fileName );
funName = char( funName );


if metricName == "execution"
metricName = "cvmetric_Structural_block";
elseif metricName == "relationalop"
metricName = "cvmetric_Structural_relationalop";
end 
metricName = char( metricName );

covDataLst = codeinstrum.internal.codecov.CodeCovData.empty;
if isa( covData, 'codeinstrum.internal.codecov.CodeCovDataGroup' )
covDataLst = covData.getAll( true );
elseif isa( covData, 'codeinstrum.internal.codecov.CodeCovData' )
covDataLst = covData;
end 

covDataFound = codeinstrum.internal.codecov.CodeCovData.empty;

if ~isempty( fileName ) || ( isa( covData, 'codeinstrum.internal.codecov.CodeCovData' ) && isempty( fileName ) && isempty( funName ) )
for ii = 1:numel( covDataLst )
objs = covDataLst( ii ).findSourceLoc( fileName, funName );
if ~isempty( objs )
covDataFound = covDataLst( ii );
break ;
end 
end 
if ~isempty( covDataFound )


[ hitNums, codeCovRes, justifiedHitNums ] = codeinstrum.internal.codecov.CodeCovData.getCodeResInfoForMatchedSourceLoc(  ...
covDataFound, objs, metricName );

if isempty( hitNums )
varargout = cell( 1, nargout );
return 
else 
if metricName == "complexity"
hitNums = hitNums( 1 );
else 
hitNums( 1 ) = hitNums( 1 ) + justifiedHitNums;
end 
varargout{ 1 } = hitNums;
end 

if nargout == 2
varargout{ 2 } = cvi.ReportData.getCodeCoverageInfo( codeCovRes, metricName, justifiedHitNums );
end 
else 
varargout = cell( 1, nargout );
end 
else 
if isa( covData, 'codeinstrum.internal.codecov.CodeCovDataGroup' )
metricKind = codeinstrum.internal.codecov.CodeCovData.getCodeCovResStructInfoForMetric( metricName );
if isempty( metricKind )
varargout = cell( 1, nargout );
return 
end 
if metricKind == internal.cxxfe.instrum.MetricKind.CYCLO_CPLX
hitNums = int32( 0 );
for ii = 1:numel( covDataLst )
hitNums = hitNums + covDataLst( ii ).CodeTr.getCycloCplx( covDataLst( ii ).CodeTr.Root );
end 
varargout{ 1 } = double( hitNums );
else 
aggRslt = covData.getAggregatedResults(  );
if isempty( aggRslt )

varargout = cell( 1, nargout );
return ;
end 
oneMetricStat = aggRslt.getMetricStats( metricKind );
if oneMetricStat.metricKind == internal.cxxfe.instrum.MetricKind.UNKNOWN

varargout = cell( 1, nargout );
return 
end 
hitNums = double( [ oneMetricStat.numCovered, oneMetricStat.numNonExcluded ] );
justifiedHitNums = double( oneMetricStat.numJustifiedUncovered );
if hitNums( 2 ) < 1 && ~oneMetricStat.numTotal
varargout = cell( 1, nargout );
return 
end 
hitNums( 1 ) = hitNums( 1 ) + justifiedHitNums;
varargout{ 1 } = hitNums;
end 
else 

varargout = cell( 1, nargout );
end 
end 
end 




function execProfRslt = getProfilingResult( covData, metricName, fileName, funName )
R36
covData
metricName( 1, 1 )string{ mustBeMember( metricName,  ...
[ "execution_profiling", "stack_profiling" ] ) }
fileName( 1, 1 )string
funName( 1, 1 )string
end 

fileName = char( fileName );
funName = char( funName );

covDataLst = codeinstrum.internal.codecov.CodeCovData.empty;
if isa( covData, 'codeinstrum.internal.codecov.CodeCovDataGroup' )
covDataLst = covData.getAll( true );
elseif isa( covData, 'codeinstrum.internal.codecov.CodeCovData' )
covDataLst = covData;
end 

covDataFound = codeinstrum.internal.codecov.CodeCovData.empty;

for ii = 1:numel( covDataLst )
objs = covDataLst( ii ).findSourceLoc( fileName, funName );
if ~isempty( objs )
covDataFound = covDataLst( ii );
break ;
end 
end 
if ~isempty( covDataFound )
execProfRslt = cell( 1, numel( objs ) );
for ii = 1:numel( objs )
if metricName == "execution_profiling"
execProfRslt{ ii } = covDataFound.getAggregatedResults(  ).getExecutionProfilingResult( objs( ii ).getExecutionProfilingPoint(  ) );
else 

end 
end 
end 
end 



resObj = performOp( resObj1, resObj2, opKind, clsName )
htmlFiles = htmlReport( varargin )
end 

methods ( Static = true, Hidden = true )

[ hitNums, codeCovRes, justifiedHitNums ] =  ...
getCodeResInfoForMatchedSourceLoc( covRes, objs, metricName, resIdx )
metricKind = getCodeCovResStructInfoForMetric( metricName )


function res = genAggregatedTestInfoStructure( tests )
numTests = tests.Size(  );
res = struct( 'uniqueId', cell( 1, numTests ),  ...
'analyzedModel', cell( 1, numTests ),  ...
'description', cell( 1, numTests ),  ...
'date', cell( 1, numTests ),  ...
'testRunInfo', cell( 1, numTests ) );
for testIdx = 1:numTests
res( testIdx ).uniqueId = tests( testIdx ).uniqueId;
res( testIdx ).analyzedModel = tests( testIdx ).name;
res( testIdx ).description = tests( testIdx ).description;
res( testIdx ).date = tests( testIdx ).date;
if strcmp( tests( testIdx ).testRunInfo.context, 'ST' )

if isempty( tests( testIdx ).testRunInfo.runId )
res( testIdx ).testRunInfo = struct( 'runId', tests( testIdx ).testRunInfo.testId,  ...
'runName', tests( testIdx ).testRunInfo.runName );
else 
res( testIdx ).testRunInfo = struct( 'runId', tests( testIdx ).testRunInfo.testId,  ...
'runName', tests( testIdx ).testRunInfo.runName,  ...
'testId', tests( testIdx ).testRunInfo.runId );
end 
else 
testId = struct( 'uuid', tests( testIdx ).testRunInfo.testId,  ...
'contextType', tests( testIdx ).testRunInfo.context );
res( testIdx ).testRunInfo = struct( 'runId', str2double( tests( testIdx ).testRunInfo.runId ),  ...
'runName', tests( testIdx ).testRunInfo.runName,  ...
'testId', testId );
end 
end 
end 
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmprcRoFl.p.
% Please follow local copyright laws when handling this file.

