function isLink=is_a_link(blockH)




    if isempty(get_param(blockH,'ReferenceBlock')),
        isLink=0;
    else
        isLink=1;
    end;