function object=findObject(this,uuid)






    modelObj=this.model.findElement(uuid);




    if~isempty(modelObj)

        object=this.wrap(modelObj);
    else
        object=[];
    end
end
