function [ oDeps ] = mdlRefParseUserDeps( iMdl, iMdlDeps, iVerbose, iTypes )


oDeps = loc_mdlRefParseUserDeps( iMdl, iMdlDeps, iMdlDeps, iVerbose, iTypes );
end 


function [ oDeps ] = loc_mdlRefParseUserDeps( iMdl, iBases, iActuals, iVerbose, iTypes )
nMdlDeps = length( iBases );

oDeps = struct( 'Base', {  }, 'Actual', {  }, 'Type', [  ] );

for i = 1:nMdlDeps
depBase = iBases{ i };
depActual = iActuals{ i };
depType = iTypes( i );




if ( ~isempty( regexp( fileparts( depActual ), '\*', 'once' ) ) )
MSLDiagnostic( 'Simulink:slbuild:ignoringUnfoundDependency',  ...
depActual, iMdl ).reportAsWarning;
continue ;
end 



if ~isempty( regexp( depBase, '^\$MDL', 'once' ) )
mdlDir = get_mdl_dir( iMdl );





depActual = regexprep( depBase, '^\$MDL', '' );
depActual = fullfile( mdlDir, depActual );
end 



depInfo = dir( depActual );
if isempty( depInfo )


[ tmpDep, foundFile, foundBuiltIn ] = sl_get_file_ignoring_builtins( depActual );

if ( ( ~foundFile ) && foundBuiltIn )

continue ;
end 




if foundFile
depActual = tmpDep;
depInfo = dir( depActual );
end 
end 



if isempty( depInfo )
MSLDiagnostic( 'Simulink:slbuild:ignoringUnfoundDependency',  ...
depActual, iMdl ).reportAsWarning;
continue ;
end 


if length( depInfo ) == 1

assert( ~depInfo.isdir,  ...
'Internal Error:  Invalid dependency %s for model iMdl',  ...
depBase, iMdl );

if ( isempty( regexp( depBase, '\*', 'once' ) ) )
oDeps( end  + 1 ).Base = depBase;%#ok<AGROW>
oDeps( end  ).Actual = depActual;
oDeps( end  ).Type = depType;
continue ;
end 
end 








deps = { depInfo( ~[ depInfo.isdir ] ).name };

ndeps = length( deps );
if ndeps == 0
sl_disp_info( DAStudio.message( 'Simulink:slbuild:ignoringDirectoryDependency',  ...
depActual, iMdl ),  ...
iVerbose );
continue ;
end 




if ~isfolder( depActual ), 
depBase = fileparts( depBase );
depActual = fileparts( depActual );
end 




if ( ~isempty( depActual ) )
depBases = strcat( repmat( { [ depBase, filesep ] }, 1, ndeps ), deps );
depActuals = strcat( repmat( { [ depActual, filesep ] }, 1, ndeps ), deps );
else 
depBases = deps;
depActuals = deps;
end 
depTypes = repmat( depType, 1, ndeps );


oNewDeps = loc_mdlRefParseUserDeps( iMdl, depBases, depActuals, iVerbose, depTypes );
oDeps = [ oDeps, oNewDeps ];%#ok<AGROW>
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpkAK3IG.p.
% Please follow local copyright laws when handling this file.

