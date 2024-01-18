function[result,libSid]=isLibObject(obj,host)

    if isa(obj,'double')
        sfRoot=Stateflow.Root;
        sfObj=sfRoot.idToHandle(obj);
    else
        sfObj=obj;
    end

    libName=strtok(sfObj.Path,'/');

    if nargin==1
        mdlName=strtok(Simulink.ID.getSID(sfObj),':');
    elseif isa(host,'double')
        mdlName=get_param(host,'Name');
    else
        host=convertStringsToChars(host);
        mdlName=host;
    end

    result=~strcmp(mdlName,libName);

    if nargout>1
        if result
            libSid=Simulink.ID.getStateflowSID(sfObj);
        else
            libSid='';
        end
    end
end

