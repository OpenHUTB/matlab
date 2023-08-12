function dv = getDesignVerifierObjImpl( bd )







dv = [  ];
if ~Simulink.BlockDiagramAssociatedData.isRegistered( bd.Handle, 'DesignVerifier' )

return ;
end 
dv = Simulink.BlockDiagramAssociatedData.get( bd.Handle, 'DesignVerifier' );
if isempty( dv ) || ~ishandle( dv )




try 
dv = Simulink.DVOutput( '' );
dv.parent = bd;
catch E
warning( E.identifier, '%s', E.message );
end 
if isempty( dv )
DAStudio.error(  ...
'Simulink:SldvNode:UnableToCreateDVOutputObj' );
end 



Simulink.BlockDiagramAssociatedData.set( bd.Handle, 'DesignVerifier', dv );



blockH = bd.Handle;
Simulink.addBlockDiagramCallback( blockH, 'PreDestroy',  ...
'DesignVerifier', @(  )i_disconnect( blockH ) );
end 
end 

function i_disconnect( bdhandle )




end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTTdn2w.p.
% Please follow local copyright laws when handling this file.

