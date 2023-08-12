




classdef SimulationInputSummarizer
methods ( Static )
function summarize( simIn )
self = MultiSim.internal.SimulationInputSummarizer;


self.stringDisplayer( 'ModelName', simIn.ModelName, true );
self.stringDisplayer( 'InitialState', simIn.InitialState );
self.stringDisplayer( 'ExternalInput', simIn.ExternalInput )
self.tableDisplayer( 'ModelParameters', simIn.ModelParameters );
self.tableDisplayer( 'BlockParameters', simIn.BlockParameters );
self.tableDisplayer( 'Variables', simIn.Variables );
self.stringDisplayer( 'PreSimFcn', simIn.PreSimFcn );
self.stringDisplayer( 'PostSimFcn', simIn.PostSimFcn );
self.stringDisplayer( 'UserString', simIn.UserString );
self.stringDisplayer( 'RuntimeFcns', simIn.RuntimeFcns );
end 
end 

methods ( Static, Access = private )
function str = var2str( var )

displayStruct = matlab.internal.datatoolsservices.getWorkspaceDisplay( { var } );
str = displayStruct.Value;
end 

function dispTitle( titleStr )

if matlab.internal.display.isHot
fprintf( '    <strong>%s: </strong>', titleStr );
else 
fprintf( '    %s: ', titleStr );
end 
end 

function tableDisplayer( titleStr, value )
if ~isempty( value )
MultiSim.internal.SimulationInputSummarizer.dispTitle( titleStr );
fprintf( '\n' );
disp( table( value ) );
fprintf( '\n' );
end 
end 

function stringDisplayer( titleStr, value, dispEmpty )
R36
titleStr
value
dispEmpty( 1, 1 )logical = false
end 

if ~isempty( value ) || dispEmpty
MultiSim.internal.SimulationInputSummarizer.dispTitle( titleStr );
fprintf( MultiSim.internal.SimulationInputSummarizer.var2str( value ) );
fprintf( '\n\n' );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPh_E_l.p.
% Please follow local copyright laws when handling this file.

