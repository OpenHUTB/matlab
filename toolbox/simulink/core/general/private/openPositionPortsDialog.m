function openPositionPortsDialog( blkH )




assert( slfeature( 'FlexiblePortPlacementInfrastructure' ) >= 1 )
assert( slfeature( 'SubsystemFlexiblePortPlacement' ) >= 1 )

assert( is_simulink_handle( blkH ) );
assert( strcmp( get_param( blkH, 'Type' ), 'block' ) );
assert( any( strcmp( get_param( blkH, 'BlockType' ), { 'SubSystem', 'ModelReference' } ) ) );

flexibleportplacement.dialog.Factory.createDialog( blkH );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpDUO8lL.p.
% Please follow local copyright laws when handling this file.

