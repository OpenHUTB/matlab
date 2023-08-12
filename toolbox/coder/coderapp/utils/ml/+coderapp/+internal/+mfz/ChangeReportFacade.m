classdef ChangeReportFacade < handle



properties ( Hidden, SetAccess = immutable )
Report
end 

properties ( Dependent, SetAccess = immutable )
Created
CreatedUuids
Modified
ModifiedUuids
DestroyedUuids
end 

properties ( Access = private )
ModifiedMap
end 

methods 
function this = ChangeReportFacade( changeReport )
R36
changeReport( 1, 1 )mf.zero.ChangeReport
end 
this.Report = changeReport;
end 

function created = get.Created( this )
created = this.Report.Created;
end 

function created = get.CreatedUuids( this )
created = { this.Created.UUID };
end 

function destroyed = get.DestroyedUuids( this )
destroyed = { this.Report.Destroyed.UUID };
end 

function modified = get.Modified( this )
modified = [ this.Report.Modified.Element ];
end 

function modified = get.ModifiedUuids( this )
modified = { this.Modified.UUID };
end 

function map = get.ModifiedMap( this )
if ~isobject( this.ModifiedMap )
modified = this.Report.Modified;
if ~isempty( modified )
els = [ modified.Element ];
props = cell( size( els ) );
for i = 1:numel( els )
props{ i } = { modified( i ).ModifiedProperties.name };
end 
map = containers.Map( { els.UUID }, props );
this.ModifiedMap = map;
else 
map = containers.Map(  );
this.ModifiedMap = map;
end 
else 
map = this.ModifiedMap;
end 
end 

function modified = isModified( this, arg, prop )
R36
this( 1, 1 )
arg
prop{ mustBeTextScalar( prop ) } = ''
end 
if ~isempty( arg )
uuids = toUuids( arg );
modified = this.ModifiedMap.isKey( uuids );
else 
modified = logical.empty;
return 
end 
if ~isempty( prop )
for i = find( modified )
modified( i ) = any( strcmp( prop, this.ModifiedMap( uuids{ i } ) ) );
end 
end 
end 

function props = getModifiedProperties( this, arg )
uuid = toUuids( arg, true );
map = this.ModifiedMap;
if map.isKey( uuid )
props = map( uuid );
else 
props = {  };
end 
end 

function created = isCreated( this, arg )
if ~isempty( arg )
created = ismember( toUuids( arg ), this.CreatedUuids );
else 
created = logical.empty;
end 
end 

function destroyed = isDestroyed( this, arg )
if ~isempty( arg )
destroyed = ismember( toUuids( arg ), this.DestroyedUuids );
else 
destroyed = logical.empty;
end 
end 
end 

methods ( Static )
function wrapperFunc = converter( listenerFunc )
R36
listenerFunc( 1, 1 )function_handle
end 
wrapperFunc = @( report )listenerFunc( coderapp.internal.mfz.ChangeReportFacade( report ) );
end 
end 
end 


function uuids = toUuids( arg, scalarOnly )
R36
arg
scalarOnly = false
end 
if isempty( arg )
uuids = {  };
elseif isobject( arg )
uuids = { arg.UUID };
else 
mustBeText( arg );
uuids = cellstr( arg );
end 
assert( ~scalarOnly || isscalar( arg ), 'Expected a scalar' );
if scalarOnly
uuids = uuids{ 1 };
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmphuzeon.p.
% Please follow local copyright laws when handling this file.

