function result=inSubsystemReference(objH,isSf)

    if nargin<2||isempty(isSf)
        [isSf,objH,errMsg]=rmi.resolveobj(objH);
        if~isempty(errMsg)
            error(message('Simulink:util:ErrorOfExecutingCommand','rmi.resolveobj()',errMsg));
        end
    end
    refSid=rmisl.getRefSidFromObjSSRefInstance(objH,isSf,false);
    result=~isempty(refSid);
end

