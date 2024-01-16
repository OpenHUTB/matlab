function addMLPathEntries(mlPathEntries)
    matlabPathEntriesCellArr=cell(mlPathEntries(:));

    if(~isempty(matlabPathEntriesCellArr))
        addpath(matlabPathEntriesCellArr{:},'-end');
    end

end
