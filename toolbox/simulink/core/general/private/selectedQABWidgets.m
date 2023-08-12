function selected = selectedQABWidgets(  )
mgr = SLStudio.QABManager.get(  );
defaultWidgets = mgr.getDefaultWidgets(  );
visibleEntries = defaultWidgets.getVisibleEntries(  );
selected = cellfun( @( x )x.Name, visibleEntries, 'UniformOutput', false );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptSjSNy.p.
% Please follow local copyright laws when handling this file.

