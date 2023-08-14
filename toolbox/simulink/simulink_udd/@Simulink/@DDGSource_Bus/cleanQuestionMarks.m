function[modArray]=cleanQuestionMarks(~,inArray)






    if isempty(inArray)
        modArray=inArray;
    else
        modArray=strrep(inArray,'??? ','');
    end
end

