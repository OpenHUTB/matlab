function out = getActiveModelName( obj )
if isempty( obj.SourceSubsystem )
out = obj.ModelName;
elseif isValidSlObject( slroot, obj.ModelName ) && ~isempty( coder.internal.ModelCodegenMgr.getInstance( obj.ModelName ) )
out = obj.ModelName;
else 
out = strtok( obj.SourceSubsystem, ':' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpId9XaX.p.
% Please follow local copyright laws when handling this file.

