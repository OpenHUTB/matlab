function ret = pmsl_ismodelref( model )


modelCodegenMgr = coder.internal.ModelCodegenMgr.getInstance( model );




ret = ( ~isempty( modelCodegenMgr ) &&  ...
( ~strcmp( modelCodegenMgr.MdlRefBuildArgs.ModelReferenceTargetType, 'NONE' ) ||  ...
modelCodegenMgr.MdlRefBuildArgs.hasModelBlocks ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZsqT7u.p.
% Please follow local copyright laws when handling this file.

