function mmap=getMemoryMap(mdl)


    mws=get_param(mdl,'ModelWorkspace');
    if hasVariable(mws,'mmap')
        mmap=getVariable(mws,'mmap');
        if~isa(mmap,'soc.memmap.MemoryMap')
            error(message('soc:memmap:NotAMemMapObj'));
        end
    else

        mmap=[];
    end
end
