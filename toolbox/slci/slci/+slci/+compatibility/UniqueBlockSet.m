


classdef UniqueBlockSet<handle

    properties(Access=private)
        blockMap=[];
        blockStr='';
        blockCell={};
    end

    methods

        function obj=UniqueBlockSet()
            obj.blockMap=containers.Map('KeyType','double','ValueType','any');
        end

        function AddBlock(aObj,blockH)
            if~aObj.blockMap.isKey(blockH)
                aObj.blockMap(blockH)=blockH;
                if aObj.blockMap.numel>1
                    aObj.blockStr=[aObj.blockStr,', '];
                end
                aObj.blockStr=[aObj.blockStr...
                ,slci.compatibility.getFullBlockName(blockH)];
                aObj.blockCell{end+1}=blockH;
            end
        end

        function out=GetBlockStr(aObj)
            out=aObj.blockStr;
        end

        function out=GetBlockCell(aObj)
            out=aObj.blockCell;
        end

        function out=GetLength(aObj)
            out=numel(aObj.blockCell);
        end
    end

end

