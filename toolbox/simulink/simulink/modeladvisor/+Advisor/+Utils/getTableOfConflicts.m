function conflictsTable=getTableOfConflicts(conflicts)






    conflictsTable=[];
    if~isempty(conflicts)
        numRows=numel(conflicts);
        conflictsTable=ModelAdvisor.Table(numRows,1);
        for i=1:numel(conflicts)
            conflictsTable.setEntry(i,1,conflicts(i));
        end
    end
end


