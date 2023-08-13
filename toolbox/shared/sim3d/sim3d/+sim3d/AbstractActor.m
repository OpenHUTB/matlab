classdef ( Hidden )AbstractActor < handle


properties ( SetAccess = 'protected', GetAccess = 'protected' )



ObjectIdentifier( 1, 1 )uint32 = uint32( 1 );




ParentIdentifier( 1, : )char = 'Scene Origin';




ActorName( 1, : )char = '';




ActorClassId( 1, 1 )uint16 = uint16( sim3d.utils.SemanticType.None );




ActorType( 1, : )char = '';




Mesh( 1, : )char = '';




Visibility( 1, 1 )logical = true;




HiddenInGame( 1, 1 )logical = false;




SimulatePhysics( 1, 1 )logical = false;




NumberOfParts( 1, 1 )uint32 = 1;




EnableGravity( 1, 1 )logical = true;




CastShadow( 1, 1 )logical = false;

Snapshots( 1, 1 )sim3d.internal.Snapshots;
end 

properties ( Access = public )



Parent = [  ];




Children = struct(  );




ParentWorld = [  ];




Mobility( 1, 1 )int32 = int32( sim3d.utils.MobilityTypes.Static );
end 

properties ( Access = public, Hidden = true )



Transform( 1, 1 )sim3d.utils.Transform = [  ];
end 

properties ( Access = public, Dependent = true )



Translation( :, 3 )single;




Rotation( :, 3 )single;




Scale( :, 3 )single;

end 

properties ( GetAccess = public, Dependent = true )

Name( 1, : )char;
end 

properties ( Access = protected )
TransformReader = [  ];
TransformWriter = [  ];
CreateActor = [  ];
RemoveActorPublisher = [  ];
end 

methods 

function self = AbstractActor( actorName, parentID, translation, rotation, scale, varargin )
self.ObjectIdentifier = self.generateUniqueActorID(  );
r = sim3d.AbstractActor.parseInputs( actorName, varargin{ : } );
self.ActorName = r.ActorName;
self.ActorClassId = r.ActorClassId;
self.ParentIdentifier = parentID;
self.Transform = sim3d.utils.Transform( translation, rotation, scale );
self.NumberOfParts = r.NumberOfParts;
self.Mesh = r.Mesh;
self.Mobility = r.Mobility;
self.Visibility = r.Visibility;
self.HiddenInGame = r.HiddenInGame;
self.SimulatePhysics = r.SimulatePhysics;
self.EnableGravity = r.EnableGravity;
self.CastShadow = r.CastShadow;
self.Snapshots.reset(  );
end 

function delete( self )

if ~isempty( self.TransformReader ) && isvalid( self.TransformReader )
self.TransformReader.delete(  );
self.TransformReader = [  ];
end 
if ~isempty( self.TransformWriter ) && isvalid( self.TransformWriter )
self.TransformWriter.delete(  );
self.TransformWriter = [  ];
end 
if ~isempty( self.CreateActor ) && isvalid( self.CreateActor )
self.CreateActor.delete(  );
self.CreateActor = [  ];
end 
if ~isempty( self.RemoveActorPublisher ) && isvalid( self.RemoveActorPublisher )
self.RemoveActorPublisher.delete(  );
self.RemoveActorPublisher = [  ];
end 

childList = self.getChildList(  );
if ~isempty( childList )
for i = 1:numel( childList )
child = self.Children.( childList{ i } );
if isvalid( child )
child.delete(  );
end 
end 
end 
if ~isempty( self.Parent ) && isvalid( self.Parent )
self.Parent.removeChild( self.getTag(  ) );
end 
if ~isempty( self.ParentWorld ) && isvalid( self.ParentWorld )
if isfield( self.ParentWorld.Actors, self.getTag(  ) )
self.ParentWorld.Actors = rmfield( self.ParentWorld.Actors, self.getTag(  ) );
end 
end 
end 

function Actors = findBy( self, PropName, PropValue, SearchMode )

























R36
self( 1, 1 )sim3d.AbstractActor
PropName( 1, : )char
PropValue
SearchMode{ mustBeMember( SearchMode, { 'first', 'last', 'full' } ) } = 'full'
end 

Actors = {  };

