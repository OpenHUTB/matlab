function strs=resolveMessageStrings(maybeMsgIds)






    strs=cellfun(@(theStr)pm.sli.internal.resolveMessageString(theStr),...
    maybeMsgIds,'UniformOutput',false);

end
