function newBlk=addLibBlock(libBlkName,dstBlk,varargin)
    coreLibName=slplc.utils.getCoreLibName();
    if~bdIsLoaded(coreLibName)
        load_system(coreLibName);
        c1=onCleanup(@()close_system(coreLibName,0));
    end
    libBlk=[coreLibName,'/',libBlkName];
    newBlk=add_block(libBlk,dstBlk,varargin{:});
end