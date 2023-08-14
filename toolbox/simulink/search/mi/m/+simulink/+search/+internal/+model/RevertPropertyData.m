


classdef RevertPropertyData<simulink.search.internal.model.ReplaceData

    methods(Access=public)
        function obj=RevertPropertyData(propertyName,propertyValue)
            obj@simulink.search.internal.model.ReplaceData(-1,lower(propertyName),propertyValue,{},{});
            obj.name=obj.propertyname;
        end

        function setReplaceWithBitArray(this,replaceData,bitArray)
            setReplaceWithBitArray@simulink.search.internal.model.ReplaceData(this,replaceData,bitArray);
            this.name=lower(replaceData.propertyname);
        end

        function setAfterReplacedByBitArray(this,replaceData,bitArray)
            setAfterReplacedByBitArray@simulink.search.internal.model.ReplaceData(this,replaceData,bitArray);
            this.name=lower(replaceData.propertyname);
        end
    end

    properties(Access=public)

        name=[];
    end
end
