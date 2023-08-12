classdef ( Sealed )TypeMakerNode < handle




properties ( Hidden, Constant )
EMPTY_CHANGE = cell2struct( cell( 0, 4 ), { 'node', 'type', 'annotations', 'info' }, 2 )
end 

properties ( SetAccess = immutable )
Id uint32
TypeMaker codergui.internal.type.TypeMaker
end 

properties ( SetAccess = { ?codergui.internal.type.TypeMakerNode, ?codergui.internal.type.TypeMaker } )
Parent codergui.internal.type.TypeMakerNode
end 

properties ( Dependent, GetAccess = { ?codergui.internal.type.TypeMakerNode, ?codergui.internal.type.Attribute }, SetAccess = immutable )
IsInternalChange
end 

properties ( Dependent, SetAccess = immutable )
CustomAttributes
end 

properties ( Dependent, GetAccess = private, SetAccess = immutable )
InternalAttributes
end 

properties ( Dependent, SetAccess = private )
MetaType
Children codergui.internal.type.TypeMakerNode
Attributes codergui.internal.type.Attribute
NumChildren
IsRoot
HasChanges
Root codergui.internal.type.TypeMakerNode
SizeAttribute codergui.internal.type.Attribute
AddressAttribute codergui.internal.type.Attribute
end 

properties ( Dependent )
Class
Address
Size
end 

properties ( Hidden, SetAccess = private )
TypeChecksum char
end 

properties ( GetAccess = private, SetAccess = immutable )
ClassAttribute
MetaTypeHolder
AdditionsHolder
RemovalsHolder
ChildrenHolder
AttributesHolder
SizeAttrHolder
AddressAttrHolder
AllHolders
end 

properties ( Access = private )
IsNew = true
TriggerDepth =  - 1
NextMetaType
SilentClassChange = false
Validating = false
Reorders = zeros( 0, 2 )
ChecksumAttributes codergui.internal.type.Attribute
end 

methods ( Access = ?codergui.internal.type.TypeMaker )
function this = TypeMakerNode( id, typeMaker, parent )
if nargin == 0
return 
elseif nargin < 3
parent = codergui.internal.type.TypeMakerNode.empty(  );
end 

this( numel( id ) ) = codergui.internal.type.TypeMakerNode;
classAttrDef = codergui.internal.type.AttributeDefs.Class;
sizeAttrDef = codergui.internal.type.AttributeDefs.Size;
if ~isempty( parent ) && ~isempty( parent.MetaType.ChildAddressAttribute )
addrAttrDef = parent.MetaType.ChildAddressAttribute;
else 
addrAttrDef = codergui.internal.type.AttributeDefs.Address;
end 

for i = 1:numel( id )
instance = this( i );
instance.Id = id( i );
instance.Parent = parent;
instance.TypeMaker = typeMaker;
instance.MetaTypeHolder = codergui.internal.type.FlushableValue( codergui.internal.type.MetaType.empty(  ) );
instance.AdditionsHolder = codergui.internal.type.FlushableValue( codergui.internal.type.TypeMakerNode.empty(  ) );
instance.RemovalsHolder = codergui.internal.type.FlushableValue( codergui.internal.type.TypeMakerNode.empty(  ) );
instance.ChildrenHolder = codergui.internal.type.FlushableValue( codergui.internal.type.TypeMakerNode.empty(  ) );
instance.AttributesHolder = codergui.internal.type.FlushableValue( codergui.internal.type.Attribute.empty(  ) );
instance.SizeAttrHolder = codergui.internal.type.FlushableValue( codergui.internal.type.Attribute(  ...
instance, sizeAttrDef, @instance.setSizeCallback ) );
instance.AddressAttrHolder = codergui.internal.type.FlushableValue( codergui.internal.type.Attribute(  ...
instance, addrAttrDef, @instance.setAddressCallback ) );
instance.AllHolders = [ instance.MetaTypeHolder, instance.AdditionsHolder, instance.RemovalsHolder ...
, instance.ChildrenHolder, instance.AttributesHolder, instance.SizeAttrHolder, instance.AddressAttrHolder ];
instance.ClassAttribute = codergui.internal.type.Attribute( instance, classAttrDef, @instance.applyClass, false );
end 
end 
end 

methods 
function result = get( this, keyOrDef, prop )
if nargin < 3
prop = '';
end 
result = this.multiGet( keyOrDef, prop, 'deal' );
end 

function varargout = multiGet( this, keysOrDefs, prop, outputMode )
if nargin > 1
attribs = this.attr( keysOrDefs );
else 
attribs = this.Attributes;
end 
if nargin < 3 || isempty( prop )
results = { attribs.Value };
else 
results = { attribs.( [ upper( prop( 1 ) ), prop( 2:end  ) ] ) };
end 
if nargin < 4 || isempty( outputMode )
if nargout > 1
outputMode = 'deal';
else 
outputMode = 'cell';
end 
end 
switch outputMode
case 'cell'
varargout = { results };
case 'deal'
varargout = results;
otherwise 
codergui.internal.util.throwInternal( '"%s" is not a valid output mode., outputMode' );
end 
end 

function set( this, keyOrDef, prop, value )
if nargin < 4
value = prop;
prop = '';
end 
this.multiSet( keyOrDef, prop, { value } );
end 

function multiSet( this, keysOrDefs, prop, values, force )
narginchk( 3, 5 );
if isempty( this )
return 
end 

argCount = nargin;
if argCount < 5
force = false;
if argCount < 4
values = prop;
prop = [  ];
end 
end 
if isempty( prop )
valueSet = true;
else 
prop = [ upper( prop( 1 ) ), prop( 2:end  ) ];
valueSet = strcmp( prop, 'Value' );
end 

