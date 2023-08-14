function exportR17bToR17a(transformer)






    locRenameAtomicComponentKind(transformer);

    function locRenameAtomicComponentKind(transformer)
        match=M3I.Context;
        match.ParentRoleName='packagedElement';
        match.RoleName='Kind';

        function cs=transform(context)
            cs=M3I.ContextSequence;
            ct=context;
            if strcmp(context.ParentTypeName,'Simulink.metamodel.arplatform.component.AtomicComponent')&&...
                any(strcmp(context.getValue(),{'EcuAbstraction','ComplexDeviceDriver','ServiceProxy'}))
                context.setAttributeValue('Application');
            end
            cs.addContext(ct);
        end
        transformer.addPreTransform(match,@transform);
    end

end


