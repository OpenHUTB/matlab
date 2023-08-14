function isCellArrayOfStrings(~,arr)





    if(~iscell(arr)||(~isempty(arr)&&~all(cellfun(@ischar,arr))))
        error(message('SimulinkFixedPoint:autoscaling:cellArrayOfStringsExpected','runsToLoad'));
    end


end