function outputCell=filterEmptyCell(inputCell)




    outputCell=inputCell(cellfun(@(x)~isempty(x),inputCell));

end

