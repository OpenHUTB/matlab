function props=filterStoredIntProperties(obj,props,varargin)





    if(~isobject(obj))
        return;
    end
    dtObj=Simulink.data.getDataTypeObjIfFixpt(obj,varargin{:});
    if isempty(dtObj)
        props(strcmp(props(:),'StoredIntMin'))=[];
        props(strcmp(props(:),'StoredIntMax'))=[];
    end
end