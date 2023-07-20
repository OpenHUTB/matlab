function s=copystruct(astruct,numcopies)
    s=cell(numcopies,1);
    for i=1:numcopies
        s{i}=astruct;
    end
end