if ~isempty( self.Children )
childList = struct2cell( self.Children );
switch SearchMode
case 'first'
for i = 1:numel( childList )
if isprop( childList{ i }, PropName ) && compareValue( childList{ i }.( PropName ), PropValue )
Actors = childList{ i };
break 
else 
chlds = childList{ i }.findBy( PropName, PropValue, SearchMode );
if ~isempty( chlds )
Actors = chlds;
break ;
end 
end 
end 
case 'last'
for i = 1:numel( childList )
if isprop( childList{ i }, PropName ) && compareValue( childList{ i }.( PropName ), PropValue )
Actors = childList{ i };
end 
chlds = childList{ i }.findBy( PropName, PropValue, SearchMode );
if ~isempty( chlds )
Actors = chlds;
end 
end 
case 'full'
for i = 1:numel( childList )
if isprop( childList{ i }, PropName ) && compareValue( childList{ i }.( PropName ), PropValue )
Actors{ end  + 1 } = childList{ i };%#ok<AGROW> count depends on search
end 
chlds = childList{ i }.findBy( PropName, PropValue );
if ~isempty( chlds )
Actors = horzcat( Actors, chlds );%#ok<AGROW> count depends on search
end 
end 
end 
end 

function Same = compareValue( Value1, Value2 )
if isempty( Value2 )
Same = isempty( Value1 );
elseif isequal( Value2, '*' )
Same = ~isempty( Value1 );
else 
if ischar( Value1 )

if Value2( 1 ) == '*'
if Value2( end  ) == '*'
Same = ~isempty( Value1 ) && contains( Value1, Value2( 2:end  - 1 ), 'IgnoreCase', true );
else 
Same = endsWith( Value1, Value2( 2:end  ), 'IgnoreCase', true );
end 
elseif Value2( end  ) == '*'
Same = startsWith( Value1, Value2( 1:end  - 1 ), 'IgnoreCase', true );
else 
Same = strcmpi( Value1, Value2 );
end 
else 

Same = isequal( Value1, Value2 );
end 
end 
end 

end 

function takeSnapshot( self, Name, Properties, IncludeChildren )
R36
self( 1, 1 )sim3d.AbstractActor;
Name( 1, : )char = ''
Properties( 1, : )cell = { 'Location', 'Rotation' }
IncludeChildren( 1, 1 )logical = true
end 
self.Snapshots.takeSnapshot( self, Name, Properties, IncludeChildren );
end 

function restoreSnapshot( self, SnapID )
found = self.Snapshots.restoreSnapshot( SnapID );
if ~found
warning( message( "shared_sim3d:sim3dActor:SnapshotNotFound", SnapID, self.getTag(  ) ) );
end 
end 
end 


methods ( Access = protected )

function createGameActor( self )
self.CreateActor = sim3d.utils.CreateActor(  );
self.CreateActor.setActorName( self.getTag(  ) );
self.CreateActor.setActorName( self.getTag(  ) );
self.CreateActor.setParentName( self.getParentTag(  ) );
self.CreateActor.setCreateActorType( self.getActorType(  ) );
self.CreateActor.setActorId( self.getActorClassId(  ) );
self.CreateActor.setMesh( self.Mesh(  ) );
self.CreateActor.setMobility( self.Mobility(  ) );
self.CreateActor.setVisiblity( self.Visibility(  ) );
self.CreateActor.setHidden( self.HiddenInGame(  ) );
self.CreateActor.setPhysics( self.SimulatePhysics(  ) );
self.CreateActor.setGravity( self.EnableGravity(  ) );
self.CreateActor.setShadows( self.CastShadow(  ) );

actorLocation = struct(  ...
'translation', single( zeros( 1, 3 ) ),  ...
'rotation', single( zeros( 1, 3 ) ),  ...
'scale', single( ones( 1, 3 ) ) );

translation = self.Translation(  );
rotation = self.Rotation(  );
scale = self.Scale(  );
if ~isempty( translation )
actorLocation.translation = translation;
end 
if ~isempty( rotation )
actorLocation.rotation = rotation;
end 
if ~isempty( scale )
actorLocation.scale = scale;
end 
self.CreateActor.setActorLocation( actorLocation );
self.CreateActor.write;

end 

function onTransformUpdate( self )
R36
self sim3d.AbstractActor
end 
if ~isempty( self.TransformWriter )
[ translation, rotation, scale ] = self.Transform.get(  );
self.TransformWriter.write( translation, rotation, scale );
end 
end 

