


function insertData(obj,codeline)
    key=obj.constructKey(codeline);
    if obj.hasData(key)


        obj.sendData('hiliteData',codeline);
    else

        data=cell(1,7);
        data{1}=codeline;
        struct_data=obj.constructStructData(data);
        obj.fCurrentData(key)=struct_data;

        obj.sendData('insertData',{struct_data});
    end

end