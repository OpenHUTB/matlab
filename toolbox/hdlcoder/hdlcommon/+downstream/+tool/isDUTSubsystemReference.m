function isa=isDUTSubsystemReference(dutName)


    isa=false;
    if strcmp(get_param(dutName,'Type'),'block')
        if strcmp(get_param(dutName,'blockType'),'SubSystem')
            isa=~isempty(get_param(dutName,'ReferencedSubsystem'));
        end
    end

end