end 

methods ( Access = public, Hidden = true )

function setup( self )

self.createGameActor(  );
self.TransformReader = sim3d.io.ActorTransformReader( self.getTag(  ), self.getNumberOfParts(  ) );
self.TransformWriter = sim3d.io.ActorTransformWriter( self.getTag(  ), self.getNumberOfParts(  ) );
self.RemoveActorPublisher = sim3d.utils.RemoveActor;
end 

function reset( self )


if ~isempty( self.TransformWriter )
[ translation, rotation, scale ] = self.Transform.get(  );
self.TransformWriter.write( translation, rotation, scale );
end 
end 

function output( self )
childList = self.getChildList(  );
if ~isempty( childList )
for i = 1:numel( childList )
self.Children.( childList{ i } ).output(  );
end 
end 
end 

function update( self )
childList = self.getChildList(  );
if ~isempty( childList )
for i = 1:numel( childList )
self.Children.( childList{ i } ).update(  );
end 
end 
end 

function remove( self, childFlag )





self.ParentWorld = [  ];
if ~childFlag
self.Parent = [  ];
end 

childList = self.getChildList(  );
if ~isempty( childList )
for i = 1:numel( childList )
self.Children.( childList{ i } ).remove( true );
end 
end 
if ~isempty( self.RemoveActorPublisher )
self.RemoveActorPublisher.setActorName( self.getTag(  ) );
self.RemoveActorPublisher.setRemoveActorType( self.getActorType(  ) );
self.RemoveActorPublisher.write(  );
end 
end 

function setupTree( self )



self.setup(  );
self.reset(  );
childList = self.getChildList(  );
if ~isempty( childList )
for i = 1:numel( childList )
self.Children.( childList{ i } ).setupTree(  );
end 
end 
end 

function updateActorName( self, actorName )
if ( ~isempty( self.ParentWorld ) )
if isfield( self.Parent.Children, actorName )
warning( message( "Actor name not unique" ) );
else 

self.Parent.Children.( actorName ) = self.Parent.Children.( self.ActorName );
self.Parent.Children = rmfield( self.Parent.Children, self.ActorName );
self.ActorName = actorName;
end 
end 
if ( ~isempty( self.Parent ) )
if isfield( self.Parent.Children, actorName )
warning( message( "Actor name not unique" ) );
else 

self.Parent.Children.( actorName ) = self;
self.Parent.Children = rmfield( self.Parent.Children, self.ActorName );
end 

end 

end 

function actorClassId = getActorClassId( self )
actorClassId = self.ActorClassId;
end 

function tag = getParentTag( self )
tag = self.ParentIdentifier;
end 

function childList = getChildList( self )
childList = fieldnames( self.Children );
end 

function value = isfieldi( ~, S, field )
names = fieldnames( S );
isField = strcmpi( field, names );

if any( isField )
value = true;
else 
value = false;
end 
end 

function addChildrenToParentWorld( self )
if ( ~isempty( self.ParentWorld ) )
world = self.ParentWorld;
childList = self.getChildList(  );
if ~isempty( childList )
for i = 1:numel( childList )
child = self.Children.( childList{ i } );
world.add( child );
end 
end 
end 
end 

function parentID = getParentIdentifier( self )
if ~isempty( self.Parent ) && isvalid( self.Parent )
parentID = self.Parent.getTag(  );
else 
parentID = self.ParentIdentifier;
end 
end 

function setGenericActorMobility( ~, ~ )
end 

function tag = getTag( self )
if ( strcmpi( self.ActorName, '' ) || isempty( self.ActorName ) )
tag = sprintf( '%s%d', self.getTagName(  ), self.ObjectIdentifier );
else 
tag = self.ActorName;
end 
end 

function uniqueID = generateUniqueActorID( ~, id )
persistent actorNum;
if nargin == 1
if isempty( actorNum )
actorNum = 1;
else 
actorNum = actorNum + 1;
end 
uniqueID = actorNum;
else 
actorNum = id;
uniqueID = actorNum;
end 
end 

function tagName = getTagName( ~ )
tagName = 'Actor';
end 

function updateActorParent( self, actorName )
if ( ~isempty( self.ParentWorld ) )
if isfield( self.ParentWorld.Actors, actorName )
warning( message( "Actor name not unique" ) );
else 

