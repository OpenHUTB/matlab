function result = canEditInMatlab( editorType )











R36
editorType char{ mustBeMember( editorType, { 'any', 'native', 'external' } ) } = 'any'
end 

import( 'matlab.internal.lang.capability.Capability' );
isRemoteClient = ~Capability.isSupported( Capability.LocalClient );

s = settings;
editorSettings = s.matlab.editor;
switch editorType
case 'native'
result = isRemoteClient || ( editorSettings.UseMATLABEditor.ActiveValue &&  ...
matlab.desktop.editor.isEditorAvailable );
case 'external'
result = ~isRemoteClient && ~editorSettings.UseMATLABEditor.ActiveValue &&  ...
~isempty( editorSettings.OtherEditor.ActiveValue );
otherwise 
if isRemoteClient


result = true;
elseif editorSettings.UseMATLABEditor.ActiveValue
result = matlab.desktop.editor.isEditorAvailable;
else 
result = ~isempty( editorSettings.OtherEditor.ActiveValue );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpIFsfKl.p.
% Please follow local copyright laws when handling this file.

