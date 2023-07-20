function cleanBusName=hCleanBusName(h,busName)





    cleanBusName=regexprep(busName,'^Bus:\s*','');
    cleanBusName=h.hCleanDTOPrefix(cleanBusName);


