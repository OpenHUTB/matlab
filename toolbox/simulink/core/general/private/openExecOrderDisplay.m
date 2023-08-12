function openExecOrderDisplay( varargin )








taskIdx =  - 1;
if nargin == 1
model = varargin{ 1 };
elseif nargin == 2
model = varargin{ 1 };
taskIdx = varargin{ 2 };
else 
disp( 'Invalid number of arguments.' );
return ;
end 

try 

set_param( model, 'ExecutionOrderLegendDisplay', 'on' );
set_param( model, 'SimulationCommand', 'Update' );
studios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
st = studios( 1 );
Simulink.STOSpreadSheet.SortedOrder.launchExecutionOrderViewer( st );


if taskIdx >= 0
compName = char( st.getStudioTag + "ssTaskLegend" );
ssComp = st.getComponent( 'GLUE2:SpreadSheet', compName );
ssSource = ssComp.getSource;
for k = 1:length( ssSource.mTaskData )
if ( ssSource.mTaskData( k ).taskIdx == taskIdx )
sel = ssSource.mTaskData( k );
Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource.handleSelectionChange( ssComp, sel );
return ;
end 
end 
end 
catch 
return ;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpf6_2aN.p.
% Please follow local copyright laws when handling this file.