self.ParentWorld.Actors.( actorName ) = self;
self.ParentWorld.Actors = rmfield( self.ParentWorld.Actors, self.ActorName );
end 
end 

if ( ~isempty( self.Parent ) )
if isfield( self.Parent.Children, actorName )
warning( message( "Actor name not unique" ) );
else 

self.Parent.Children.( actorName ) = self;
self.Parent.Children = rmfield( self.Parent.Children, self.ActorName );
end 

end 
end 

function setParentIdentifier( self, id )
R36
self sim3d.AbstractActor
id char
end 
self.ParentIdentifier = id;
end 

function numberOfParts = getNumberOfParts( self )
numberOfParts = self.NumberOfParts;
end 

function aactorS = getAttributes( self )
aactorS.ActorClassId = self.ActorClassId;
aactorS.Translation = self.Translation;
aactorS.Rotation = self.Rotation;
aactorS.Scale = self.Scale;
aactorS.NumberOfParts = self.NumberOfParts;
aactorS.Mesh = self.Mesh;
aactorS.Mobility = self.Mobility;
aactorS.Visibility = self.Visibility;
aactorS.HiddenInGame = self.HiddenInGame;
aactorS.SimulatePhysics = self.SimulatePhysics;
aactorS.EnableGravity = self.EnableGravity;
aactorS.CastShadow = self.CastShadow;

end 

function setAttributes( self, aactorS )
self.Mobility = aactorS.Mobility;
self.ActorClassId = aactorS.ActorClassId;
self.Translation = aactorS.Translation;
self.Rotation = aactorS.Rotation;
self.Scale = aactorS.Scale;
self.NumberOfParts = aactorS.NumberOfParts;
self.Mesh = aactorS.Mesh;
self.Visibility = aactorS.Visibility;
self.HiddenInGame = aactorS.HiddenInGame;
self.SimulatePhysics = aactorS.SimulatePhysics;
self.EnableGravity = aactorS.EnableGravity;
self.CastShadow = aactorS.CastShadow;

end 

function translation = getTranslation( self )
translation = self.Transform.getTranslation(  );
end 

function rotation = getRotation( self )
rotation = self.Transform.getRotation(  );
end 

function scale = getScale( self )
scale = self.Transform.getScale(  );
end 

function setTranslation( self, translation )
R36
self sim3d.AbstractActor
translation( :, 3 )single
end 
self.Translation = translation;
end 

function setRotation( self, rotation )
R36
self sim3d.AbstractActor
rotation( :, 3 )single
end 
self.Rotation = rotation;
end 

function setScale( self, scale )
R36
self sim3d.AbstractActor
scale( :, 3 )single
end 
self.Scale = scale;
end 

function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.AbstractActor
other( 1, 1 )sim3d.AbstractActor
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end 


self.ActorClassId = other.ActorClassId;
self.ActorType = other.getActorType(  );
self.Mesh = other.Mesh;
self.Mobility = other.Mobility;
self.Visibility = other.Visibility;
self.HiddenInGame = other.HiddenInGame;
self.SimulatePhysics = other.SimulatePhysics;
self.NumberOfParts = other.NumberOfParts;
self.EnableGravity = other.EnableGravity;
self.CastShadow = other.CastShadow;

if UseSourcePosition
self.Translation = other.Translation;
self.Rotation = other.Rotation;
self.Scale = other.Scale;
end 

if CopyChildren && ~isempty( other.Children )
childList = other.getChildList(  );
for i = 1:numel( childList )
otherchild = other.Children.( childList{ i } );
newchild = sim3d.ActorFactory.create( otherchild );
newchild.copy( otherchild, true, true );
self.addChild( newchild );
end 
end 
end 

function propagate( self, PropName, PropValue, Condition )

















R36
self( 1, : )sim3d.AbstractActor
PropName( 1, : )char
PropValue
Condition{ mustBeMember( Condition, { 'all', 'children', 'selected', 'unselected' } ) } = 'all'
end 

switch Condition
case 'all'
if isprop( self, PropName )
self.( PropName ) = PropValue;
end 
case 'children'
Condition = 'all';
case 'selected'
if isprop( self, 'Selected' ) && isprop( self, 'PropName' )
if self.Selected
self.( PropName ) = PropValue;
end 
end 
case 'unselected'
if isprop( self, 'Selected' ) && isprop( self, 'PropName' )
if ~self.Selected
self.( PropName ) = PropValue;
end 
end 
end 

