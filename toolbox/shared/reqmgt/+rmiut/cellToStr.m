function result=cellToStr(cell_array)





    string='';
    for i=1:length(cell_array)
        string=[string,',',cell_array{i}];%#ok
    end
    result=string(2:end);
end
