function setPropertyValue(obj,propSetUsageName,propName,value,units)



    if(isa(obj,'systemcomposer.base.StereotypableElement'))
        elem=obj.getImpl;
    else
        elem=obj;
    end
    if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
        elem=elem.getArchitecture;
    end

    if(nargin>4)
        elem.setPropVal([char(propSetUsageName),'.',char(propName)],value,units);
    else
        elem.setPropVal([char(propSetUsageName),'.',char(propName)],value);
    end
end