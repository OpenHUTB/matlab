


function onTempVarRowSelect(obj,data)

    if~isempty(data)&&~isempty(data.codelines)
        input=obj.prepareHiliteCodeData(data.codelines);

        title=data.name;
        src=slci.view.internal.getSource(obj.getStudio);
        modelName=src.modelName;


        slci.view.internal.hiliteCode(modelName,title,input);
    end