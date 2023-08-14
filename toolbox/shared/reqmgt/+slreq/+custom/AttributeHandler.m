classdef AttributeHandler



    properties(Constant,Hidden)




        ReservedAttributeNames=containers.Map({'index','id','customid','summary','keywords','description','rationale'...
        ,'sid','createdon','createdby','modifiedon','modifiedby','revision','type'},...
        {1,2,3,4,5,6,7,8,9,10,11,12,13,14});
    end

    methods(Static)

        function tf=isReservedName(name)
            tf=isKey(slreq.custom.AttributeHandler.ReservedAttributeNames,lower(name));
        end

        function tf=hasOnlyNameChange(prevEnumList,newEnumList)


            tf=false;
            nPrev=numel(prevEnumList);
            nNew=numel(newEnumList);
            if nNew==nPrev

                reshapedNew=reshape(newEnumList,size(prevEnumList));
                if sum(strcmp(prevEnumList,reshapedNew))==nPrev-1




                    tf=true;
                end
            end
        end
    end
end

