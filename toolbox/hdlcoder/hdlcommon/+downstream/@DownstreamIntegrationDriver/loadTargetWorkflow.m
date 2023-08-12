function loadTargetWorkflow( obj, dutName )
if ( obj.isMLHDLC || obj.queryFlowOnly == downstream.queryflowmodesenum.VIVADOSYSGEN )
return 
end 

obj.errorModelSetting = false;
msg = {  };
obj.loadingFromModel = true;
modelName = bdroot( dutName );





try 
modelWorkflow = hdlget_param( modelName, 'Workflow' );
if ~strcmp( obj.get( 'Workflow' ), modelWorkflow )
obj.set( 'Workflow', modelWorkflow );
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyWorkflowSettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 

obj.loadingFromModel = false;
obj.updateCodegenAndPrjDir;
obj.emitLoadingErrorMsg( modelName, msg );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp8uOgEk.p.
% Please follow local copyright laws when handling this file.

