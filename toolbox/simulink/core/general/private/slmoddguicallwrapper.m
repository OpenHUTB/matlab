function slmoddguicallwrapper( varargin )




action = varargin{ 1 };
me = daexplr;
im = DAStudio.imExplorer( me );
ctreend = im.getCurrentTreeNode;
assert( ~isempty( ctreend ) );
mdl = ctreend.getParent.getFullName;

if strcmp( action, 'save_modd' )
mws = get_param( mdl, 'ModelWorkspace' );
mws.saveToExternalDictionary(  );
elseif strcmp( action, 'revert_modd' )
set_param( mdl, 'ModelOwnedDictionaryFile', '' );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpEr07Ng.p.
% Please follow local copyright laws when handling this file.

