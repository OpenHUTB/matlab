





classdef cvdata < cv.internal.cvdata

properties ( GetAccess = public, SetAccess = protected, Hidden )


id( 1, 1 ){ mustBeNumeric } = 0
end 

properties ( GetAccess = public, SetAccess = protected, Hidden )
dbVersion( 1, : )char = SlCov.CoverageAPI.getDbVersion(  )
end 

properties ( GetAccess = public, SetAccess = protected )
test cv.coder.cvtest{ mustBeScalarOrEmpty } = cv.coder.cvtest.empty(  )
end 

properties ( GetAccess = public, SetAccess = private, Dependent = true )
simMode( 1, 1 )SlCov.CovMode
startTime( 1, : )char
stopTime( 1, : )char
moduleinfo( 1, 1 )struct
checksum( 1, 1 )struct
end 

properties ( GetAccess = public, SetAccess = private, Dependent = true, Hidden )
uniqueId( 1, : )char
end 

properties ( GetAccess = public, SetAccess = public )
filter( 1, : )string
end 

properties ( GetAccess = public, SetAccess = public, Hidden = true )
description( 1, : )char = ''
tag( 1, : )char = ''
testRunInfo struct{ mustBeScalarOrEmpty }
aggregatedTestInfo struct
traceOn( 1, 1 )logical = true
aggregatedIds( 1, : )string
filterApplied( 1, : )string
filterAppliedStruct struct
filterData
end 

properties ( GetAccess = public, SetAccess = public, Hidden = true, Transient = true )
rptCtxInfo( 1, 1 )struct
end 

properties ( GetAccess = public, SetAccess = public, SetObservable = true, Hidden = true )
codeCovData SlCov.results.CodeCovData{ mustBeScalarOrEmpty } = SlCov.results.CodeCovData.empty(  )
end 

properties ( GetAccess = public, SetAccess = private, Dependent = true, Hidden = true )
testSettings
end 

properties ( GetAccess = protected, SetAccess = protected )
isDerivedData( 1, 1 )logical = false
structuralChecksum
moduleInfo
isTmpObjForSave( 1, 1 )logical = false
end 

properties ( GetAccess = protected, SetAccess = protected, Transient = true )
ListenerHandle
end 

methods 



function this = cvdata( varargin )
if nargin == 1 && isa( varargin{ 1 }, 'cv.coder.cvdata' )
varargin{ 1 }.load(  );
this = varargin{ 1 };
elseif nargin > 0 && nargin <= 2 && ( ischar( varargin{ 1 } ) || isstring( varargin{ 1 } ) )
uuid = '';
if nargin == 2 && isstruct( varargin{ 2 } ) && isfield( varargin{ 2 }, 'uniqueId' )
srcCvd = varargin{ 2 };
uuid = srcCvd.uniqueId;
end 
fileName = convertStringsToChars( varargin{ 1 } );
this = cv.internal.cvdata.setupFileRef( this, fileName, uuid );
else 
for ii = 1:numel( varargin )
arg = varargin{ ii };
if isa( arg, 'SlCov.results.CodeCovData' ) && isempty( this.codeCovData )
this.codeCovData = arg;
elseif isa( arg, 'codeinstrum.internal.codecov.CodeCovData' ) && isempty( this.codeCovData )
this.codeCovData = SlCov.results.CodeCovData( arg );
elseif isa( arg, 'cv.coder.cvtest' )
cvt = arg.clone(  );
cvt.isLocked = true;
this.test = cvt;
else 
assert( false );
end 
end 
end 
if isempty( this.ListenerHandle )
this.ListenerHandle = addlistener( this, 'codeCovData', 'PostSet', @cv.coder.cvdata.codeCovDataChanged );
end 
end 




function delete( this )
if ~this.isTmpObjForSave
cv.coder.cvdatamgr.instance(  ).remove( this );
end 
end 




function value = get.startTime( this )
value = '';
if this.valid(  )
value = this.codeCovData.CodeCovDataImpl.CodeCovDataCore.startTime;
try 
value = datestr( datenum( value ) );
catch 
end 
end 
end 




function value = get.stopTime( this )
value = '';
if this.valid(  )
value = this.codeCovData.CodeCovDataImpl.CodeCovDataCore.endTime;
try 
value = datestr( datenum( value ) );
catch 
end 
end 
end 




function value = get.simMode( this )
value = SlCov.CovMode.Unknown;
if this.valid(  )
if endsWith( this.codeCovData.CodeCovDataImpl.Name, '_sil' )
value = SlCov.CovMode.SIL;
elseif endsWith( this.codeCovData.CodeCovDataImpl.Name, '_pil' )
value = SlCov.CovMode.PIL;
end 
end 
end 




