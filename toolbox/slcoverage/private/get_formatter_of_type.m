function id=get_formatter_of_type(types),







    if ischar(types)
        [m,n]=size(types);
        numTypes=zeros(1,m);
        for i=1:m
            numTypes(1,i)=find_formatter_type(types(i,:));
        end
        types=numTypes;
    end

    id=[];
    for type=types(:)',
        id=[id,cv('find','all','formatter.keyNum',type)];
    end
