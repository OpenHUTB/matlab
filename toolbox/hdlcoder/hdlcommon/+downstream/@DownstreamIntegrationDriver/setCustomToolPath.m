function setCustomToolPath( obj, userToolPath )


if ~strcmp( obj.getCustomToolPath, userToolPath )
backToolList = obj.hAvailableToolList.TheAvailableToolList;
try 
obj.hAvailableToolList.buildAvailableToolList( userToolPath )
catch ME

obj.hAvailableToolList.TheAvailableToolList = backToolList;
rethrow( ME );
end 
obj.hAvailableToolList.CustomToolPath = userToolPath;

obj.loadDefaultTool;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpj0Z7RC.p.
% Please follow local copyright laws when handling this file.