try 
if isscalar( this )
cleanup = this.pushTrigger(  );%#ok<NASGU>
attribs = this.attr( keysOrDefs );
else 
if ~ischar( keysOrDefs ) && ~isscalar( keysOrDefs )
error( 'multiSet only works for single attributes if given multiple nodes' );
end 
cleanups = cell( 1, numel( this ) );
attribs = repmat( this( 1 ).ClassAttribute, 1, numel( this ) );
attrCount = numel( string( keysOrDefs ) );
for i = 1:numel( this )
cleanups{ i } = this( i ).pushTrigger(  );
aiStart = ( i - 1 ) * attrCount + 1;
attribs( aiStart:aiStart + attrCount - 1 ) = this( i ).attr( keysOrDefs );
end 
end 
if argCount < 3
attribs.reset(  );
return 
end 
if force
trues = num2cell( true( 1, numel( attribs ) ) );
[ attribs.ForceNextValue ] = trues{ : };
else 
prevForcedAttribs = attribs( attribs.ForceNextValue );
if ~isempty( prevForcedAttribs )
falses = num2cell( false( 1, numel( prevForcedAttribs ) ) );
[ prevForcedAttribs.ForceNextValue ] = falses{ : };
end 
end 
if valueSet
[ attribs.Value ] = values{ : };
else 
[ attribs.( prop ) ] = values{ : };
end 
catch me
for i = 1:numel( this )
this( i ).revert( me );
end 
end 
end 

function attribs = attr( this, keysOrDefs )
if ischar( keysOrDefs ) || isstring( keysOrDefs )
switch keysOrDefs
case 'class'
attribs = this.ClassAttribute;
return 
case 'address'
attribs = this.AddressAttribute;
return 
case 'size'
attribs = this.SizeAttribute;
return 
otherwise 
keysOrDefs = cellstr( keysOrDefs );
end 
end 
if iscellstr( keysOrDefs )
internals = this.InternalAttributes;
[ internalMask, internalIndices ] = ismember( keysOrDefs, { internals.Key } );
attribs = repmat( this.ClassAttribute, 1, numel( keysOrDefs ) );
attribs( internalMask ) = internals( internalIndices( internalMask ) );
if ~isempty( this.MetaType )
attribs( ~internalMask ) = this.Attributes( numel( internals ) + this.MetaType.getAttributeIndices( keysOrDefs( ~internalMask ) ) );
else 
attribs( ~internalMask ) = this.Attributes( numel( internals ) );
end 
elseif isa( keysOrDefs, 'codergui.internal.type.AttributeDef' )
attrDefs = [ this.Attributes.Definition ];
[ matched, indices ] = ismember( { keysOrDefs.Key }, { attrDefs.Key } );
if ~all( matched )
codergui.internal.util.throwInternal( 'Unrecognized attribute definitions: %s', strjoin( { keysOrDefs( ~matched ).Key }, ', ' ) );
end 
attribs = this.Attributes( indices );
elseif isa( keysOrDefs, 'codergui.internal.type.Attribute' )
[ matched, indices ] = ismember( keysOrDefs, this.Attributes );
if ~all( matched )
codergui.internal.util.throwInternal( 'Unrecognized attributes: %s', strjoin( { keysOrDefs( ~matched ).Key }, ', ' ) );
end 
attribs = this.Attributes( indices );
elseif isnumeric( keysOrDefs )
attribs = this.Attributes( keysOrDefs );
else 
codergui.internal.util.throwInternal( 'Unsupported "keys" argument class: %s', class( keysOrDefs ) );
end 
end 

function newChildren = append( this, count )
if nargin < 2
count = 1;
end 
cleanup = this.pushTrigger(  );%#ok<NASGU>
if isempty( this.MetaType ) || this.MetaType.IsLeaf
this.revert( 'coderApp:typeMaker:childrenNotAllowed', 'MetaType "%s" cannot have children', this.MetaType.Id );
end 
newChildren = this.TypeMaker.createNodes( this, count );
this.doAppendChildren( newChildren );
end 

function remove( this, indicesOrNodes )
if isa( indicesOrNodes, 'codergui.internal.type.TypeMakerNode' )
[ found, indices ] = ismember( indicesOrNodes, this.Children );
indices = indices( found );
else 
indices = indicesOrNodes;
end 
removed = this.Children( indices );
if isempty( removed )
return 
end 

cleanup = this.pushTrigger(  );%#ok<NASGU>
nextChildren = this.ChildrenHolder.Current;
nextChildren( indices ) = [  ];
this.ChildrenHolder.Next = nextChildren;



select = [ removed.IsNew ];
if any( select )
this.AdditionsHolder.Next = setdiff( this.AdditionsHolder.Current, removed( select ), 'stable' );
end 
select = ~select;
if any( select )
this.RemovalsHolder.Next = [ this.RemovalsHolder.Current, removed( select ) ];
end 
end 

function clearChildren( this )
this.remove( 1:numel( this.Children ) );
end 

function moveChild( this, moveNode, newIdx )
if isempty( moveNode )
return 
end 
children = this.ChildrenHolder.Current;
if isnumeric( moveNode )
oldIdx = moveNode;
else 
[ ~, ~, oldIdx ] = intersect( moveNode, children, 'stable' );
end 
newIdx = reshape( max( 1, min( numel( children ), newIdx ) ), [  ], 1 );
oldIdx = reshape( oldIdx, [  ], 1 );
if all( oldIdx == newIdx )
return 
end 
indices = 1:numel( children );
if newIdx > oldIdx
indices( oldIdx:newIdx - 1 ) = indices( oldIdx + 1:newIdx );
else 
indices( newIdx + 1:oldIdx ) = indices( newIdx:oldIdx - 1 );
end 
indices( newIdx ) = oldIdx;

