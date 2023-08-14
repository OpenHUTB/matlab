function status=openFileSource(fileString)





    status='';
    f=textscan(fileString,'%s','delimiter','|');
    f=f{:};

    pm_assert(numel(f),3);

    opentoline(f{1},str2double(f{2}),str2double(f{3}));

end
