function fillLinkMappingData(h)








    h.MapOldMaskToCurrent={};
    h.OldMasksCanNotHandle={''};


    for k=1:numel(h.LinkMappingFH)
        try
            items=num2cell(h.LinkMappingFH{k}());
            h.MapOldMaskToCurrent=vertcat(h.MapOldMaskToCurrent,items{:});
        catch e
            warning(e.identifier,'%s',e.message);
        end
    end


    h.OldMaskTypeCell=cellfun(@(in)in.oldMaskType,h.MapOldMaskToCurrent,'UniformOutput',false)';

end
