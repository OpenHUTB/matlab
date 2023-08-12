function old = explicitpartitioning( new )




















persistent defaultexplicitss;
persistent defaultrtb;
persistent defaultrtbdt;
persistent defaultpartitioningview;
persistent defaultpartitionvirtualsubsystems;
persistent defaultdebug;
persistent defaulttest;

isfirstrun = isempty( defaultexplicitss );

load_simulink;



if isstruct( new )
explicitss = new.explicitss;
rtb = new.rtb;
rtbdt = new.rtbdt;
partitioningview = new.partitioningview;
partitionvirtualsubsystems = new.partitionvirtualsubsystems;
debug = new.debug;
test = new.test;
else 
switch new
case 'v1'

rtb = 0;
rtbdt = 2;
partitioningview = 3;
partitionvirtualsubsystems = 0;
explicitss = 1;
debug = slsvTestingHook( 'ScheduleEditorDebug' );
test = slsvTestingHook( 'ScheduleEditorTesting' );
case 'v2'

rtb = 0;
rtbdt = 2;
partitioningview = 7;
partitionvirtualsubsystems = 0;
explicitss = 1;
debug = slsvTestingHook( 'ScheduleEditorDebug' );
test = slsvTestingHook( 'ScheduleEditorTesting' );
case 'on'

rtb = 2;
rtbdt = 2;
partitioningview = 63;
partitionvirtualsubsystems = 1;
explicitss = 3;
debug = slsvTestingHook( 'ScheduleEditorDebug' );
test = slsvTestingHook( 'ScheduleEditorTesting' );
case 'debug'

rtb = slfeature( 'MultiCoreDeterRTB' );
rtbdt = slfeature( 'DirectFeedThruHandlingAtExplicitTaskBoundary' );
partitioningview = slfeature( 'PartitioningView' );
partitionvirtualsubsystems = slfeature( 'PartitionVirtualSubsystems' );
explicitss = slfeature( 'PartitionSubsystems' );
debug = ~slsvTestingHook( 'ScheduleEditorDebug' );
test = ~slsvTestingHook( 'ScheduleEditorTesting' );
case 'off'

explicitss = 1;
rtb = 0;
rtbdt = 0;
partitioningview = 0;
partitionvirtualsubsystems = 0;
debug = slsvTestingHook( 'ScheduleEditorDebug' );
test = slsvTestingHook( 'ScheduleEditorTesting' );
case 'default'

if isfirstrun
fprintf( 'MATLAB is already in the default state\n' );
return 
else 
explicitss = defaultexplicitss;
rtb = defaultrtb;
rtbdt = defaultrtbdt;
partitioningview = defaultpartitioningview;
partitionvirtualsubsystems =  ...
defaultpartitionvirtualsubsystems;
debug = defaultdebug;
test = defaulttest;
end 
case 'current'
printFeature( 'PartitionSubsystems' );
printFeature( 'MultiCoreDeterRTB' );
printFeature( 'DirectFeedThruHandlingAtExplicitTaskBoundary' );
printFeature( 'PartitioningView' );
printFeature( 'PartitionVirtualSubsystems' );
printTestingHook( 'ScheduleEditorDebug' );
printTestingHook( 'ScheduleEditorTesting' );
return 
case 'edit'
edit( mfilename( 'fullpath' ) );
return 
otherwise 
error( 'Invalid option' )
end 
end 


old.explicitss = changeFeature( 'PartitionSubsystems', explicitss );
old.rtb = changeFeature( 'MultiCoreDeterRTB', rtb );
old.rtbdt = changeFeature( 'DirectFeedThruHandlingAtExplicitTaskBoundary', rtbdt );
old.partitioningview = changeFeature( 'PartitioningView', partitioningview );
old.partitionvirtualsubsystems =  ...
changeFeature( 'PartitionVirtualSubsystems', partitionvirtualsubsystems );
old.debug = changeTestingHook( 'ScheduleEditorDebug', debug );
old.test = changeTestingHook( 'ScheduleEditorTesting', test );

if isfirstrun




defaultexplicitss = old.explicitss;
defaultrtb = old.rtb;
defaultrtbdt = old.rtbdt;
defaultpartitioningview = old.partitioningview;
defaultpartitionvirtualsubsystems = old.partitionvirtualsubsystems;
defaultdebug = old.debug;
defaulttest = old.test;
end 
end 

function old = changeFeature( feature, value )


old = slfeature( feature, value );

fprintf( 'Changing %s from value %d to %d\n', feature, old, value );
end 

function old = changeTestingHook( feature, value )


old = slsvTestingHook( feature, value );

fprintf( 'Changing %s from value %d to %d\n', feature, old, value );
end 

function printFeature( feature )

fprintf( '%s = %d\n', feature, slfeature( feature ) );
end 

function printTestingHook( feature )

fprintf( '%s = %d\n', feature, slsvTestingHook( feature ) );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp27APhy.p.
% Please follow local copyright laws when handling this file.

