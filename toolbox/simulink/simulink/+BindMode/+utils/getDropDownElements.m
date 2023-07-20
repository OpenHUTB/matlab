

function values=getDropDownElements(modelName)


    bMObj=BindMode.BindMode.getInstance();
    bMSourceDataObj=bMObj.bindModeSourceDataObj;
    if(isprop(bMSourceDataObj,'dropDownElements'))
        values=bMSourceDataObj.dropDownElements;
    else
        values={};
    end
end