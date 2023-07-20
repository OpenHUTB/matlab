function rule=identifyBlockBySID(block)















    sid=slexportprevious.utils.escapeSIDFormat(get_param(block,'SID'));
    rule=sprintf('<SID|"%s">',sid);
end