cleanup = this.pushTrigger(  );%#ok<NASGU>
this.ChildrenHolder.Next = children( indices );

changed = newIdx ~= oldIdx;
this.Reorders( end  + 1:end  + nnz( changed ), : ) = [ reshape( oldIdx( changed ), [  ], 1 ), reshape( newIdx( changed ), [  ], 1 ) ];
end 

function reset( this )
this.Class = '';
end 

function internal = get.IsInternalChange( this )
internal = this.TriggerDepth > 0;
end 

function children = get.Children( this )
children = this.ChildrenHolder.Current;
end 

function metaType = get.MetaType( this )
metaType = this.MetaTypeHolder.Current;
end 

function set.MetaType( this, metaType )
this.MetaTypeHolder.Next = metaType;
end 

function set.Class( this, newClass )
this.ClassAttribute.Value = newClass;
end 

function class = get.Class( this )
class = this.ClassAttribute.Value;
end 

function set.Address( this, address )
this.AddressAttribute.Value = address;
end 

function address = get.Address( this )
address = this.AddressAttribute.Value;
end 

function set.Size( this, size )
this.SizeAttribute.Value = size;
end 

function size = get.Size( this )
size = this.SizeAttribute.Value;
end 

function attrs = get.Attributes( this )
attrs = this.AttributesHolder.Current;
if isempty( attrs )
attrs = [ this.ClassAttribute, this.SizeAttribute, this.AddressAttribute ];
end 
end 

function set.Attributes( this, attrs )
this.AttributesHolder.Next = [ this.ClassAttribute, this.SizeAttribute, this.AddressAttribute, attrs ];
end 

function changed = get.HasChanges( this )
changed = any( [ this.Attributes.IsPending, this.AllHolders.IsPending ] );
end 

function numChildren = get.NumChildren( this )
numChildren = numel( this.Children );
end 

function root = get.IsRoot( this )
root = isempty( this.Parent );
end 

function root = get.Root( this )
root = this;
while ~root.IsRoot
root = root.Parent;
end 
end 

function attrs = get.InternalAttributes( this )
attrs = [ this.ClassAttribute, this.SizeAttribute, this.AddressAttribute ];
end 

function attrs = get.CustomAttributes( this )
attrs = this.Attributes( numel( this.InternalAttributes ) + 1:end  );
end 

function attr = get.AddressAttribute( this )
attr = this.AddressAttrHolder.Current;
end 

function set.AddressAttribute( this, attr )
this.AddressAttrHolder.Next = attr;
this.AttributesHolder.Next = [ this.ClassAttribute,  ...
this.SizeAttribute, this.AddressAttribute, this.CustomAttributes ];
end 

function attr = get.SizeAttribute( this )
attr = this.SizeAttrHolder.Current;
end 

function set.SizeAttribute( this, attr )
this.SizeAttrHolder.Next = attr;
this.AttributesHolder.Next = [ this.ClassAttribute,  ...
this.SizeAttribute, this.AddressAttribute, this.CustomAttributes ];
end 

function checksum = get.TypeChecksum( this )
checksum = this.TypeChecksum;
if isempty( checksum )
checksum = this.generateTypeChecksum(  );
this.TypeChecksum = checksum;
end 
end 

function subtree = getSubtree( this )
if isempty( this )
subtree = this;
return 
elseif ~isscalar( this )
subtree = cell( 1, numel( this ) );
for i = 1:numel( this )
subtree{ i } = this( i ).getSubtree(  );
end 
subtree = [ subtree{ : } ];
return 
end 

subtree = cell( 1, numel( this.Children ) );
for i = 1:numel( this.Children )
subtree{ i } = this.Children( i ).getSubtree(  );
end 
subtree = [ this, subtree{ : } ];
end 

function coderType = getCoderType( this, modelOrBuilder )
R36
this( 1, 1 )
modelOrBuilder{ mustBeA( modelOrBuilder, [ "mf.zero.Model", "codergui.internal.type.TypeStoreBuilder" ] ) } = mf.zero.Model.empty
end 

if isempty( this.MetaType )
codergui.internal.util.throwInternal( 'No MetaType' );
end 

if ~isempty( modelOrBuilder )
coderType = this.toMF0( modelOrBuilder );
return ;
end 

childTypes = cell( 1, numel( this.Children ) );
children = this.Children;

if ~hasCustomCoderType( this.Class )
for i = 1:numel( this.Children )
childTypes{ i } = children( i ).getCoderType(  );
end 
coderType = this.MetaType.toCoderType( this, childTypes );
else 
coderType = this.MetaType.toCoderType( this, children );
end 

[ initValue, expr, internal ] = this.multiGet( { 'initialValue', 'valueExpression', 'isInternalValueExpr' },  ...
'value', 'deal' );

if ~isa( coderType, 'coder.type.Base' )
coderType.InitialValue = initValue;
if ~internal
coderType.ValueConstructor = expr;
end 
end 
end 

function setCoderType( this, coderType )
if isa( coderType, 'coderapp.internal.codertype.Type' )
this.fromMF0( coderType );
return ;
end 
cleanup = this.pushTrigger(  );%#ok<NASGU>
isType = isa( coderType, 'coder.Type' ) || isa( coderType, 'coder.type.Base' );
isConstant = isType && isa( coderType, 'coder.Constant' );
if ~isType
try 
coderType = coder.typeof( coderType );
catch me
this.revert( me );
end 
end 

