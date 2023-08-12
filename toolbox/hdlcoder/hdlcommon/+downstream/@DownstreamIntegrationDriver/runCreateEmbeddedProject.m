function [ status, result ] = runCreateEmbeddedProject( obj )


if obj.isIPCoreGen
if ~obj.isMLHDLC && hdlwfsmartbuild.isSmartbuildOn( obj.isMLHDLC, obj.hCodeGen.ModelName )

smartBuildObj = hdlwfsmartbuild.CreatePrjSb.getInstance( obj );
rebuildDecision = smartBuildObj.preprocess;
if rebuildDecision
[ status, result ] = obj.hIP.createEmbeddedProject;
if status
smartBuildObj.postprocessRebuild( result );
end 
else 
[ status, result ] = smartBuildObj.postprocessSkip;
end 
else 
[ status, result ] = obj.hIP.createEmbeddedProject;
end 
else 
error( message( 'hdlcommon:workflow:IPWorkflowOnly', 'runCreateEmbeddedProject' ) );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpPpOwTT.p.
% Please follow local copyright laws when handling this file.

