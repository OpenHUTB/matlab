


function members=i_cell2mat(members)
    if iscell(members)
        members=cell2mat(members);
    end
end