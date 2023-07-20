function matches=regexpmatch(array,pattern)





    matches=~cellfun("isempty",regexp(array,pattern,"once","forceCellOutput"));
end