function value = get.uniqueId( this )
value = '';
if this.valid(  )
value = this.codeCovData.CodeCovDataImpl.CodeCovDataCore.UUID;
end 
end 




function value = get.testSettings( this )
R36
this( 1, 1 )cv.coder.cvdata
end 
value = [  ];
if ~isempty( this.test )
value = this.test.settings;
end 
end 




function value = get.filter( this )
if isempty( this.filter )
value = '';
elseif numel( this.filter ) == 1
value = char( this.filter );
else 
value = cellstr( this.filter );
end 
end 




function set.filter( this, value )
this.filter = value;
this.loadAndApplyFilter(  );
end 




function value = get.filterApplied( this )
if isempty( this.filterApplied )
value = '';
elseif numel( this.filterApplied ) == 1
value = char( this.filterApplied );
else 
value = cellstr( this.filterApplied );
end 
end 




function value = get.checksum( this )
R36
this( 1, 1 )cv.coder.cvdata
end 
value = [  ];
if ~isempty( this.structuralChecksum )
value = this.structuralChecksum;
return 
end 
if this.valid(  )
try 
chk = this.codeCovData.CodeCovDataImpl.CodeTr.getChecksum(  );
chk = double( typecast( chk, 'uint32' ) );
value.u1 = chk( 1 );
value.u2 = chk( 2 );
value.u3 = chk( 3 );
value.u4 = chk( 4 );
catch 
end 
end 
this.structuralChecksum = value;
end 




function value = get.moduleinfo( this )
R36
this( 1, 1 )cv.coder.cvdata
end 
value = [  ];
if ~isempty( this.moduleInfo )
value = this.moduleInfo;
return 
end 
if this.valid(  )
name = codeinstrum.internal.codecov.ModuleUtils.parseModuleName( this.codeCovData.CodeCovDataImpl.Name );
value.name = name;
value.files = [  ];
files = this.codeCovData.CodeCovDataImpl.CodeTr.getFilesInResults(  );
for ii = 1:numel( files )
fileInfo.path = files( ii ).pathRelativeToSymbolicName;
fileInfo.lastModifiedTime = files( ii ).lastModifiedTime;
fileInfo.fileSize = files( ii ).fileSize;
fileInfo.structuralChecksum = sprintf( '%02X', files( ii ).structuralChecksum.toArray(  ) );
value.files = [ value.files;fileInfo ];
end 
end 
this.moduleInfo = value;
end 




function set.testRunInfo( this, value )
R36
this( 1, 1 )cv.coder.cvdata
value
end 

if isstruct( value ) && ( numel( fieldnames( value ) ) == 0 )
value = [  ];
end 

assert( isempty( value ) ||  ...
( isstruct( value ) &&  ...
numel( value ) == 1 &&  ...
isfield( value, 'runName' ) &&  ...
isfield( value, 'testId' ) ) ...
 );

this.testRunInfo = value;

obj = this.codeCovData;%#ok<MCSUP>
if isa( obj, 'SlCov.results.CodeCovData' ) && obj.hasResults(  )
obj.setTestRunInfo( value );
end 
end 




function set.aggregatedTestInfo( this, value )
R36
this( 1, 1 )cv.coder.cvdata
value
end 

if isstruct( value ) && ( numel( fieldnames( value ) ) == 0 )
value = [  ];
end 

assert( isempty( value ) ||  ...
( isstruct( value ) &&  ...
numel( value ) >= 1 &&  ...
isfield( value( 1 ), 'uniqueId' ) && isfield( value( 1 ), 'analyzedModel' ) &&  ...
isfield( value( 1 ), 'description' ) && isfield( value( 1 ), 'date' ) &&  ...
isfield( value( 1 ), 'testRunInfo' ) && isstruct( value( 1 ).testRunInfo ) ) ...
 );

this.aggregatedTestInfo = value;

obj = this.codeCovData;%#ok<MCSUP>
if isa( obj, 'SlCov.results.CodeCovData' ) && obj.hasResults(  )
obj.setAggregatedTestInfo( value );
end 
end 




function set.codeCovData( this, obj )
R36
this( 1, 1 )cv.coder.cvdata
obj SlCov.results.CodeCovData{ mustBeScalarOrEmpty } = SlCov.results.CodeCovData.empty(  )
end 
this.codeCovData = obj;
cv.coder.cvdatamgr.instance(  ).addOrUpdate( this );
end 

function set.test( this, value )
if isempty( this.test )
this.test = value;
end 
end 




function cvd = saveobj( this )
if ~isempty( this.ListenerHandle )
cvd = this.clone(  );
cvd.isTmpObjForSave = true;


