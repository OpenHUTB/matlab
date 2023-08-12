function restoreDesignMdlSettings( obj )




if ~Sldv.utils.isValidContainerMap( obj.SettingsCacheMdlRefMap )
return ;
end 

entries = obj.SettingsCacheMdlRefMap.keys;
for idx = 1:length( entries )
modelName = entries{ idx };
origDirty = get_param( modelName, 'Dirty' );
oc = onCleanup( @(  )set_param( modelName, 'Dirty', origDirty ) );
settingsCache = obj.SettingsCacheMdlRefMap( modelName );
if isfield( settingsCache, 'params' )
paramNames = fields( settingsCache.params );
for jdx = 1:length( paramNames )
set_param( modelName, paramNames{ jdx }, settingsCache.params.( paramNames{ jdx } ) );
end 
end 
if isfield( settingsCache, 'OldConfigSet' )
oldConfigSet = settingsCache.( 'OldConfigSet' );
Sldv.utils.restoreConfigSet( modelName, oldConfigSet );
end 
end 


obj.SettingsCacheMdlRefMap.remove( entries );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6tqHTE.p.
% Please follow local copyright laws when handling this file.

