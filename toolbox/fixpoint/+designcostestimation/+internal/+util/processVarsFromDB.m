function result=processVarsFromDB(dataFromDB)





    rows=size(dataFromDB,2);
    cols=size(dataFromDB{1},2);
    cells=reshape([dataFromDB{:}],cols,rows)';
    result=num2cell(zeros(size(cells,1),7));

    for idx=1:size(cells,1)
        result{idx,1}=string(cells{idx,1});
        result{idx,2}=string(cells{idx,2});
        result{idx,3}=cells{idx,3};
        result{idx,4}=cells{idx,4};
        result{idx,5}=cells{idx,5};
        currBlockName=designcostestimation.internal.util.userSourceLocation(string(cells{idx,6}));
        if(isempty(currBlockName))
            result{idx,6}="";
        else
            result{idx,6}=string(currBlockName);
        end
        result{idx,7}=cells{idx,7};
    end
end