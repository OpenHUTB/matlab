function interfaces = getSelectedInterfaces( bdName )





R36
bdName = '';
end 

if isempty( bdName )
bdName = bdroot;
end 

interfaces = systemcomposer.InterfaceEditor.SelectedInterfaces( bdName );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpL9oWmg.p.
% Please follow local copyright laws when handling this file.

