function outCell=makeCell(outCell)



    if isempty(outCell)
        outCell=cell.empty;
    elseif~iscell(outCell)
        outCell={outCell};
    end
end