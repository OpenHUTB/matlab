function destroyComponent( configname, compname, options )

R36
configname{ mustBeTextScalar, mustBeNonempty };
compname;
options.RemoveFromPath{ mustBeNumericOrLogical } = true;
end 


model = dig.config.Model.getOrCreate( configname );
editor = model.openEditor(  );
if ~isempty( compname )
component = editor.getComponent( compname );
if isempty( component )
component = editor.getComponentByPath( compname );
end 
else 
component = editor.getComponentByPath( pwd );
end 

if ~isempty( component )
try 
compfolder = component.Path;
editor.destroyComponent( component.Name, options.RemoveFromPath );
editor.updateModel(  );
editor.save(  );
model.closeEditor(  );
model.Preferences.forgetPath( compfolder );
model.savePreferences(  );
catch ME
model.closeEditor(  );
model.Preferences.forgetPath( compfolder );
model.savePreferences(  );
matlab.internal.regfwk.unregisterResources( compfolder );
model.reload(  );
rethrow( ME );
end 
else 
model.closeEditor(  );
end 
clear model editor;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7gAtXp.p.
% Please follow local copyright laws when handling this file.

