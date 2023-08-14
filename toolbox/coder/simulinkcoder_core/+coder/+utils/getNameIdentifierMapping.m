function result=getNameIdentifierMapping(modelOrBuildDir)



    result=containers.Map;

    codeDescriptor=coder.getCodeDescriptor(modelOrBuildDir);

    params=codeDescriptor.getDataInterfaces('Parameters');
    for i=1:length(params)
        name=params(i).GraphicalName;
        impl=params(i).Implementation;
        switch class(impl)
        case 'coder.descriptor.Variable'
            identifier=impl.Identifier;
        case 'coder.descriptor.AutosarCalibration'
            identifier=impl.ElementName;
        case 'coder.descriptor.StructExpression'
            identifier=impl.ElementIdentifier;
        otherwise
            identifier='';
        end
        result(name)=identifier;
    end

end

