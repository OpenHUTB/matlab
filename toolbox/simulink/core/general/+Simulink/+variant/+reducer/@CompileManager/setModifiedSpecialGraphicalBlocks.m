function setModifiedSpecialGraphicalBlocks(obj,val)








    if isempty(obj.ModifiedSpecialGraphicalBlocks)
        obj.ModifiedSpecialGraphicalBlocks=val;
        return;
    end



    existingBlocks=arrayfun(@(x)(x.BlockPath),obj.ModifiedSpecialGraphicalBlocks,...
    'UniformOutput',false);
    for ii=1:length(val)
        idx=find(strcmp(val(ii).BlockPath,existingBlocks),1);
        if isempty(idx)
            obj.ModifiedSpecialGraphicalBlocks=[obj.ModifiedSpecialGraphicalBlocks;val(ii)];
        end
    end
end

