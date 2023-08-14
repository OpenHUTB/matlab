function retstr=styleguide_look_under_masks(checkTag)















    retstr='graphical';


    idList=getLookUnderMasksIDs();

    idx=strmatch(checkTag,strvcat(idList{1:end,1}));%#ok<VCAT>

    if~isempty(idx)
        retstr=idList{idx,2};
    end
