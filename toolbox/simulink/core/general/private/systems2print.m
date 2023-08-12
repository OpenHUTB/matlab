function [ systems, resolved, unresolved ] = systems2print( sys, direction, lookUnderMask, expandLibLinks )


if ischar( sys )
sys = get_param( sys, 'Handle' );
end 

resolved = [  ];
unresolved = [  ];

if strcmp( direction, 'AllSystems' )
if ishandle( sys )
sys = bdroot( sys );
else 

obj = find( sfroot, 'Id', sys );
if isprop( obj, 'Chart' )
obj = obj.chart;
end 
sys = bdroot( sfprivate( 'chart2block', obj.Id ) );
end 
end 

if ishandle( sys )
obj = get_param( sys, 'Object' );
else 
obj = find( sfroot, 'Id', sys );
end 

switch direction
case 'CurrentSystemAndAbove'
systems = vertcat( find_printable_ancestors( obj ), obj );

case { 'CurrentSystemAndBelow', 'AllSystems' }
if expandLibLinks

if isa( obj, 'Stateflow.Object' )
h = sfprivate( 'chart2block', obj.Id );
else 
h = obj.Handle;
end 
libdata = libinfo( h, 'FollowLinks', 'on', 'LookUnderMasks', 'all' );
load_system( { libdata.Library } );
end 
[ systems, resolved, unresolved ] = find_printable_children( obj, lookUnderMask, expandLibLinks, true );

otherwise 
systems = obj;
end 

systems = unique( systems, 'stable' );
resolved = unique( resolved, 'stable' );
unresolved = unique( unresolved, 'stable' );

end 

function parents = find_printable_ancestors( object )

parents = [  ];
p = object;
while ~isempty( p ) && ~isa( p, 'Simulink.BlockDiagram' )
p = p.getParent;
if is_printable( p )
parents = vertcat( p, parents );%#ok<AGROW>
end 
end 

end 

function [ systems, links, unresolved ] = find_printable_children( object, lookUnderMask, expandLibLinks, objectIsCurrent )


systems = [  ];
links = [  ];
unresolved = [  ];

if ~objectIsCurrent && ~lookUnderMask && is_masked( object )
return ;
end 

if is_printable( object )
switch class( object )
case 'Simulink.SubSystem'
if strcmpi( object.LinkStatus, 'resolved' )
if expandLibLinks
links = get_param( object.ReferenceBlock, 'Object' );
end 
return ;
else 
systems = object;
end 

case 'Stateflow.AtomicSubchart'
if object.IsLink
if expandLibLinks
h = sf( 'get', object.Id, '.simulink.blockHandle' );
if ~isempty( h )
slObj = find( slroot, 'handle', h );
if ~isempty( slObj )

[ systems, links, unresolved ] = find_printable_children( slObj, lookUnderMask, expandLibLinks, false );
end 
end 
end 
return ;
else 
systems = object.Chart;
end 

case 'Stateflow.LinkChart'
if expandLibLinks
slObj = get_param( object.Path, 'Object' );

[ systems, links, unresolved ] = find_printable_children( slObj, lookUnderMask, expandLibLinks, false );
end 
return ;

otherwise 
systems = object;
end 
end 

subs = object.getHierarchicalChildren;
n = length( subs );
for i = 1:n
[ s, l, u ] = find_printable_children( subs( i ), lookUnderMask, expandLibLinks, false );
if ~isempty( s )
systems = vertcat( systems, s );%#ok<AGROW>
end 
if ~isempty( l )
links = vertcat( links, l );%#ok<AGROW>
end 
if ~isempty( u )
unresolved = vertcat( unresolved, u );%#ok<AGROW>
end 
end 

if expandLibLinks
refs = object.find( '-depth', 1, '-isa', 'Simulink.Reference' );
if ~isempty( refs )
unresolved = vertcat( unresolved, refs );
end 
end 

end 

function masked = is_masked( object )

masked = false;

if isa( object, 'Stateflow.Chart' )
h = sfprivate( 'chart2block', object.Id );
if ~isempty( h )
object = find( slroot, 'handle', h );
end 
end 

if ~isa( object, 'Simulink.SubSystem' )
return ;
end 

if strcmpi( object.Mask, 'on' )
masked = true;
end 

end 

function printable = is_printable( object )

printable = false;
switch class( object )
case { 'Simulink.BlockDiagram',  ...
'Simulink.SubSystem',  ...
'Stateflow.Chart',  ...
'Stateflow.AtomicSubchart',  ...
'Stateflow.AtomicBox',  ...
'Stateflow.EMChart',  ...
'Stateflow.LinkChart',  ...
'Stateflow.StateTransitionTableChart',  ...
'Stateflow.TruthTable',  ...
'Stateflow.TruthTableChart',  ...
 }
printable = true;

case { 'Stateflow.State',  ...
'Stateflow.Function',  ...
'Stateflow.Box',  ...
 }
printable = object.IsSubchart;
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpQS1X0L.p.
% Please follow local copyright laws when handling this file.

