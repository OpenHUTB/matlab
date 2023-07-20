function[modelH,objH,isSf,isSigBuilder]=resolveObj(obj,isResolved)




    if nargin>1&&isResolved==true


        objH=obj;
        isSf=(floor(objH)==objH);
    else
        [isSf,objH,errMsg]=rmi.resolveobj(obj);
        if isempty(objH)
            error(message('Slvnv:reqmgt:rmi:InvalidObject',errMsg));
        end
    end

    if isSf
        modelH=rmisf.getmodelh(objH);
        isSigBuilder=false;
    elseif rmifa.isFaultInfoObj(objH)
        faultInfoObj=rmifa.resolveObjInFaultInfo(objH);
        modelH=get_param(faultInfoObj.getTopModelName,'handle');
        isSigBuilder=false;
    else
        modelH=get_param(bdroot(objH),'Handle');
        if nargout==4
            isSigBuilder=rmisl.is_signal_builder_block(objH);
        end
    end
end

