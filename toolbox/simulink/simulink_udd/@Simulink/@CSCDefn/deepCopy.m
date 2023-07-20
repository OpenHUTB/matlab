function hCopy=deepCopy(hObj)





    hCopy=DeepCopy(hObj);




    function hCopy=DeepCopy(hObj)


        hCopy=[];
        if(isempty(hObj))
            return;
        end


        tmp=copy(hObj);


        hprops=Simulink.data.getPropList(hObj,'GetAccess','public','SetAccess','public');

        for p=1:length(hprops)
            propName=hprops(p).Name;
            propVal=hObj.(propName);

            if(Simulink.data.isHandleObject(propVal))

                subObj=DeepCopy(propVal);

                tmp.(propName)=subObj;
            end
        end

        hCopy=tmp;




