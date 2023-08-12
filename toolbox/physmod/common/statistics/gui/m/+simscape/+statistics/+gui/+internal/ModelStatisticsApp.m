classdef ModelStatisticsApp < handle





properties ( Access = private )
ComponentSelector( 1, 1 )
Refresher( 1, 1 )function_handle = @(  )[  ]
end 

methods 
function obj = ModelStatisticsApp( title, refresher, args )
R36
title( 1, 1 )string = missing
refresher( 1, 1 )function_handle = @(  )[  ];
args.Statistics struct
end 
obj.Refresher = refresher;
obj.buildApp( title, args );
end 

function refresh( obj, args )
R36
obj( 1, 1 )
args.Statistics struct
end 
opt = {  };
if isfield( args, 'Statistics' )
opt = { 'ComponentTree', lComponentTrees( args.Statistics ) };
end 
obj.ComponentSelector.refresh( opt{ : } );
end 

function close( obj )
obj.ComponentSelector.Container.close(  );
delete( obj );
end 
end 

methods ( Access = private )
function obj = buildApp( obj, title, args )
import simscape.statistics.gui.util.internal.ComponentSelectorApp
options = {  };
if isfield( args, 'Statistics' )
options = { 'InitialTree', lComponentTrees( args.Statistics ) };
end 
obj.ComponentSelector = ComponentSelectorApp(  ...
@(  )lComponentTrees( obj.Refresher(  ) ), options{ : } );

obj.ComponentSelector.Container.add( help(  ) );
obj.ComponentSelector.Visible = true;

obj.ComponentSelector.Container.Title = "Simscape Model Statistics";
if ~ismissing( title )
obj.ComponentSelector.Container.Title =  ...
strcat( obj.ComponentSelector.Container.Title, ": ", title );
end 
end 
end 

end 

function qabbtn = help(  )

qabbtn = matlab.ui.internal.toolstrip.qab.QABHelpButton(  );


qabbtn.DocName = 'simscape/StatisticsViewer';

end 

function vn = lComponentTrees( stats )
stats = lAddComponents( stats );
vn = lComponentTree( stats );
end 

function stats = lAddComponents( stats )
import simscape.statistics.gui.util.internal.TextComponent;
import simscape.statistics.gui.internal.GuiComponentRegistry;

v = GuiComponentRegistry.Components;
m = containers.Map( cellstr( [ v.Path ] ), { v.Function } );


for idx = 1:numel( stats )
pth = stats( idx ).Path;
stat = stats( idx ).Statistic;
if isKey( m, pth )
fcn = m( pth );
stats( idx ).Component = fcn( stat.Data );
else 
stats( idx ).Component = TextComponent( Text = stat.Description, Label = stat.Name );
end 
end 
end 

function s = lComponentTree( obj )

import simscape.statistics.gui.util.internal.ComponentTree;
import simscape.statistics.gui.util.internal.TextComponent;
if isempty( obj )
s = repmat( ComponentTree( TextComponent(  ), "x" ), size( obj ) );
else 
s = [  ];
for iObj = 1:numel( obj )
ids = strsplit( obj( iObj ).Path, '.' );
s = lInsert( s, ids, obj( iObj ).Component, obj( iObj ).Statistic.Name );
end 
end 

function s = lInsert( s, ids, component, label )


if isempty( s )
iS = [  ];
else 
iS = strcmp( [ s.ID ], ids( 1 ) );
end 
if ~any( iS )
iS = [ iS, true ];
s = [ s, ComponentTree( TextComponent, ids( 1 ), Label = label ) ];
end 
if numel( ids ) == 1
s( iS ).Component = component;
else 
s( iS ).Children = lInsert( s( iS ).Children, ids( 2:end  ), component, label );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpEgBasr.p.
% Please follow local copyright laws when handling this file.

