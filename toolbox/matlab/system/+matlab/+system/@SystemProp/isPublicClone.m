function flag=isPublicClone(obj,other)



    flag=strcmp(class(obj),class(other));
    if~flag
        return
    end
    props=getPublicProperties(obj,{'Default','Hidden','Inactive','Dependent'});
    for n=1:length(props)
        prop=props{n};
        propVal=obj.(prop);
        if isa(propVal,'matlab.system.SystemInterface')
            flag=isPublicClone(propVal,other.(prop));
        else
            flag=isequal(propVal,other.(prop));
        end
        if~flag
            return
        end
    end
end
