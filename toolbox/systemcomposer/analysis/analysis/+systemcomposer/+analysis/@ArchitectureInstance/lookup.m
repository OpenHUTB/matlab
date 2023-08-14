function instance=lookup(obj,keyType,keyVal)








    instance=[];
    if strcmpi(keyType,"UUID")
        uuid=keyVal;
        instanceElem=this.getModel().findElement(uuid);
        if~isempty(instanceElem)
            instance=obj.getWrapperForImpl(instanceElem);
        end
    elseif strcmpi(keyType,"Path")
        qualifiedName=keyVal;
        instance=obj.findInstanceFromQualifiedName(qualifiedName);
    else
        msgObj=message('SystemArchitecture:API:UnknownLookupKey');
        exception=MException('systemcomposer:API:UnknownLookupKey',msgObj.getString);
        throw(exception);
    end

    if isempty(instance)
        msgObj=message('SystemArchitecture:API:LookupNotInModel');
        exception=MException('systemcomposer:API:LookupNotInModel',...
        msgObj.getString);
        throw(exception);
    end
end
