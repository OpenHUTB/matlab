function objectId=convertToObjectId(id)




    objectId=id;
    try
        h=idToHandle(sfroot,id);
        if isa(h,'Stateflow.EMFunction')
            objectId=id;
        elseif isa(h,'Stateflow.EMChart')
            objectId=sf('get',id,'.states');
        end
    catch
    end