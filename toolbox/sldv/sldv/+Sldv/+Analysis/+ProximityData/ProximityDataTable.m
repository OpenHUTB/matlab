classdef ProximityDataTable<handle





    properties
proximityDataArray
    end

    methods
        function obj=ProximityDataTable()

        end

        function initialize(obj)
            obj.proximityDataArray=[];
        end

        function addData(obj,proximityData)









            newEntry=proximityData;
            newEntry.age=0;

            if isempty(obj.proximityDataArray)
                obj.proximityDataArray=newEntry;
            else
                obj.proximityDataArray(end+1)=newEntry;
            end
        end

        function deleteData(obj,targObjIdx)
            [~,index]=obj.getData(targObjIdx);
            if~isempty(index)
                obj.proximityDataArray(index)=[];
            end
        end

        function incrementAge(obj,objIndices)
            for iterator=1:length(objIndices)
                objIdx=objIndices(iterator);
                [data,index]=obj.getData(objIdx);
                data.age=data.age+1;
                obj.proximityDataArray(index)=data;
            end
        end
        function dataTable=getTable(obj)
            dataTable=obj.proximityDataArray;
        end

        function[data,index]=getData(obj,targetObjIdx)
            data=[];
            allProximityData=obj.proximityDataArray;
            index=find([allProximityData.targetObjective]==targetObjIdx);
            if~isempty(index)
                data=obj.proximityDataArray(index);
            end
        end


        function updateHasDecidedNeighbours(obj,closestObjIdx)
            flags=arrayfun(@(proximityEntry)ismember(closestObjIdx,...
            proximityEntry.closestObjIndices),...
            obj.proximityDataArray);
            if any(flags)
                [obj.proximityDataArray(flags).hasDecidedNeighbours]=deal(true);
            end
        end
    end
end


