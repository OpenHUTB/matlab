function ma = getModelAdvisorObjImpl( bd )







ma = [  ];

if ~Simulink.BlockDiagramAssociatedData.isRegistered( bd.Handle, 'ModelAdvisor' )

return ;
end 
ma = Simulink.BlockDiagramAssociatedData.get( bd.Handle, 'ModelAdvisor' );
if isempty( ma ) || ~isobject( ma )




try 
ma = Simulink.ModelAdvisor;
catch E
warning( E.identifier, '%s', E.message );
end 
if isempty( ma )
DAStudio.error(  ...
'Simulink:CodeBrowser:ModelAdvisor_UnableToCreateSLAdvisorObj' );
end 

Simulink.BlockDiagramAssociatedData.set( bd.Handle, 'ModelAdvisor', ma );







end 
end 















% Decoded using De-pcode utility v1.2 from file /tmp/tmpgZLVBc.p.
% Please follow local copyright laws when handling this file.

