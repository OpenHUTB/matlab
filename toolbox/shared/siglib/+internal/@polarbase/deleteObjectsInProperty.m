function deleteObjectsInProperty(p,propName)




    h=p.(propName);



    p.(propName)=[];


    for i=1:numel(h)
        if isvalid(h(i))
            delete(h(i));
        end
    end
