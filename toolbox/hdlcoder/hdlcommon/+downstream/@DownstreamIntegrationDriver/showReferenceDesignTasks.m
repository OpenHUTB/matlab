function result = showReferenceDesignTasks( obj )




currentWorkflow = obj.get( 'Workflow' );
if obj.hWorkflowList.isInWorkflowList( currentWorkflow )





hWorkflow = obj.hWorkflowList.getWorkflow( currentWorkflow );
result = hWorkflow.hdlwa_showReferenceDesignTasks;

elseif obj.isIPCoreGen && ~obj.isBoardEmpty


result = ~obj.isGenericIPPlatform;

else 
result = false;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUBIcEZ.p.
% Please follow local copyright laws when handling this file.

