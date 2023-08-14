function stringOut=makeStringFromCell(cellIn)




    if~isempty(cellIn)
        stringOut=cellIn{1};
        for idx=2:numel(cellIn)
            stringOut=sprintf('%s\n%s',stringOut,cellIn{idx});
        end
    else
        stringOut=char.empty;
    end
end
