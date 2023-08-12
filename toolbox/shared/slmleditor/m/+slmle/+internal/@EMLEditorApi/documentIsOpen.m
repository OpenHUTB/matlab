function bool = documentIsOpen( obj, objectId, sid )



R36
obj
objectId
sid = ''
end 

if obj.logger
disp( mfilename );
end 

persistent ISA_SCRIPT;
if ( isempty( ISA_SCRIPT ) )
ISA_SCRIPT = sf( 'get', 'default', 'script.isa' );
end 

if sf( 'get', objectId, '.isa' ) == ISA_SCRIPT

try 
filePath = sf( 'get', objectId, 'script.filePath' );
bool = matlab.desktop.editor.isOpen( filePath );
catch 
bool = false;
end 
return ;
end 



m = slmle.internal.slmlemgr.getInstance;
mlfbeds = m.getMLFBEditorsFromAllStudios( objectId );

bool = ~isempty( mlfbeds );



% Decoded using De-pcode utility v1.2 from file /tmp/tmp4fgGup.p.
% Please follow local copyright laws when handling this file.

