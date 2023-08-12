function runAnnotateModel( obj )



target = obj.get( 'Tool' );
hModel = obj.getModelName;


preroute = strcmp( obj.CriticalPathSource, 'pre-route' );
numPath = obj.CriticalPathNumber;

if obj.ShowAllPaths
showAll = 'on';
else 
showAll = 'off';
end 

if obj.ShowUniquePaths
showUnique = 'on';
else 
showUnique = 'off';
end 

if obj.ShowDelayData
showDelay = 'on';
else 
showDelay = 'off';
end 

if obj.ShowEndsOnly
showEnds = 'on';
else 
showEnds = 'off';
end 

if preroute
filename = obj.getPostMapTimingReportPath;
else 
filename = obj.getPostPARTimingReportPath;
end 

if ~exist( filename, 'file' )
error( message( 'hdlcoder:workflow:NoTimingFile' ) );
end 


if strcmp( hdlfeature( 'BackAnnotateV2' ), 'on' ) && strcmp( target, 'Xilinx Vivado' )

backannotate(  ...
'model', hModel,  ...
'numCP', str2double( numPath ),  ...
'pathToTimingFile', filename,  ...
'targetPlatform', target,  ...
'showall', showAll,  ...
'unique', showUnique,  ...
'showdelays', showDelay,  ...
'endsonly', showEnds,  ...
'annotateGM', hdlfeature( 'BackAnnotateGM' ) ...
 );
else 

hdlannotatepath( 'model', hModel, numPath, filename,  ...
'targetPlatform', target,  ...
'showall', showAll,  ...
'unique', showUnique,  ...
'showdelays', showDelay,  ...
'endsonly', showEnds );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpngSbVl.p.
% Please follow local copyright laws when handling this file.

