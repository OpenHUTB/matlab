
function[validBoards,fcnHandles]=getValidBoards
    metadata=meta.package.fromName('esb.internal.io');
    if(isempty(metadata)||isempty(metadata.FunctionList))
        validBoards={};
        fcnHandles={};
    else
        fcns={metadata.FunctionList(startsWith({metadata.FunctionList(:).Name},'register')).Name};
        validBoards=strings(1,length(fcns));
        fcnHandles=cell(1,length(fcns));
        for i=1:length(fcns)
            [validBoards(i),fcnHandles{i}]=esb.internal.io.(fcns{i});
        end
    end
end

