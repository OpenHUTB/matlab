function dasObj=getDasObjFromDataObj(this,dataObj)










    dasObj=[];
    if~isempty(dataObj)
        dasObj=dataObj.getDasObject();
    end

end
