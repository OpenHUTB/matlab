function ssref_block_path = getNearestSSRefBlockWithDDAttached( input )












ssref_block_path = '';
if slfeature( 'SLSubsystemSLDD' ) == 0
return ;
end 

assert( isstring( input ) || ischar( input ) );

ssref_block_path = Simulink.SubsystemReference.getNearestParentSubsystemReferenceBlock( input );
while ~isempty( ssref_block_path )
ssref_mdl_name = get_param( ssref_block_path, 'ReferencedSubsystem' );
if ~isempty( ssref_mdl_name ) && ~isempty( get_param( ssref_mdl_name, "DataDictionary" ) )
return ;
end 
ssref_block_path = Simulink.SubsystemReference.getNearestParentSubsystemReferenceBlock( ssref_block_path );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpnNcqlI.p.
% Please follow local copyright laws when handling this file.

