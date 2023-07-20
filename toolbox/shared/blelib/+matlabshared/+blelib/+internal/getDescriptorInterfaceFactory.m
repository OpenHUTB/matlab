function[rinterface,winterface]=getDescriptorInterfaceFactory(attributes)





    rinterface=matlabshared.blelib.read.descriptor.Default;
    winterface=matlabshared.blelib.write.descriptor.Default;

    if ismember("Read",attributes)
        rinterface=matlabshared.blelib.read.descriptor.Read;
    end

    if ismember("Write",attributes)
        winterface=matlabshared.blelib.write.descriptor.Write;
    end
end