if ~coder.type.Base.isEnabled( 'GUI' ) && isa( coderType, 'coder.type.Base' )
coderType = coderType.getCoderType(  );
elseif coder.type.Base.isEnabled( 'GUI' ) && coder.type.Base.isEnabled( 'CLI' )
coderType = coder.type.Base.applyCustomCoderType( coderType );
end 

schema = this.TypeMaker.MetaTypeSchema;
if isa( coderType, 'coder.OutputType' ) || isConstant
className = class( coderType );
elseif isa( coderType, 'coder.type.Base' )
className = coderType.getCoderType(  ).ClassName;
else 
className = coderType.ClassName;
end 




if isa( coderType, 'coder.type.Base' )
metaType = schema.getMetaType( 'coder.type.Base' );
else 
metaType = schema.getMetaType( class( coderType ) );
if isempty( metaType )
metaType = schema.getMetaType( coderType.ClassName );
end 
if isempty( metaType )
codergui.internal.util.throwInternal( 'Unsupported type' );
end 
end 

internalCleanup = this.pushTrigger(  );%#ok<NASGU>
this.NextMetaType = metaType;
this.Class = className;

try 
metaType.fromCoderType( this, coderType );
catch me
this.revert( me );
end 


if isType && ~isa( coderType, 'coder.type.Base' )
if ~isempty( coderType.ValueConstructor ) || isConstant
valueCon = coderType.ValueConstructor;
if isConstant && isempty( valueCon )
valueCon = coderapp.internal.value.valueToExpression( coderType.Value, 4000 );
this.set( 'isInternalValueExpr', true );
end 
this.set( 'valueExpression', valueCon );
end 
if ~isempty( coderType.InitialValue )
this.set( 'initialValue', coderType.InitialValue );
end 
end 
end 

function globalSpec = asGlobal( this, globalName )
coderType = this.getCoderType(  );
initialValue = this.resolveValue(  );
globalSpec = { coderType, initialValue };
if nargin > 1 && ~isempty( globalName )
globalSpec = { globalName, globalSpec };
end 
end 

function asConstant( this )
try 
value = this.resolveValue(  );
catch 
try 
value = evalin( 'base', sprintf( '%s.empty', this.Class ) );
catch 
value = [  ];
end 
end 
if ~codergui.internal.undefined( value )
this.setCoderType( coder.Constant( value ) );
end 
end 

function state = getTransientNodeState( this, nonDefaultOnly, externalizeAttributes )
if nargin < 3
externalizeAttributes = false;
if nargin < 2
nonDefaultOnly = true;
end 
end 
state = this.getBasicNodeState( false, nonDefaultOnly, externalizeAttributes );
for i = 1:numel( this )
state( i ).children = [ this( i ).Children.Id ];
if ~isempty( this( i ).Parent )
state( i ).parent = this( i ).Parent.Id;
else 
state( i ).parent = 0;
end 
end 
end 

function nodeStates = getPersistableSubtreeState( this )
nodes = this.getSubtree(  );
nodeStates = nodes.getBasicNodeState( true, false, true );
tempVals = repmat( { [  ] }, 1, numel( nodeStates ) );
[ nodeStates.children ] = tempVals{ : };
tempVals = num2cell( [ nodes.IsRoot ] );
[ nodeStates.isRoot ] = tempVals{ : };

idsToIndices = containers.Map( [ nodes.Id ], 1:numel( nodes ) );
for i = find( [ nodes.NumChildren ] > 0 )
indices = idsToIndices.values( num2cell( [ nodes( i ).Children.Id ] ) );
nodeStates( i ).children = [ indices{ : } ];
end 
end 

function unionWith( this, other )
if isa( other, 'codergui.internal.type.TypeMakerNode' )
other = other.getCoderType(  );
elseif ~isa( other, 'coder.Type' )
other = coder.typeof( other );
end 
if ~isempty( this.MetaType )
other = this.getCoderType(  ).union( other );
end 
this.setCoderType( other );
end 

function [ code, nodeRanges ] = toCode( this, varName )
tempChildRoot = 'childTypes';
tempVar = 'temp';
if nargin < 2 || isempty( varName )
varName = 'type';
end 
if strcmp( varName, tempChildRoot )
tempChildRoot = [ tempChildRoot, 'Temp' ];
end 
if strcmp( varName, tempVar )
tempVar = [ tempVar, 'Temp' ];
end 

topSections = cell( 1, numel( this ) );
nodeRanges = topSections;
pos = 1;
nl = newline(  );
nlc = numel( nl );

for i = 1:numel( this )
sections = this( i ).doToCode( varName, struct( 'childRoot', tempChildRoot, 'tempVar', tempVar ) );
nodeRanges{ i } = repmat( struct( 'node', { 0 }, 'start', { 0 }, 'end', { 0 } ), 1, numel( sections ) );
for j = 1:numel( sections )
sectionCode = sections( j ).code;
endPos = pos + numel( sectionCode ) - 1;
nodeRanges{ i }( j ).node = sections( j ).node;
nodeRanges{ i }( j ).start = pos;
nodeRanges{ i }( j ).end = endPos;
pos = endPos + 1 + nlc;
end 
topSections{ i } = strjoin( { sections.code }, nl );
pos = pos + nlc;
end 

varsToClear = { tempChildRoot, tempVar };
if hasCustomCoderType( this.Class )
addlVars = '';
for i = 1:numel( sections )
if ~isempty( sections( i ).ClearVar )
addlVars = [ addlVars, ' ', sections( i ).ClearVar ];%#ok<AGROW>
end 
end 

