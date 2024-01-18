function result=isLibObject(obj)

    result=false;
    for i=1:length(obj)
        theObj=obj(i);
        type=class(theObj);
        if strcmp(type,'double')
            objH=theObj;
            isSf=(floor(objH)==objH);
        elseif strncmp(type,'Simulink.',length('Simulink.'))&&~rmifa.isFaultInfoObj(theObj)
            objH=theObj.Handle;
            isSf=false;
        elseif strncmp(type,'Stateflow.',length('Stateflow.'))
            objH=theObj.Id;
            isSf=true;
        else
            return;
        end

        if isSf
            if objIsLibObject(rmisf.sfinstance(objH))
                result=true;
                return;
            end
        else
            if~strcmp(get_param(objH,'type'),'block_diagram')&&objIsLibObject(objH)
                result=true;
                return;
            end
        end
    end
end


function out=objIsLibObject(objH)
    out=false;
    while true
        objH=get_param(objH,'Parent');
        if strcmp(get_param(objH,'Type'),'block_diagram')
            break;
        else
            linkStatus=get_param(objH,'StaticLinkStatus');
            if strcmp(linkStatus,'inactive')||strcmp(linkStatus,'resolved')
                out=true;
                break;
            end
        end
    end
end