if ~isempty( self.Children )
childList = struct2cell( self.Children );
for i = 1:numel( childList )
childList{ i }.propagate( PropName, PropValue, Condition );
end 
end 
end 

function Result = gather( self, PropName, IncludeChildren )













R36
self( 1, 1 )sim3d.AbstractActor
PropName
IncludeChildren( 1, 1 )logical = true
end 

Result = [  ];
if ~isa( self, 'sim3d.internal.RootObject' )
if iscell( PropName )
for i = 1:numel( PropName )
if isprop( self, PropName{ i } )
values{ 1, i } = self.( PropName{ i } );%#ok<AGROW> unknown size
else 
values{ 1, i } = 'invalid';%#ok<AGROW> unknown size
end 
end 
Result = [ { self }, values ];
else 
if isprop( self, PropName )
Result = { self, self.( PropName ) };
else 
Result = { self, 'invalid' };

end 
end 
end 
if IncludeChildren && ~isempty( self.Children )
childList = struct2cell( self.Children );
for i = 1:numel( childList )
subRes = childList{ i }.gather( PropName );
Result = vertcat( Result, subRes );%#ok<AGROW> count depends on search
end 
end 
end 

function removeSnapshot( self, SnapID )

self.Snapshots.removeSnapshot( SnapID );

end 

function States = getSnapshotStates( self )
States = self.Snapshots.getStates(  );
end 

function setSnapshotState( self, States )
self.Snapshots.setStates( States );
end 

function addChild( self, actor )
if isa( self, 'sim3d.AbstractActor' )
actorTag = actor.getTag(  );
self.Children.( actorTag ) = actor;
actor.ParentWorld = self.ParentWorld;
else 

end 
end 

function removeChild( self, child )
if isa( child, 'sim3d.AbstractActor' )
tag = child.getTag(  );
elseif isa( child, 'char' )
tag = child;
else 

end 
if isfield( self.Children, tag )
self.Children = rmfield( self.Children, tag );
else 

end 
end 

function treeStruct = subTreeAsStruct( self )
childList = self.getChildList(  );
childStruct = struct(  );
if ~isempty( childList )
for i = 1:numel( childList )
tag = self.Children.( childList{ i } ).getTag(  );
childStruct.( tag ) = self.Children.( childList{ i } ).subTreeAsStruct(  );
end 
end 
treeStruct = struct( 'Name', self.getTag(  ), 'Children', childStruct );
end 

function ExpStruct = exportAsStruct( self )

if ~isa( self, 'sim3d.internal.RootObject' )

ExpStruct = self.getAttributes(  );
ExpStruct.ActorType = self.getActorType(  );
end 
ExpStruct.Name = self.Name(  );


ExpStruct.States = self.getSnapshotStates;
for j = 1:size( ExpStruct.States, 1 )
data = ExpStruct.States{ j, 4 };
for k = 1:size( data, 1 )
data{ k, 1 } = data{ k, 1 }.getTag(  );
end 
ExpStruct.States{ j, 4 } = data;
end 


childList = self.getChildList(  );
ExpStruct.Children = [  ];
for idx = 1:numel( childList )
child = self.Children.( childList{ idx } );
ExpStruct.Children.( child.getTag ) = exportAsStruct( child );
end 
end 

function importFromStruct( self, inStruct )

if ~strcmp( inStruct.Name, 'SceneOrigin' ) && ~strcmp( inStruct.Name, 'Scene Origin' )

actor = sim3d.ActorFactory.create( inStruct.ActorType );
actor.ActorName = inStruct.Name;
actor.setAttributes( inStruct );
actor.Parent = self;
else 
actor = self;
end 


if ~isempty( inStruct.Children )
childList = fieldnames( inStruct.Children );
for i = 1:numel( childList )
actor.importFromStruct( inStruct.Children.( childList{ i } ) );
end 
end 


States = inStruct.States;
for j = 1:size( States, 1 )
data = States{ j, 4 };
for k = 1:size( data, 1 )
data{ k, 1 } = actor.Parent.findBy( 'Name', data{ k, 1 }, 'first' );
end 
States{ j, 4 } = data;
end 
self.setSnapshotState( States );

