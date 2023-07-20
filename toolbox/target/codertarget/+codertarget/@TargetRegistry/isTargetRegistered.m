function ret=isTargetRegistered(reg,TargetFileName)




    ret=false;
    if(isa(TargetFileName,'function_handle'))
        for i=1:numel(reg.FcnHandles)
            if isequal(TargetFileName,reg.FcnHandles{i})
                ret=true;
                return;
            end
        end
    else
        TargetIdx=getTargetIdx(reg,TargetFileName);
        if~isempty(TargetIdx)
            ret=true;
        end
    end
end