addlVars = strtrim( addlVars );
if ~isempty( addlVars )
varsToClear = [ tempVar, addlVars ];
end 
end 

code = clearVarIfUsed( strjoin( topSections, [ nl, nl ] ), varsToClear );
nodeRanges = [ nodeRanges{ : } ];
end 

function setChildrenAddresses( this, children, addresses )
if nargin < 3
addresses = children;
children = this.Children;
skipValidate = true;
else 
skipValidate = false;
end 
if ~iscell( addresses )
codergui.internal.util.throwInternal( 'Addresses must be wrapped in cell arrays' );
elseif numel( children ) ~= numel( addresses )
codergui.internal.util.throwInternal( 'Length of children and addresses arguments do not match' );
end 
invalidChildren = false;
if ~skipValidate
if isnumeric( children )
[ matched, idx ] = ismember( children, [ this.Children.Id ] );
if all( matched )
children = this.Children( idx );
else 
invalidChildren = true;
end 
elseif ~isempty( setdiff( children, this.Children ) )
invalidChildren = true;
end 
end 
if invalidChildren
codergui.internal.util.throwInternal( 'setChildrenAddresses should only be called on direct descendants' );
elseif ~isempty( children )
children.multiSet( 'address', [  ], addresses, true );
end 
end 
end 

methods ( Access = { ?codergui.internal.type.TypeMakerNode, ?codergui.internal.type.TypeMaker } )
function [ changes, creations, defuncts ] = applyChanges( this )
changes = cell( 1, numel( this ) );
defuncts = changes;
creations = changes;
for i = 1:numel( this )
[ changes{ i }, creations{ i }, defuncts{ i } ] = this( i ).doApplyChanges(  );
end 


[ ~, ordinals ] = sort( [ this.Id ] );
changes = [ changes{ ordinals } ];
creations = [ creations{ ordinals } ];
defuncts = [ defuncts{ ordinals } ];

if isempty( creations )
creations = codergui.internal.type.TypeMakerNode.empty(  );
end 
if isempty( defuncts )
defuncts = codergui.internal.type.TypeMakerNode.empty(  );
end 
if ~isempty( changes ) || ~isempty( creations ) || ~isempty( defuncts )
clearPendingChanges( unique( [ changes.node, creations, defuncts ] ) );
end 
end 

function clearPendingChanges( this )
allAttrs = [ this.Attributes ];
allAttrs.reset(  );
allHolders = [ this.AllHolders ];
allHolders.clear(  );

emptyReorders = zeros( 0, 2 );
for i = 1:numel( this )
node = this( i );
node.TypeChecksum = '';
node.NextMetaType = [  ];
node.TriggerDepth =  - 1;
node.Reorders = emptyReorders;
end 
end 

function restoreOwnState( this, states, wasExternalized )
assert( numel( this ) == numel( states ) );
if isempty( this )
return 
end 
if nargin < 3
wasExternalized = false;
end 
changed = false( 1, numel( this ) );

for i = 1:numel( this )
node = this( i );
state = states( i );
iChanged = false;




combinedAttrStates = { [  ], [  ], [  ] };
if ~strcmp( state.class, node.Class )
if ~isempty( state.class )
combinedAttrStates{ 1 } = state.class;
node.Class = state.class.value;
else 
node.Class = '';
end 
iChanged = true;
end 
if ~isempty( state.size ) && ~isequal( state.size, node.Size )
combinedAttrStates{ 2 } = state.size;
iChanged = true;
end 
if ~isempty( state.address ) && ~isequal( state.address, node.Address )
combinedAttrStates{ 3 } = state.address;
iChanged = true;
end 
allAttrStates = [ combinedAttrStates{ : }, state.attributes ];
if ~isempty( allAttrStates )
attrs = node.attr( { allAttrStates.key } );
iChanged = any( attrs.restore( allAttrStates, wasExternalized ) ) || iChanged;
end 
[ resolved, moveIdx ] = ismember( state.children, [ node.Children.Id ] );
if all( resolved )
if ~issorted( moveIdx )
node.ChildrenHolder.Next = node.Children( moveIdx );
node.Reorders( end  + 1:end  + numel( moveIdx ), : ) = [ 1:numel( node.Children );moveIdx ]';
end 
changed( i ) = iChanged;
end 
end 

if any( changed )
this( 1 ).TypeMaker.commitNode( this( changed ) );
end 
end 

function deserializeNode( this, stateIndex, allStates )
assert( isscalar( this ) && isscalar( stateIndex ) );

state = allStates( stateIndex );
this.restoreOwnState( state, true );

if ~isempty( state.children )
children = this.append( numel( state.children ) );
for i = 1:numel( children )
children( i ).deserializeNode( state.children( i ), allStates );
end 
end 
end 

function doAppendChildren( this, newChildren )
schema = this.TypeMaker.MetaTypeSchema;
this.MetaType.initializeChildren( this, newChildren );

if ~isempty( schema.DefaultClass )
for child = reshape( newChildren, 1, [  ] )
if isempty( child.Class )
child.Class = schema.DefaultClass;
end 
end 
end 

this.ChildrenHolder.Next = [ this.ChildrenHolder.Current, newChildren ];
this.AdditionsHolder.Next = [ this.AdditionsHolder.Current, newChildren ];
end 
end 

methods ( Access = { ?codergui.internal.type.TypeMakerNode, ?codergui.internal.type.TypeMaker, ?codergui.internal.type.MetaType } )
function assignChildTypes( this, childTypes, addresses )



