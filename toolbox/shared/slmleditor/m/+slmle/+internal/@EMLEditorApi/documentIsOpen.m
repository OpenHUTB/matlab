function bool = documentIsOpen( obj, objectId, sid )



arguments
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



