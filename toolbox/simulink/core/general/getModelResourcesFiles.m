function files = getModelResourcesFiles( model )











if isa( model, 'char' )
model = get_param( model, 'Handle' );
end 


files = {  };
hAnnotations = find_system( model,  ...
'FindAll', 'on',  ...
'SkipLinks', 'on',  ...
'LookUnderMasks', 'on',  ...
'IncludeCommented', 'on',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
'type', 'annotation' );


for i = 1:numel( hAnnotations )
annotation = get_param( hAnnotations( i ), 'Object' );
resourcesFiles = annotation.getResourcesFiles(  );
if ~isempty( resourcesFiles )
files = cat( 1, files, resourcesFiles );
end 
end 


hCharts = find_system( model,  ...
'LookUnderMasks', 'all',  ...
'SkipLinks', 'on',  ...
'FollowLinks', 'off',  ...
'IncludeCommented', 'on',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
'MaskType', 'Stateflow' );


for i = 1:numel( hCharts )
chart = idToHandle( sfroot, sfprivate( 'block2chart', hCharts( i ) ) );


if ~isempty( chart )
notes = chart.find( '-isa', 'Stateflow.Note' );

for j = 1:numel( notes )
resourcesFiles = notes( j ).getResourcesFiles(  );
if ~isempty( resourcesFiles )
files = cat( 1, files, resourcesFiles );
end 
end 
end 
end 


files = unique( files );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcW5rUX.p.
% Please follow local copyright laws when handling this file.

