function archElem=lookup(obj,keyType,keyVal)











    archElem=[];
    if strcmpi(keyType,"SimulinkHandle")
        archElemI=systemcomposer.utils.getArchitecturePeer(keyVal);
    elseif strcmpi(keyType,"UUID")
        mfM=mf.zero.getModel(obj.Architecture.getImpl);
        archElemI=mfM.findElement(keyVal);
    elseif strcmpi(keyType,"Path")
        archElemI=obj.Architecture.getImpl.findElement(keyVal);
    else
        msgObj=message('SystemArchitecture:API:UnknownLookupKey');
        exception=MException('systemcomposer:API:UnknownLookupKey',msgObj.getString);
        throw(exception);
    end
    if~isempty(archElemI)
        archElem=systemcomposer.internal.getWrapperForImpl(archElemI,"");
        if isempty(archElem)||(isa(archElem,'systemcomposer.base.StereotypableElement')&&~isequal(obj,archElem.Model))
            msgObj=message('SystemArchitecture:API:LookupNotInModel');
            exception=MException('systemcomposer:API:LookupNotInModel',...
            msgObj.getString);
            throw(exception);
        end
    end
end
