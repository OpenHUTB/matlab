function index=getIndexNumber(name,list)

    index=0;
    for ii=1:length(list)
        if strcmpi(name,list{ii})
            index=ii-1;
        end
    end

end