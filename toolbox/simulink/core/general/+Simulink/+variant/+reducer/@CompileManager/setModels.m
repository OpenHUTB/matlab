function setModels(obj,val)




    if~iscell(val)
        val={val};
    end
    obj.Models=unique([obj.Models;val]);
end
