function setDirtyImpl( obj, part_id, val )


if ~val
warning( 'Simulink:LoadSave:DirtyFlagManager', 'Can''t clear dirty flag' );
end 
m = Simulink.internal.getDirtyFlagManager( obj.Name );
m.setPartDirty( part_id );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLyPuAx.p.
% Please follow local copyright laws when handling this file.

