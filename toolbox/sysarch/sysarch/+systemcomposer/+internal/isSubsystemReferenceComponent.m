function tf = isSubsystemReferenceComponent( hdlOrPathOrElem )

arguments
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

