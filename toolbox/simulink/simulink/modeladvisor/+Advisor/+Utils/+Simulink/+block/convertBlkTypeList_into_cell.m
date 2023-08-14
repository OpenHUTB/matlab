function output=convertBlkTypeList_into_cell(BlkList)
    output={};
    ListLength=size(BlkList);
    ListLength=ListLength(1);
    for i=1:ListLength
        output{i}=[BlkList{i,1},'!@#$%)(*&^',BlkList{i,2}];
    end
end
