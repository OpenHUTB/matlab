




function out=isSynthDSMFromWSVar(aBlk)
    obj=get_param(aBlk,'Object');



    out=strcmp(obj.BlockType,'DataStoreMemory')...
    &&obj.isSynthesized...
    &&strcmp(obj.StateMustResolveToSignalObject,'on');
end