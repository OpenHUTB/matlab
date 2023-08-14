function hCopy=deepCopy(hObj)





    hCopy=DeepCopy(hObj);




    function hCopy=DeepCopy(hObj)


        hCopy=[];
        if(isempty(hObj))
            return;
        end


        tmp=copy(hObj);


        hclass=classhandle(hObj);
        hprops=hclass.Properties;

        for p=1:length(hprops)
            proptype=hprops(p).DataType;

            if(strcmp(proptype,'handle'))
                propname=hprops(p).Name;
                propval=get(hObj,propname);


                subObj=DeepCopy(propval);

                set(tmp,propname,subObj);
            end
        end

        hCopy=tmp;




