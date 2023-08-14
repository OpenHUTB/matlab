function setMemoryMap(mdl,mmap)
    mws=get_param(mdl,'ModelWorkspace');
    mws.assignin('mmap',mmap);
end
