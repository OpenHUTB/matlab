function dlg=findDDGByTagIdAndTag(tagId,dialogTag)




    dlg=[];


    alldlgsWithTag=findDDGByTag(dialogTag);

    for idx=1:numel(alldlgsWithTag)
        dlgWithTag=alldlgsWithTag(idx);
        if strcmpIfTagPrefixIsProp(dlgWithTag,tagId)

            dlg=dlgWithTag;
            return;
        end
    end
end

function tf=strcmpIfTagPrefixIsProp(dlg,tagId)
    tf=false;
    if isempty(dlg)||~ismethod(dlg,'getSource')||~isprop(dlg.getSource,'TagId')

        return;
    end


    tf=strcmp(dlg.getSource.TagId,tagId);
end


