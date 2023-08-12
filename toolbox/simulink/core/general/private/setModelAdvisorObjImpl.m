function setModelAdvisorObjImpl( bd, ma )










if ~Simulink.BlockDiagramAssociatedData.isRegistered( bd.Handle, 'ModelAdvisor' )

return ;
end 


Simulink.BlockDiagramAssociatedData.set( bd.Handle, 'ModelAdvisor', ma );





% Decoded using De-pcode utility v1.2 from file /tmp/tmpRWTafb.p.
% Please follow local copyright laws when handling this file.

