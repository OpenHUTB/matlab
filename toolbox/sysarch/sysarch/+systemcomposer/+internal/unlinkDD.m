function varargout = unlinkDD( modelName )




varargout{ 1 } = 'Success!';


if nargin > 1
error( 'Expected 1 argument' )
end 


set_param( modelName, 'DataDictionary', '' );


allStudios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
studio = allStudios( 1 );
if strcmp( get_param( studio.App.blockDiagramHandle, 'Name' ), modelName )
systemcomposer.createInterfaceEditorComponent( studio, true, true )
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJQT1jV.p.
% Please follow local copyright laws when handling this file.