if ~iscell( childTypes )
childTypes = num2cell( childTypes );
end 
children = this.Children;
if numel( children ) < numel( childTypes )
this.append( numel( childTypes ) - numel( children ) );
elseif numel( children ) > numel( childTypes )
this.remove( numel( childTypes ) + 1:numel( children ) );
end 
children = this.Children;
hasAddresses = nargin > 2 && ~isempty( addresses );
if hasAddresses && ~iscell( addresses )
addresses = num2cell( addresses );
end 
for i = 1:numel( childTypes )
children( i ).setCoderType( childTypes{ i } );
end 
if hasAddresses
this.setChildrenAddresses( children, addresses );
end 
end 

function internalAppend( this, children )
this.doAppendChildren( children );
for i = 1:numel( children )
children( i ).Parent = this;
end 
end 



function internalSetClass( this, className )
this.SilentClassChange = true;
this.Class = className;
this.SilentClassChange = false;
end 
end 

methods ( Access = { ?codergui.internal.type.Attribute, ?codergui.internal.type.TypeMakerNode } )
function triggerCleanup = pushTrigger( this )
if ~this.Validating
this.TriggerDepth = this.TriggerDepth + 1;
triggerCleanup = onCleanup( @this.cleanupAndCommit );
else 
triggerCleanup = [  ];
end 
end 

function revert( this, varargin )
this.TypeMaker.rollback( this );
if ~isempty( varargin )
if numel( varargin ) == 1 && isa( varargin{ 1 }, 'MException' )
varargin{ 1 }.rethrow(  );
else 
error( varargin{ : } );
end 
end 
end 
end 

methods ( Access = private )
function [ changes, creations, defuncts ] = doApplyChanges( this )
ownChanges = this.EMPTY_CHANGE(  );
cn = 0;

if ~isempty( this.MetaType )
this.Validating = true;
try 
this.MetaType.validateNode( this );
this.Validating = false;
catch me
this.Validating = false;
me.rethrow(  );
end 
end 

if this.MetaTypeHolder.IsPending
cn = cn + 1;
ownChanges( cn ).type = codergui.internal.type.ChangeType.MetaType;
ownChanges( cn ).annotations = this.MetaTypeHolder.Annotations;
if ~isempty( this.MetaType )
ownChanges( end  ).info = this.MetaType.Id;
else 
ownChanges( end  ).info = '';
end 
end 

pendingAttrs = this.Attributes;
pendingAttrs = pendingAttrs( [ pendingAttrs.IsPending ] );
if ~isempty( pendingAttrs )
aIdx = numel( ownChanges ) + 1:numel( ownChanges ) + numel( pendingAttrs );
[ ownChanges( aIdx ).type ] = deal( codergui.internal.type.ChangeType.Attribute );
allAnnotations = { pendingAttrs.Annotations };
[ ownChanges( aIdx ).annotations ] = allAnnotations{ : };
attrKeys = { pendingAttrs.Key };
[ ownChanges( aIdx ).info ] = attrKeys{ : };
cn = numel( ownChanges );
end 

if ~isempty( this.RemovalsHolder.Next )
removalNodes = this.RemovalsHolder.Next;
defuncts = removalNodes.getSubtree(  );
this.RemovalsHolder.clear(  );
if ~isempty( removalNodes )
cn = cn + 1;
ownChanges( cn ).type = codergui.internal.type.ChangeType.ChildrenRemoved;
ownChanges( cn ).annotations = this.RemovalsHolder.Annotations;
ownChanges( cn ).info = { removalNodes.Id };
end 
this.RemovalsHolder.clear(  );
else 
defuncts = [  ];
end 

if ~isempty( this.AdditionsHolder.Next )
cn = cn + 1;
addedNodes = this.AdditionsHolder.Next;
ownChanges( cn ).type = codergui.internal.type.ChangeType.ChildrenAdded;
ownChanges( cn ).annotations = [  ];
ownChanges( cn ).info = { addedNodes.Id };
subChanges = cell( 1, numel( addedNodes ) );
creations = subChanges;
for i = 1:numel( addedNodes )
[ subChanges{ i }, creations{ i } ] = addedNodes( i ).doApplyChanges(  );
end 
creations = [ creations{ : } ];
this.AdditionsHolder.clear(  );
else 
addedNodes = [  ];
subChanges = {  };
creations = [  ];
end 

if ~isempty( this.Reorders )
cn = cn + 1;
ownChanges( cn ).type = codergui.internal.type.ChangeType.ChildrenMoved;
ownChanges( cn ).annotations = [  ];
reorders = this.Reorders;
ownChanges( cn ).info = num2cell( struct( 'from', num2cell( reorders( :, 1 ) ),  ...
'to', num2cell( reorders( :, 2 ) ) ) );
end 

if ~isempty( this.ChildrenHolder.Next )
children = this.ChildrenHolder.Next;
elseif ~isempty( this.ChildrenHolder.Current )
children = this.ChildrenHolder.Current;
else 
children = [  ];
end 

if ~isempty( children )
if exist( 'addedNodes', 'var' ) > 0
children = children( ~ismember( children, addedNodes ) );
end 
subChangesCnt = numel( subChanges );
for i = 1:numel( children )
[ subChanges{ subChangesCnt + 1 } ] = children( i ).doApplyChanges(  );
subChangesCnt = subChangesCnt + 1;
end 
end 

this.AllHolders.flush(  );
pendingAttrs.applyChanges(  );

[ ownChanges.node ] = deal( this );
changes = [ reshape( ownChanges, 1, [  ] ), subChanges{ : } ];
if this.IsNew
creations = [ this, creations ];
this.IsNew = false;
end 
end 

