classdef DatasetStructValueExtractor<MultiSim.internal.DatasetExtractor

    properties(SetAccess=private)
SubField
    end

    methods
        function obj=DatasetStructValueExtractor(outputIdentifier,dataIndex,elementName,repeatIndex,subField)
            obj=obj@MultiSim.internal.DatasetExtractor(outputIdentifier,dataIndex,elementName,repeatIndex);
            obj.SubField=subField;
        end


        function data=getData(obj,simData)
            structData=obj.getSignalData(simData);
            data=NaN;
            if isfield(structData,obj.SubField)
                signalData=structData.(obj.SubField).Data;
                if~isempty(signalData)
                    data=signalData(end);
                end
            end
        end
    end

    methods(Access=protected)
        function fullString=getStringIdentifier(obj)
            fullString=getStringIdentifier@MultiSim.internal.DatasetExtractor(obj)+"."+obj.SubField;
        end
    end
end
