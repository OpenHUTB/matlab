function [ srcFilesToSkip, buildInfoUpToDate ] =  ...
updateBuildInfoForInstr( buildInfo, isIdeLink, lIsSilAndPws )




srcFilesToSkip = {  };


buildInfoUpToDate = false;


if lIsSilAndPws


addDefines( buildInfo, '-DPORTABLE_WORDSIZES', 'OPTS' );


srcFilesToSkip = getSourceFiles( buildInfo, true, true,  ...
{ 'SkipForInTheLoop', 'SkipForSil' } );

rtw.pil.BuildInfoHelpers.updateBuildInfoToSkipLinkLibsAndOptions( buildInfo );

if isIdeLink



tgtInfo = getTgtPrefInfo( buildInfo.ModelName );
srcFilesToSkip = [ srcFilesToSkip( : );tgtInfo.chipInfo.src( : ) ];







if ispc
group = 'rtwshared.lib';
else 
group = 'rtwshared.a';
end 

sourceFilesShared = getSourceFiles( buildInfo, true, true, group );
srcFilesToSkip = [ srcFilesToSkip( : );sourceFilesShared( : ) ];
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpT0bZ3f.p.
% Please follow local copyright laws when handling this file.

