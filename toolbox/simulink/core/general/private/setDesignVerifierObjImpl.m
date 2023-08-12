function setDesignVerifierObjImpl( bd, dv )










if ~Simulink.BlockDiagramAssociatedData.isRegistered( bd.Handle, 'DesignVerifier' )

return ;
end 


Simulink.BlockDiagramAssociatedData.set( bd.Handle, 'DesignVerifier', dv );





if ~( slfeature( 'BigSwitch_DA_U2m' ) )
dv.connect( bd, 'up' );



end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpRW2i_J.p.
% Please follow local copyright laws when handling this file.