end 

function [ translation, rotation, scale ] = readTransform( self )
if ~isempty( self.TransformReader )
[ translation, rotation, scale ] = self.TransformReader.read(  );
else 
translation = [  ];
rotation = [  ];
scale = [  ];
end 
end 

function writeTransform( self )
if ~isempty( self.TransformWriter )
[ translation, rotation, scale ] = self.Transform.get(  );
self.TransformWriter.write( translation, rotation, scale );
end 
end 

function jsonText = sceneGraphToJSON( self )
treeStruct = self.subTreeAsStruct(  );
jsonText = jsonencode( treeStruct );
end 

end 

methods 

function parent = get.Parent( self )
parent = self.Parent;
end 

function world = get.ParentWorld( self )
world = self.ParentWorld;
end 

function set.Parent( self, parent )
if isequal( parent, self.Parent )

return ;
end 
if isequal( parent, [  ] )


if ~isempty( self.Parent ) && isvalid( self.Parent )
self.Parent.removeChild( self.getTag(  ) );
self.Parent = [  ];
self.setParentIdentifier( '' );
return ;
end 
end 
if isvalid( parent ) && isa( parent, 'sim3d.AbstractActor' )

if ~isempty( self.Parent ) && isvalid( self.Parent )
self.Parent.removeChild( self.getTag(  ) );
end 
parent.addChild( self );
self.Parent = parent;
self.setParentIdentifier( parent.getTag(  ) );
else 
error( message( 'shared_sim3d:sim3dAbstractActor:NewParentInvalid' ) );
end 
end 

function set.ParentWorld( self, world )
if isequal( world, [  ] )

if ~isempty( self.ParentWorld ) && isvalid( self.ParentWorld )
self.ParentWorld.Actors = rmfield( self.ParentWorld.Actors, self.getTag(  ) );
end 
self.ParentWorld = [  ];
return ;
end 
if ~isempty( world )
if isa( world, 'sim3d.World' ) && isvalid( world )
if ~isempty( self.ParentWorld )
if isequal( world, self.ParentWorld )

self.addChildrenToParentWorld(  );
return ;
end 
error( message( 'shared_sim3d:sim3dAbstractActor:ActorInDifferentWorld', self.getTag(  ) ) );
end 
tag = self.getTag(  );
if self.isfieldi( world.Actors, tag )
l = namelengthmax;
maxTagLength = l - 10;
if length( tag ) > maxTagLength
tag = tag( end  - maxTagLength:end  );
end 
newActorName = matlab.lang.makeValidName( [ tag, num2str( self.ObjectIdentifier ) ] );
for i = 1:length( newActorName )
isActor = self.isfieldi( world.Actors, newActorName );
if isActor
newActorName = matlab.lang.makeValidName( newActorName( 2:end  ) );
else 
break ;
end 
end 
self.ActorName = newActorName;%#ok

end 
if ( ~strcmp( self.getTag(  ), 'Scene Origin' ) )
world.Actors.( self.getTag(  ) ) = self;
end 
self.ParentWorld = world;
self.addChildrenToParentWorld(  );
else 
error( message( 'shared_sim3d:sim3dAbstractActor:NewWorldInvalid' ) );
end 
end 
end 

function mesh = get.Mesh( self )
mesh = self.Mesh;
end 

function mobility = get.Mobility( self )
mobility = self.Mobility;
end 

function visibility = get.Visibility( self )
visibility = self.Visibility;
end 

function hidden = get.HiddenInGame( self )
hidden = self.HiddenInGame;
end 

function physics = get.SimulatePhysics( self )
physics = self.SimulatePhysics;
end 

function gravity = get.EnableGravity( self )
gravity = self.EnableGravity;
end 

function shadow = get.CastShadow( self )
shadow = self.CastShadow;
end 

function translation = get.Translation( self )
translation = self.getTranslation(  );
end 

function rotation = get.Rotation( self )
rotation = self.getRotation(  );
end 

function scale = get.Scale( self )
scale = self.getScale(  );
end 

function set.Mesh( self, mesh )
self.Mesh = mesh;
end 

function set.Mobility( self, mobility )
self.Mobility = mobility;
setGenericActorMobility( self, mobility );
end 

function set.Visibility( self, visibility )
self.Visibility = visibility;
end 

