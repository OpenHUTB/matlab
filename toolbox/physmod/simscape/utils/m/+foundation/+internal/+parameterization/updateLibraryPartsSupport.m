function updateLibraryPartsSupport(lib,libDir)








    libName=getfullname(lib);
    blks=find_system(libName,'BlockType','SimscapeBlock');



    rootPath=fullfile(libDir,[libName,'_parts']);
    for idx=1:numel(blks)
        manufacturers=findManufacturers(rootPath,get_param(blks{idx},'Handle'));
        if~isempty(manufacturers)
            set_param(blks{idx},'SupportsSimscapePartSelection','on');
        end
    end

end
