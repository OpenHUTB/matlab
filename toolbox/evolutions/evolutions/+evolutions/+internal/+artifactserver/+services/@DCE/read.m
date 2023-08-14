function cost=read(obj,data)




    key=data.Id;


    if~obj.iskeyInDB(key)
        cost=struct.empty;
        return;
    end


    cost=obj.getFromDb(key);
end
