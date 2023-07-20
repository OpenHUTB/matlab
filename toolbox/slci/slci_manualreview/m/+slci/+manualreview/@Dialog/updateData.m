


function updateData(obj,data)
    assert(iscell(data));

    key=obj.constructKey(data{1});
    struct_data=obj.constructStructData(data);
    obj.fCurrentData(key)=struct_data;
end
