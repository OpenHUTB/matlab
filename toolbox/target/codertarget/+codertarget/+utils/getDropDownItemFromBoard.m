function dropDownItem=getDropDownItemFromBoard(board)





    dropDownItem.str=board.Id;
    dropDownItem.disp=strtrim([board.Manufacturer,' ',board.Name]);
end
