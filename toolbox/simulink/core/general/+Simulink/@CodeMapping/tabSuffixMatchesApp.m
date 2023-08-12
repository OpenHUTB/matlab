function match = tabSuffixMatchesApp( studio )




match = false;
modelHandle = studio.App.getActiveEditor.blockDiagramHandle;
[ ~, expectedTabSuffix ] = Simulink.CodeMapping.getTitle( modelHandle );
ss = studio.getComponent( 'GLUE2:SpreadSheet', 'CodeProperties' );
if ss.getTabCount ~= 0
titleView = ss.getTitleView(  );
if isa( titleView, 'DAStudio.Dialog' )
dataViewObj = titleView.getDialogSource;
internalTabName = dataViewObj.m_CurrentTab;
match = contains( internalTabName, expectedTabSuffix );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2Z47Mo.p.
% Please follow local copyright laws when handling this file.

