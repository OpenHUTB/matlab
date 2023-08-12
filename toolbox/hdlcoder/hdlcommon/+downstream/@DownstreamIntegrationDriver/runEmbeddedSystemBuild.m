function [ status, result, validateCell ] = runEmbeddedSystemBuild( obj )




validateCell = {  };

if obj.isIPCoreGen
if ~obj.isMLHDLC && hdlwfsmartbuild.isSmartbuildOn( obj.isMLHDLC, obj.hCodeGen.ModelName )

smartBuildObj = hdlwfsmartbuild.LogicSynthesisSb.getInstance( obj );
rebuildDecision = smartBuildObj.preprocess;
if rebuildDecision
[ status, result, validateCell ] = obj.hIP.runEmbeddedSystemBuild;
if status
smartBuildObj.postprocessRebuild( result );
end 
else 
[ status, result ] = smartBuildObj.postprocessSkip;
end 
else 
[ status, result, validateCell ] = obj.hIP.runEmbeddedSystemBuild;
end 
else 
error( message( 'hdlcommon:workflow:IPWorkflowOnly', 'runEmbeddedSystemBuild' ) );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmplRNmlO.p.
% Please follow local copyright laws when handling this file.

