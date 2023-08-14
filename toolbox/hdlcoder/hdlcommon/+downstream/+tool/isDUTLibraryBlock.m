function isa=isDUTLibraryBlock(dutName)


    isa=false;
    if strcmp(get_param(dutName,'Type'),'block')
        isa=~strcmp(get_param(dutName,'StaticLinkStatus'),'none');
    end

end