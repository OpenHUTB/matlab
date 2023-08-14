function isa=isDUTModelReference(dutName)


    isa=false;
    if strcmp(get_param(dutName,'Type'),'block')
        isa=strcmp(get_param(dutName,'blockType'),'ModelReference');
    end

end
