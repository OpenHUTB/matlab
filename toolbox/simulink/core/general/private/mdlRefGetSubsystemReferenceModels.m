






function oSSRefModels = mdlRefGetSubsystemReferenceModels( iMdl )

ssRefBlks = find_system( iMdl,  ...
'FollowLinks', 'on',  ...
'LookUnderMasks', 'all',  ...
'LookUnderReadProtectedSubsystems', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,  ...
'RegExp', 'on',  ...
'BlockType', 'SubSystem',  ...
'ReferencedSubsystem', '.*' );

oSSRefModels = get_param( ssRefBlks, 'ReferencedSubsystem' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyJytfz.p.
% Please follow local copyright laws when handling this file.