function set.HiddenInGame( self, hiddenInGame )
self.HiddenInGame = hiddenInGame;
end 

function set.SimulatePhysics( self, simulatePhysics )
self.SimulatePhysics = simulatePhysics;

end 

function set.EnableGravity( self, enableGravity )
self.EnableGravity = enableGravity;
end 

function set.CastShadow( self, castShadow )
self.CastShadow = castShadow;
end 

function set.Translation( self, translation )
R36
self sim3d.AbstractActor
translation( :, 3 )single
end 
status = sim3d.engine.Engine.getState(  );
if status == sim3d.engine.EngineCommands.RUN && ( max( max( abs( self.Transform.getTranslation(  ) - translation ) ) ) > 1e-5 &&  ...
self.Mobility == sim3d.utils.MobilityTypes.Static && class( self ) == "sim3d.Actor" )
warning( message( "shared_sim3d:sim3dAbstractActor:UnsupportedMobilityType" ) );
end 
self.Transform.setTranslation( translation );
self.onTransformUpdate(  );
end 

function set.Rotation( self, rotation )
R36
self sim3d.AbstractActor
rotation( :, 3 )single
end 
status = sim3d.engine.Engine.getState(  );
if status == sim3d.engine.EngineCommands.RUN && ( max( max( abs( self.Transform.getRotation(  ) - rotation ) ) ) > 1e-5 &&  ...
self.Mobility == sim3d.utils.MobilityTypes.Static && class( self ) == "sim3d.Actor" )
warning( message( "shared_sim3d:sim3dAbstractActor:UnsupportedMobilityType" ) );
end 
self.Transform.setRotation( rotation );
self.onTransformUpdate(  );
end 

function set.Scale( self, scale )
R36
self sim3d.AbstractActor
scale( :, 3 )single
end 
self.Transform.setScale( scale );
self.onTransformUpdate(  );
end 

function set.ActorName( self, actorName )
if isempty( actorName ) || strcmpi( actorName, '' )

self.ActorName = self.getTag(  );
else 
if ~isa( self, 'sim3d.internal.RootObject' )

if ~strcmpi( actorName, self.ActorName )
self.updateActorParent( actorName );
end 
end 
self.ActorName = actorName;
end 
end 

function name = get.Name( self )
name = self.getTag(  );
end 

end 

methods ( Abstract )
actorType = getActorType( self );
end 

methods ( Access = private )

function setObjectIdentifier( self, id )
R36
self sim3d.AbstractActor
id uint32
end 
self.ObjectIdentifier = id;
end 

end 

methods ( Access = private, Static )

function r = parseInputs( actorName, varargin )

defaultParams = struct(  ...
'ActorClassId', uint16( sim3d.utils.SemanticType.None ),  ...
'Rotation', single( zeros( 1, 3 ) ),  ...
'Scale', single( ones( 1, 3 ) ),  ...
'Mesh', '',  ...
'Mobility', int32( sim3d.utils.MobilityTypes.Static ),  ...
'Visibility', true,  ...
'HiddenInGame', false,  ...
'SimulatePhysics', false,  ...
'EnableGravity', true,  ...
'CastShadow', false,  ...
'ActorName', actorName,  ...
'NumberOfParts', uint32( 1 ) );


parser = inputParser;
parser.addParameter( 'ActorClassId', defaultParams.ActorClassId );
parser.addParameter( 'ActorName', defaultParams.ActorName );
parser.addParameter( 'NumberOfParts', defaultParams.NumberOfParts );
parser.addParameter( 'Rotation', defaultParams.Rotation );
parser.addParameter( 'Scale', defaultParams.Scale );
parser.addParameter( 'Mesh', defaultParams.Mesh );
parser.addParameter( 'Mobility', defaultParams.Mobility );
parser.addParameter( 'Visibility', defaultParams.Visibility );
parser.addParameter( 'HiddenInGame', defaultParams.HiddenInGame );
parser.addParameter( 'SimulatePhysics', defaultParams.SimulatePhysics );
parser.addParameter( 'EnableGravity', defaultParams.EnableGravity );
parser.addParameter( 'CastShadow', defaultParams.CastShadow );


parser.parse( varargin{ : } );
r = parser.Results;
end 

end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpilU1Y2.p.
% Please follow local copyright laws when handling this file.

