function retVal=getBuiltinListForDataObjects(objType)




    persistent cache


    if~isfield(cache,objType)
        typesForObject=Simulink.DataTypePrmWidget.getDataTypeListForDataObjects(objType);



        for idx=length(typesForObject):-1:1
            if~isvarname(typesForObject{idx})
                typesForObject(idx)=[];
            end
        end

        cache.(objType)=typesForObject;
    end

    retVal=cache.(objType);


