function refresh(studio,protoElem)








    import swarch.internal.propertyinspector.*;

    propInspector=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
    if propInspector.isVisible()
        if isa(protoElem,'systemcomposer.architecture.model.swarch.Function')
            schema=FunctionSchema(studio,protoElem);
        elseif isa(protoElem,'systemcomposer.architecture.model.swarch.Task')
            schema=TaskSchema(studio,protoElem);
        elseif isa(protoElem,'systemcomposer.architecture.model.traits.EventChain')
            schema=EventChainSchema(studio,protoElem);
        else
            assert(false,'Invalid Software Element class');
        end
        propInspector.updateSource(schema.getObjectName(),schema);
    end
end
