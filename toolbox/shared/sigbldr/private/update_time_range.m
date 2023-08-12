
function UD = update_time_range( UD, SBSigSuite, groupIdx, guiOpen )





for grpIter = 1:length( SBSigSuite.Groups )
if any( grpIter == groupIdx )


sigXData = SBSigSuite.Groups( grpIter ).Signals( 1 ).XData;
if isempty( sigXData )
continue ;
end 


minGrpTime = flintmax;
maxGrpTime =  - flintmax;
for sigIter = 1:length( SBSigSuite.Groups( grpIter ).Signals )
sigXData = SBSigSuite.Groups( grpIter ).Signals( sigIter ).XData;
if isempty( sigXData )

continue ;
end 
minSigTime = min( sigXData );
maxSigTime = max( sigXData );
if minSigTime < minGrpTime
minGrpTime = minSigTime;
end 

if maxSigTime > maxGrpTime
maxGrpTime = maxSigTime;
end 
end 
UD.dataSet( grpIter ).timeRange = [ minGrpTime, maxGrpTime ];
UD.dataSet( grpIter ).displayRange = [ minGrpTime, maxGrpTime ];
SBSigSuite = UD.sbobj;

groupTRangeSet( SBSigSuite, { [ minGrpTime, maxGrpTime ] }, grpIter );

end 
end 


for grpIter = 1:length( SBSigSuite.Groups )
theGroup = SBSigSuite.Groups( grpIter );
if any( grpIter == groupIdx )


sigXData = SBSigSuite.Groups( grpIter ).Signals( 1 ).XData;
if isempty( sigXData )
continue ;
end 

minTime = UD.dataSet( grpIter ).timeRange( 1 );
maxTime = UD.dataSet( grpIter ).timeRange( 2 );
for chIdx = 1:length( UD.channels )
X = theGroup.Signals( chIdx ).XData;
Y = theGroup.Signals( chIdx ).YData;
if ~isempty( X ) || ~isempty( Y )
[ X, Y ] = update_time_data( X( 1 ), X( end  ),  ...
minTime, maxTime, X, Y );
if isempty( X )
theGroup.Signals( chIdx ).YData = Y;
elseif isempty( Y )
theGroup.Signals( chIdx ).XData = X;
else 
theGroup.Signals( chIdx ).XData = X;
theGroup.Signals( chIdx ).YData = Y;
end 
end 
end 

end 
end 

ActiveGroup = UD.sbobj.ActiveGroup;

minTime = UD.dataSet( ActiveGroup ).timeRange( 1 );
maxTime = UD.dataSet( ActiveGroup ).timeRange( 2 );


theGroup = UD.sbobj.Groups( ActiveGroup );
for chIdx = 1:length( UD.channels )
X = theGroup.Signals( chIdx ).XData;
Y = theGroup.Signals( chIdx ).YData;
[ X, Y ] = update_time_data( X( 1 ), X( end  ),  ...
minTime, maxTime, X, Y );

if ( guiOpen )
UD = apply_new_channel_data( UD, chIdx, X, Y, 1 );
end 
end 

UD.common.maxTime = maxTime;
UD.common.minTime = minTime;
if guiOpen && UD.numAxes > 0
UD = set_new_time_range( UD, [ minTime, maxTime ] );
end 

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpqE1FKX.p.
% Please follow local copyright laws when handling this file.

