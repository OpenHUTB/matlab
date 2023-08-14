function BlkList=convertcell_into_BlkTypeList(input)
    BlkList={};
    tokenLength=length('!@#$%)(*&^');
    for i=1:length(input)
        startIndex=strfind(input{i},'!@#$%)(*&^');
        BlkList{i,1}=input{i}(1:startIndex-1);
        BlkList{i,2}=input{i}(startIndex+tokenLength:end);
    end
end
