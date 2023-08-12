function setToolName( obj, toolName )





hOption = obj.getOption( 'Tool' );
oldToolName = hOption.Value;
try 

hOption.Value = toolName;
if obj.isHLSWorkflow


return ;
end 
if strcmpi( toolName, obj.EmptyToolStr ) || strcmpi( toolName, obj.NoAvailableToolStr )

obj.hToolDriver = downstream.ToolDriver( obj );
else 

obj.loadTool( toolName );
end 
catch ME


hOption.Value = oldToolName;
throw( ME );
end 
obj.disp;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjGsMGb.p.
% Please follow local copyright laws when handling this file.

