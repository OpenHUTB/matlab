function fullLibName=getCustomCodeLibFullName(checksum,extType)



    fullLibName='';
    if~isempty(checksum)
        fullLibName=[checksum,'_cclib',cgxeprivate('getLibraryExtension',extType)];
    end
