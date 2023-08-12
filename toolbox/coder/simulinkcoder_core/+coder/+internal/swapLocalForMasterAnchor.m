function [ updatedPaths, masterShadowPaths ] = swapLocalForMasterAnchor ...
( tokenizedPaths, localAnchor, masterAnchor )














startFolders = regexp( tokenizedPaths, '^\$\(START_DIR\).*$', 'once', 'match' );
startFoldersIdx = ~strcmp( startFolders, '' );
startFolders = startFolders( startFoldersIdx );


masterFolders = strrep( startFolders, '$(START_DIR)', masterAnchor );


startFoldersTokensReplaced = fullfile ...
( localAnchor, regexprep( startFolders, '^\$\(START_DIR\).', '', 'once' ) );
localIdx = true( size( startFolders ) );
for i = 1:length( startFolders )
localIdx( i ) = isfolder( startFoldersTokensReplaced{ i } ) || isfile( startFoldersTokensReplaced{ i } );
end 



useMasterIdx = false( size( tokenizedPaths ) );
useMasterIdx( startFoldersIdx ) = ~localIdx;
updatedPaths = tokenizedPaths;
updatedPaths( useMasterIdx ) = masterFolders( ~localIdx );


masterShadowPaths = masterFolders( localIdx );

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3WEUJa.p.
% Please follow local copyright laws when handling this file.

