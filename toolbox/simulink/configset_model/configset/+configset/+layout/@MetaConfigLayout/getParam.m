function out=getParam(obj,name)
    if~obj.MetaCS.isValidParam(name)
        out=[];
    else
        out=obj.MetaCS.getParam(name);
    end

