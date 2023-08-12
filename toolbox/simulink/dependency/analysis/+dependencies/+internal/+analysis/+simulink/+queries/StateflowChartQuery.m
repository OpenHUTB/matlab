classdef StateflowChartQuery < dependencies.internal.analysis.simulink.queries.AdvancedQuery




properties ( GetAccess = public, SetAccess = immutable )
Type( 1, 1 )string
ID( 1, 1 )string
Predicates( 1, : )string
end 

methods ( Static )
function query = createChartQuery( varargin )
query = dependencies.internal.analysis.simulink.queries.StateflowChartQuery( "chart", "id", varargin{ : } );
end 

function query = createTableQuery( varargin )
query = dependencies.internal.analysis.simulink.queries.StateflowChartQuery( "table", "parent", varargin{ : } );
end 
end 

methods ( Access = private )
function this = StateflowChartQuery( type, id, name, value )
R36
type( 1, 1 )string
id( 1, 1 )string
end 
R36( Repeating )
name( 1, 1 )string
value( 1, 1 )string
end 
this.Type = type;
this.ID = id;
this.Predicates = reshape( [ name;value ], 1, [  ] );
end 
end 

methods 
function [ loadSaveQuery, numMatches ] = createLoadSaveQueries( this )
predicate = i_createPredicate( [ this.ID, "*", this.Predicates ] );
loadSaveQuery = { Simulink.loadsave.Query( "/Stateflow//" + this.Type + predicate + "/" + this.ID ) };
numMatches = 1;
end 

function matches = createMatch( ~, ~, ~, rawMatches )
charts = string( { rawMatches{ 1 }.Value } );
matches = struct( ChartID = {  } );
for n = 1:length( charts )
matches( n ).ChartID = charts( n );
end 
end 
end 

end 


function predicate = i_createPredicate( predicates )
predicate = sprintf( '%s="%s" and ', predicates );
predicate = "[" + predicate( 1:end  - 5 ) + "]";
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvso7xx.p.
% Please follow local copyright laws when handling this file.

