function isTopLevelDUT=isDUTTopLevel(dutName)


    isTopLevelDUT=strcmp(get_param(dutName,'Type'),'block_diagram');

end
