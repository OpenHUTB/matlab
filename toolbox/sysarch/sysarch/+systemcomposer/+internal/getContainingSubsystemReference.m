function parent=getContainingSubsystemReference(handle)
    parent=get_param(handle,'Parent');
    while~(isempty(parent)||...
        systemcomposer.internal.isSubsystemReferenceComponent(parent))
        parent=get_param(parent,'Parent');
    end
end