function newDescription=retrieveNewLine(description)






    if size(description,1)>1
        description=cellstr(description);
        newDescription=description{1};
        for index=2:numel(description)
            newDescription=sprintf('%s\n%s',newDescription,description{index});
        end
    else
        newDescription=description;
    end
end