cv.coder.cvdatamgr.instance(  ).remove( cvd );
else 
cvd = this;
end 
end 

r = minus( p, q )
r = mtimes( p, q )
r = plus( p, q )
r = times( p, q )
display( this )
end 

methods ( Hidden )



function out = getAnalyzedModel( this )
if this.valid(  )
out = this.moduleinfo.name;
else 
out = '';
end 
end 




function copyTo( this, cvd )
R36
this( 1, 1 )cv.coder.cvdata
cvd( 1, 1 )cv.coder.cvdata
end 
mCls = metaclass( this );
for ii = 1:numel( mCls.PropertyList )
prop = mCls.PropertyList( ii );
if prop.Name == "ListenerHandle"
continue 
end 
if prop.Dependent || prop.Constant || prop.Abstract || prop.NonCopyable
continue 
end 
cvd.( prop.Name ) = this.( prop.Name );
end 
end 




function outObj = clone( this, varargin )
if nargin == 2 && isa( varargin{ 1 }, 'cv.coder.cvdata' )
outObj = varargin{ 1 };
else 
outObj = cv.coder.cvdata(  );
end 
this.copyTo( outObj );
end 




function clearUniqueId( ~ )

end 




function setUniqueId( ~ )

end 




function checkId( this )%#ok<MANU>

end 




function result = isDerived( this )
result = this.isDerivedData;
end 




function load( this )
if this.isLoaded
return 
end 
cvd = cv.coder.cvdata.loadFileRef( this );
cvd.copyTo( this );
this.isLoaded = true;
end 




function value = valid( this )




if ~this.isLoaded
this.load(  );
end 
value = ~isempty( this.codeCovData );
end 




function value = isCompatible( this, cvd )%#ok<INUSD>

value = [  ];
end 




function [ enabled, enabledTO ] = getEnabledMetricNames( this )
enabled = {  };
enabledTO = {  };
if this.valid(  )
metrics = this.codeCovData.CodeCovDataImpl.CodeCovDataCore.metrics.toArray(  );
for ii = 1:numel( metrics )
switch metrics( ii )
case internal.cxxfe.instrum.MetricKind.DECISION
enabled{ end  + 1 } = 'decision';%#ok<AGROW>
case internal.cxxfe.instrum.MetricKind.CONDITION
enabled{ end  + 1 } = 'condition';%#ok<AGROW>
case internal.cxxfe.instrum.MetricKind.MCDC
enabled{ end  + 1 } = 'mcdc';%#ok<AGROW>
case internal.cxxfe.instrum.MetricKind.RELATIONAL_BOUNDARY
enabledTO{ end  + 1 } = 'cvmetric_Structural_relationalop';%#ok<AGROW>
otherwise 
end 
end 
end 
end 

this = createDerivedData( this, lhs, rhs, op );
status = applyFilter( this, fileName )
status = loadAndApplyFilter( this )
end 

methods ( Static )



function obj = loadobj( this )
if isa( this, 'cv.coder.cvdata' ) && this.valid(  )
obj = this;
if isempty( obj.ListenerHandle )
obj.ListenerHandle = addlistener( obj, 'codeCovData', 'PostSet', @cv.coder.cvdata.codeCovDataChanged );
end 
return 
end 
obj = cv.coder.cvdata(  );
mCls = metaclass( obj );
for ii = 1:numel( mCls.PropertyList )
prop = mCls.PropertyList( ii );
if prop.Name == "ListenerHandle"
continue 
end 
if ~isprop( this, prop.Name ) && ~isfield( this, prop.Name )
continue 
end 
if prop.Dependent || prop.Constant ||  ...
prop.Abstract || prop.NonCopyable ||  ...
prop.Transient
continue 
end 
obj.( prop.Name ) = this.( prop.Name );
end 
end 
end 

methods ( Static, Hidden )



function cvd = loadFileRef( obj )
cvd = [  ];
if ~obj.isLoaded
obj.isLoaded = true;
cv.internal.cvdata.checkFileRef( obj );
[ ~, d ] = cvload( obj.fileRef.name );
if isempty( d )
throwAsCaller( MException( message( 'Slvnv:simcoverage:cvdata:InvalidCvDataNoObj' ) ) );
end 
cvd = d{ 1 };
end 
end 
end 

methods ( Static, Access = protected )



function codeCovDataChanged( prop, evt, varargin )%#ok<INUSL>
evt.AffectedObject.structuralChecksum = [  ];
evt.AffectedObject.moduleInfo = [  ];
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpjySyqt.p.
% Please follow local copyright laws when handling this file.

