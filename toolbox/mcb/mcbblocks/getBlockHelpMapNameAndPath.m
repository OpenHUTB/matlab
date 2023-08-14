function[mapName,relativePathToMapFile,found]=getBlockHelpMapNameAndPath(block_type)





    blks={...
    'mcb_vectorplot','vectorplot'};
    relativePathToMapFile=fullfile(docroot,'mcb','mcb.map');
    found=false;


    idx=strcmp(block_type,blks(:,1));

    if~any(idx)
        mapName='User Defined';
    else
        found='fullpath';
        mapName=blks(idx,2);
    end
end
