classdef IncompleAOIList<handle





    properties
        AOINames(1,:)cell;
    end

    methods
        function obj=IncompleAOIList()
            obj.AOINames={};
        end

        function insertAOI(obj,aoiName)


            obj.AOINames{end+1}=aoiName;
        end

        function removeAOI(obj,aoiName)


            obj.AOINames(contains(obj.AOINames,aoiName))=[];
        end

        function tf=ismember(obj,aoiName)


            tf=any(contains(obj.AOINames,aoiName));
        end

    end
end


