function data=doorsTableIdsToStrings(module,ids)




    data=cell(size(ids));
    for i=1:size(ids,1)
        for j=1:size(ids,2)
            data{i,j}=rmidoors.getObjAttribute(module,ids(i,j),'textAsHtml');
        end
    end
end
