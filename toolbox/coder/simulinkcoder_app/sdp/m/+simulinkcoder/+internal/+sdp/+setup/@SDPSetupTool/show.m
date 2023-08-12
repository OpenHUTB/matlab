function web = show( obj, mdl )

R36
obj
mdl = ''
end 

if isa( obj.dlg, 'DAStudio.Dialog' )
obj.dlg.show;
else 
obj.dlg = DAStudio.Dialog( obj );
end 
web = obj.dlg;

if ~isempty( mdl )

end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpX78NKs.p.
% Please follow local copyright laws when handling this file.

