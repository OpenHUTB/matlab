function [ variantBlockInstances, variantBlocks ] = slFindVariantBlocks( systemName )

















narginchk( 1, 1 );
nargoutchk( 0, 2 );


possibleVariants = find_system( systemName,  ...
'FollowLinks', 'on',  ...
'LookUnderMasks', 'all',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
'Regexp', 'on',  ...
'BlockType', '^(?:SubSystem|ModelReference)$' );
inlineVariants = find_system( systemName,  ...
'FollowLinks', 'on',  ...
'LookUnderMasks', 'all',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
'Regexp', 'on',  ...
'BlockType', '^(?:VariantSource|VariantSink)$' );
triggerPorts = find_system( systemName,  ...
'FollowLinks', 'on',  ...
'LookUnderMasks', 'all',  ...
'MatchFilter', @Simulink.match.allVariants,  ...
'Regexp', 'on',  ...
'BlockType', 'TriggerPort' );
variantBlockInstances = find_system( possibleVariants,  ...
'MatchFilter', @Simulink.match.allVariants,  ...
'Variant', 'on' );

for i = 1:length( triggerPorts )
triggerPort = triggerPorts{ i };
try 
if isequal( get_param( triggerPort, 'IsSimulinkFunctin' ), 'on' )
get_param( triggerPort, 'Variant' );
inlineVariants{ end  + 1, 1 } = triggerPort;%#ok
end 
catch 
end 
end 
variantBlockInstances = sort( [ variantBlockInstances;inlineVariants ] );

if nargout == 2

variantBlocksInModel = {  };
variantBlocksInLib = {  };
for i = 1:length( variantBlockInstances )
vBlock = variantBlockInstances{ i };
linkStatus = get_param( vBlock, 'LinkStatus' );
if isequal( linkStatus, 'none' )
variantBlocksInModel{ end  + 1, 1 } = vBlock;%#ok
else 
variantBlocksInLib{ end  + 1, 1 } = get_param( vBlock, 'ReferenceBlock' );%#ok
end 
end 
variantBlocks = unique( [ variantBlocksInModel;variantBlocksInLib ] );
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpcnUYoB.p.
% Please follow local copyright laws when handling this file.