function newClass = applyClass( this, newClass )
if this.SilentClassChange
return 
end 

metaType = this.NextMetaType;
if isempty( metaType )
if ~isempty( newClass )
metaType = this.TypeMaker.MetaTypeSchema.getMetaType( newClass );
if isempty( metaType )
tmerror( message( 'coderApp:typeMaker:unsupportedClass', newClass ) );
end 
else 
metaType = codergui.internal.type.MetaType.empty(  );
end 
else 
this.NextMetaType = [  ];
end 

fullApply = ~this.TypeMaker.IsRestoring;
if ~isequal( metaType, this.MetaType ) || ~fullApply
if ~isempty( this.MetaType )
this.MetaType.cleanupNode( this );
end 
this.MetaType = metaType;

if fullApply
this.clearChildren(  );
end 

sizeAttrDef = codergui.internal.type.AttributeDefs.Size;
if ~isempty( metaType )
this.Attributes = codergui.internal.type.Attribute( this, metaType.Attributes );
if fullApply
try 
metaType.applyToNode( this );
catch me
this.revert( me );
end 
end 
if ~isempty( metaType.CustomSizeAttribute )
sizeAttrDef = metaType.CustomSizeAttribute;
end 
else 
this.Attributes = codergui.internal.type.Attribute.empty(  );
end 
this.SizeAttribute = codergui.internal.type.Attribute(  ...
this, sizeAttrDef, @this.setSizeCallback );
this.ChecksumAttributes = this.Attributes( { this.Attributes.Key } ~= "address" );
end 

if ~strcmp( newClass, this.Class )
if ~isempty( this.MetaType )
if fullApply
this.MetaType.applyClass( this, newClass );
redirectClass = this.MetaType.getUserFacingClass( this );
if ~isempty( redirectClass )
newClass = redirectClass;
end 
end 
elseif ~isempty( newClass )
this.revert( 'Could not resolve a meta type for class "%s"', newClass );
else 
this.Attributes = codergui.internal.type.Attribute.empty(  );
this.ChecksumAttributes = this.Attributes;
end 
end 
end 

function address = setAddressCallback( this, address )
if this.TypeMaker.IsRestoring
return 
end 
if isempty( this.Parent )
address = this.MetaType.validateNameAddress( address, this, 'invalidVariableName', 'duplicateVariableName' );
else 
assertHasMetaType( this.Parent );
address = this.Parent.MetaType.validateAddress( address, this );
end 
end 

function size = setSizeCallback( this, size )
if ~this.TypeMaker.IsRestoring
this.assertHasMetaType(  );
size = this.MetaType.validateSize( size, this );
end 
end 

function state = getBasicNodeState( this, persistable, nonDefaultOnly, externalizeAttributes )
[ customsStates, classStates, addressStates, sizeStates ] = this.getAttributeBasedState(  ...
~persistable, nonDefaultOnly, externalizeAttributes );
if isempty( this )
id = reshape( {  }, size( classStates ) );
else 
id = { this.Id };
end 
state = struct(  ...
'id', id,  ...
'class', classStates,  ...
'address', addressStates,  ...
'size', sizeStates,  ...
'attributes', customsStates );
if persistable
state = rmfield( state, 'id' );
end 
end 

function [ customs, class, address, size ] = getAttributeBasedState( this, full, nonDefaultOnly, externalizeAttributes )
customs = cell( 1, numel( this ) );
class = customs;
address = customs;
size = customs;

classAttrs = [ this.ClassAttribute ];
addressAttrs = [ this.AddressAttribute ];
sizeAttrs = [ this.SizeAttribute ];

for i = 1:numel( this )
node = this( i );
customs{ i } = node.describeAttributes( node.CustomAttributes, full, nonDefaultOnly, externalizeAttributes );
class{ i } = node.describeAttributes( classAttrs( i ), full, nonDefaultOnly, externalizeAttributes );
address{ i } = node.describeAttributes( addressAttrs( i ), full, nonDefaultOnly, externalizeAttributes );
size{ i } = node.describeAttributes( sizeAttrs( i ), full, nonDefaultOnly, externalizeAttributes );
end 
end 

function value = resolveValue( this )
value = this.MetaType.resolveToValue( this );
if ~codergui.internal.undefined( value )
return 
end 
[ value, valueExpr ] = this.multiGet( [  ...
codergui.internal.type.AttributeDefs.InitialValue,  ...
codergui.internal.type.AttributeDefs.ValueExpression ], 'value', 'deal' );
if ~isempty( valueExpr )
value = evalin( 'base', valueExpr );
end 
if codergui.internal.undefined( value )
codergui.internal.util.throwInternal( 'Undefined value' );
end 
end 

function cleanupAndCommit( this )
nextDepth = this.TriggerDepth - 1;
if nextDepth <  - 1
return 
end 

this.TriggerDepth = nextDepth;
if nextDepth ==  - 1 && ~this.IsNew

this.TypeMaker.commitNode( this );
end 
end 

function assertHasMetaType( this )
assert( numel( this ) == numel( [ this.MetaType ] ), message( 'coderApp:typeMaker:classCannotBeEmpty' ) );
end 

function sections = doToCode( this, varName, tempVars )
childTempVars = this.MetaType.preToCode( this );
preamble = '';


if ~isempty( childTempVars )
oldChildTempVars = childTempVars;
childTempVars = strcat( tempVars.childRoot, '.', childTempVars );

