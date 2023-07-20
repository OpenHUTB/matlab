function[matchingObject,index]=getObjectArrayElementByName(elementName,objArray)






    index=0;
    matchingObject=[];
    for i=1:numel(objArray)
        if iscell(objArray)
            obj=objArray{i};
        else
            obj=objArray(i);
        end
        assert(isprop(obj,'Name'),'You cannot use ''getObjectArrayElementByName'' for array elements that do not have the property ''Name''.')
        if isprop(obj,'Name')&&isequal(elementName,obj.Name)
            matchingObject=obj;
            index=i;
            return;
        end
    end
end
