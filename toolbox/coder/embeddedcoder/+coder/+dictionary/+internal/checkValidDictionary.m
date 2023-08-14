function checkValidDictionary(obj,name,varargin)




    checkIfRemoved=true;
    if nargin==3
        checkIfRemoved=varargin{1};
    end
    if~obj.isvalid||(checkIfRemoved&&coder.dictionary.internal.isCoderDictionaryRemoved(obj))
        if ishandle(name)
            name=get_param(name,'Name');
        end
        DAStudio.error('SimulinkCoderApp:data:InvalidDictionary',name);
    end
end
