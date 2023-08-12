

function [ blockList ] = findBlocksWithMaskTabnames( system )

blockList = find_system( system, 'LookUnderMasks', 'on', 'FollowLinks', 'off',  ...
'LookInsideSubsystemReference', 'off',  ...
'MatchFilter', @Simulink.match.allVariants, 'IncludeCommented', 'on',  ...
'LinkStatus', 'none', 'Mask', 'on' );

tab_names = get_param( blockList, 'MaskTabNameString' );
blockList( strcmp( tab_names, '' ) ) = [  ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfR8_Tl.p.
% Please follow local copyright laws when handling this file.

