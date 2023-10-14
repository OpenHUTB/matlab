function web = show( obj, mdl )

arguments
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



