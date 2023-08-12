function tf = isSubsystemReferenceComponent( hdlOrPathOrElem )






R36
hdlOrPathOrElem{ mustBeA( hdlOrPathOrElem, { 'double', 'char', 'systemcomposer.arch.Component', 'systemcomposer.architecture.model.design.Component' } ) }
end 
handle = systemcomposer.internal.getHandle( hdlOrPathOrElem );


tf = false;
if ~isempty( handle ) && strcmp( get_param( handle, 'Type' ), 'block' )
if strcmp( get_param( handle, 'BlockType' ), 'SubSystem' )
tf = ~isempty( get_param( handle, 'ReferencedSubsystem' ) );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpb8zkry.p.
% Please follow local copyright laws when handling this file.