if isa( this.MetaType, 'codergui.internal.type.CustomMetaType' )
preamble = sprintf( '%s = coder.newtype(''%s'');\n', varName, this.Class );
else 
preamble = sprintf( '%s = struct();\n', tempVars.childRoot );
end 
elseif ~iscell( childTempVars )
childTempVars = {  };
end 

childSections = cell( 1, numel( this.Children ) );
for i = 1:numel( this.Children )
needsMasterAssignment = false;

if hasCustomCoderType( this.Class )




if isempty( this.Children( i ).Children )
vName = [ varName, '.', oldChildTempVars{ i } ];
else 
vName = oldChildTempVars{ i };
needsMasterAssignment = true;
end 

childNames = oldChildTempVars;
else 
vName = childTempVars{ i };
childNames = childTempVars;
end 
childSections{ i } = this.Children( i ).doToCode( vName,  ...
struct( 'childRoot', childNames{ i }, 'tempVar', tempVars.tempVar ) );


if needsMasterAssignment
childSections{ i }( end  ).code = sprintf( '%s\n%s.%s = %s;', childSections{ i }( end  ).code, varName, vName, vName );

childSections{ i }( 1 ).ClearVar = vName;
end 
end 
if ~isempty( childSections ) && ~isempty( preamble )
childSections{ 1 }( 1 ).code = [ preamble, childSections{ 1 }( 1 ).code ];
end 

context.childPaths = childTempVars;
if ~isempty( tempVars )
context.childRoot = tempVars.childRoot;
context.tempVar = tempVars.tempVar;
end 
code = this.MetaType.toCode( this, varName, context );
assert( ischar( code ) || iscellstr( code ),  ...
'toCode must return a char vector or a cell array of char vectors' );%#ok<ISCLSTR>

if iscell( code )
code = strjoin( code, newline(  ) );
else 
code = strtrim( code );
end 
ownSection.node = this.Id;
ownSection.code = code;



if ~isfield( ownSection, 'ClearVar' )
ownSection.ClearVar = '';
end 

if ~isempty( code )
sections = [ childSections{ : }, ownSection ];
else 
sections = [ childSections{ : } ];
end 
end 

function checksum = generateTypeChecksum( this )
if isempty( this.MetaType )
checksum = '';
elseif this.MetaType.SupportsChecksum
if isempty( this.Children )
checksum = coderapp.internal.util.md5( this.multiGet( this.ChecksumAttributes, '', 'cell' ) );
else 
checksum = coderapp.internal.util.md5(  ...
this.multiGet( this.ChecksumAttributes, '', 'cell' ),  ...
{ this.Children.TypeChecksum },  ...
{ this.Children.Address } );
end 
else 
checksum = [ '{', char( matlab.lang.internal.uuid(  ) ), '}' ];
end 
end 

function mf0 = toMF0( this, modelOrBuilder )
R36
this( 1, 1 )
modelOrBuilder( 1, 1 ){ mustBeA( modelOrBuilder, [ "mf.zero.Model", "codergui.internal.type.TypeStoreBuilder" ] ) }
end 

if isempty( this.MetaType )
codergui.internal.util.throwInternal( 'No MetaType' );
end 
if isa( modelOrBuilder, 'mf.zero.Model' )
model = modelOrBuilder;
useTypeStore = false;
else 
tsBuilder = modelOrBuilder;
model = tsBuilder.MfzModel;
useTypeStore = true;
end 

children = this.Children;
if ~isempty( children )
childTypes = cell( 1, numel( this.Children ) );
for i = 1:numel( children )
if useTypeStore
childTypes{ i } = tsBuilder.internalAddType( children( i ) );
else 
childTypes{ i } = children( i ).toMF0( model );
end 
end 
childTypes = [ childTypes{ : } ];
else 
childTypes = coderapp.internal.codertype.PrimitiveType.empty(  );
end 

mf0 = this.MetaType.toMF0( this, model, childTypes );
end 

function fromMF0( this, mf0 )


cleanup = this.pushTrigger(  );%#ok<NASGU>
schema = this.TypeMaker.MetaTypeSchema;
this.NextMetaType = schema.getMetaType( class( mf0 ) );


if isprop( mf0, 'ClassName' )
this.Class = mf0.ClassName;
else 
this.Class = class( mf0 );
end 
if isempty( this.MetaType )
codergui.internal.util.throwInternal( 'No MetaType' );
end 

try 
this.Class = this.MetaType.fromMF0( this, mf0 );
assert( ~isempty( this.MetaType ) );
catch me
this.revert( me );
end 
end 
end 

methods ( Static, Access = private )
function states = describeAttributes( attributes, full, filter, externalize )
if filter
if full
filtered = attributes( [ attributes.HasNonDefaultState ] );
else 
filtered = attributes( [ attributes.HasNonDefaultValue ] );
end 
else 
filtered = attributes;
end 
if ~isempty( filtered )
states = filtered.describe( full, externalize, ~filter );
else 
states = [  ];
end 
end 
end 
end 


function code = clearVarIfUsed( code, varNames )
mt = mtree( code );
varNames = varNames( ismember( varNames,  ...
unique( mt.mtfind( 'Kind', 'ID', 'Isvar', true ).strings(  ) ) ) );
if ~isempty( varNames )
code = sprintf( '%s\n\nclear %s;', code, strjoin( varNames, ' ' ) );
end 
end 


function hasCCT = hasCustomCoderType( className )
redirectedClassName = coder.internal.getRedirectedClassName( className );
hasCCT = coder.type.Base.hasCustomCoderType( redirectedClassName ) ...
 && coder.type.Base.isEnabled( 'GUI' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphUbrn8.p.
% Please follow local copyright laws when handling this file.

