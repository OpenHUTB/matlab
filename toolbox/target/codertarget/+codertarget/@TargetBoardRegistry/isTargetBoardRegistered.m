function ret=isTargetBoardRegistered(reg,TargetBoardFileName)




    ret=false;
    if(isa(TargetBoardFileName,'function_handle'))
        for i=1:numel(reg.FcnHandles)
            if isequal(TargetBoardFileName,reg.FcnHandles{i})
                ret=true;
                return;
            end
        end
    else
        TargetBoardIdx=getTargetBoardIdx(reg,TargetBoardFileName);
        if~isempty(TargetBoardIdx)
            ret=true;
        end
    end
end
