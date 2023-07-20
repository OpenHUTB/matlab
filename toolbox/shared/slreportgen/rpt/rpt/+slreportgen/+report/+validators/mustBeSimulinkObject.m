function mustBeSimulinkObject(obj)
    validObj=isempty(obj)||isValidSlObject(slroot,obj);



    if validObj&&all(ishandle(obj))
        mlreportgen.report.validators.mustBeSingleValue(obj);
    end



    if validObj
        if~isempty(obj)
            objH=slreportgen.utils.getSlSfHandle(obj);
            objHandle=slreportgen.utils.getSlSfObject(objH);
            SlObjList={'block','annotation','port','line','block_diagram'};
            mustBeMember(objHandle.Type,SlObjList);
        end
    end

    if(~validObj)
        error(message("slreportgen:report:error:invalidSLObjectPropertySource"));
    end

end