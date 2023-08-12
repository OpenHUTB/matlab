function tf = isSubsystemReferenceBlock( obj, options )



















R36
obj
options.Resolve logical = true;
end 

try 
if options.Resolve
objH = slreportgen.utils.getSlSfHandle( obj );
else 
objH = obj;
end 

tf = ~isempty( objH ) && isnumeric( objH ) ...
 && strcmp( get_param( objH, "Type" ), "block" ) ...
 && strcmp( get_param( objH, "BlockType" ), "SubSystem" ) ...
 && ~isempty( get_param( objH, "ReferencedSubsystem" ) );
catch 
tf = false;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzxh6ul.p.
% Please follow local copyright laws when handling this file.

