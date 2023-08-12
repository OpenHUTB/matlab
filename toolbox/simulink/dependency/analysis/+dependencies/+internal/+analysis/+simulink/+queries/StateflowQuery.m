classdef StateflowQuery < dependencies.internal.analysis.simulink.queries.AdvancedQuery




properties ( GetAccess = public, SetAccess = immutable )
Type( 1, 1 )string
Parameter( 1, 1 )string
Predicates( 1, : )string
end 

methods ( Static )

function query = createStateQuery( parameter, varargin )
query = dependencies.internal.analysis.simulink.queries.StateflowQuery( "state", parameter, varargin{ : } );
end 

function query = createTransitionQuery( parameter )
query = dependencies.internal.analysis.simulink.queries.StateflowQuery( "transition", parameter );
end 

function query = createEventQuery( parameter )
query = dependencies.internal.analysis.simulink.queries.StateflowQuery( "event", parameter );
end 

function query = createDataQuery( parameter )
query = dependencies.internal.analysis.simulink.queries.StateflowQuery( "data", parameter );
end 

function query = createEnumQuery( parameter )
query = dependencies.internal.analysis.simulink.queries.StateflowQuery( "enum", parameter );
end 

end 

methods ( Access = private )
function query = StateflowQuery( type, parameter, name, value )
R36
type( 1, 1 )string
parameter( 1, 1 )string
end 
R36( Repeating )
name( 1, 1 )string
value( 1, 1 )string
end 
query.Type = type;
query.Parameter = parameter;
query.Predicates = reshape( [ name;value ], 1, [  ] );
end 
end 

methods 
function [ loadSaveQuery, numMatches ] = createLoadSaveQueries( this )
opcPredicate = i_createPredicate( [ "SSID", "*", this.Parameter, "*", this.Predicates ] );
opcValue = Simulink.loadsave.Query( "/Stateflow//" + this.Type + opcPredicate + "/" + this.Parameter );
opcSSID = Simulink.loadsave.Query( "/Stateflow//" + this.Type + opcPredicate + "/SSID" );
opcChart = Simulink.loadsave.Query( "/Stateflow//" + this.Type + opcPredicate + "/SSID" );
opcChart.Modifier = Simulink.loadsave.Modifier.ChartID;

mdlPredicate = i_createPredicate( [ "id", "*", "ssIdNumber", "*", this.Parameter, "*", this.Predicates ] );
mdlValue = Simulink.loadsave.Query( "/Stateflow//" + this.Type + mdlPredicate + "/" + this.Parameter );
mdlSSID = Simulink.loadsave.Query( "/Stateflow//" + this.Type + mdlPredicate + "/ssIdNumber" );
mdlID = Simulink.loadsave.Query( "/Stateflow//" + this.Type + mdlPredicate + "/id" );

loadSaveQuery = { [ opcValue;opcSSID;opcChart;mdlValue;mdlSSID;mdlID ],  ...
{ 'slx';'slx';'slx';'mdl';'mdl';'mdl' } };
numMatches = 3;
end 

function matches = createMatch( ~, handler, node, rawMatches )
import dependencies.internal.analysis.simulink.queries.StateflowOPCMatch
import dependencies.internal.analysis.simulink.queries.StateflowMDLMatch

values = { rawMatches{ 1 }.Value };
ssids = { rawMatches{ 2 }.Value };
ids = { rawMatches{ 3 }.Value };
handlers = repmat( { handler }, size( values ) );
nodes = repmat( { node }, size( values ) );

if isempty( values )
matches = StateflowOPCMatch.empty( 1, 0 );
elseif handler.ModelInfo.IsSLX
matches = cellfun( @StateflowOPCMatch, values, ssids, ids, handlers, nodes );
else 
matches = cellfun( @StateflowMDLMatch, values, ssids, ids, handlers, nodes );
end 
end 
end 

end 


function predicate = i_createPredicate( predicates )
predicate = sprintf( '%s="%s" and ', predicates );
predicate = "[" + predicate( 1:end  - 5 ) + "]";
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpW1y6Ze.p.
% Please follow local copyright laws when handling this file.

