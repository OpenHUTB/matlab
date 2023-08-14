function result=processResultsFromDB(dataFromDB,model)





    rows=size(dataFromDB,2);
    cols=size(dataFromDB{1},2);
    cells=reshape([dataFromDB{:}],cols,rows)';
    result=num2cell(zeros(size(cells,1),4));
    for idx=1:size(cells,1)

        Operation=[cells{idx,3},'(',cells{idx,4},')'];

        sid=cells{idx,2};
        if(isempty(sid))

            result{idx,1}=model;
        else
            result{idx,1}=designcostestimation.internal.util.userSourceLocation(sid);
        end
        result{idx,2}=cells{idx,6};
        result{idx,3}=Operation;
        result{idx,4}=cells{idx,5};
    end
end


