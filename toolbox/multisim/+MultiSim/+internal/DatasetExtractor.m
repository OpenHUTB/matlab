classdef DatasetExtractor<MultiSim.internal.BaseExtractor

    properties(SetAccess=private)
ElementName
RepeatIndex
    end

    properties(Dependent,SetAccess=private)
StringIndex
    end

    methods
        function obj=DatasetExtractor(outputIdentifier,dataIndex,elementName,repeatIndex)
            obj.Identifier=outputIdentifier;
            obj.DataIndex=dataIndex;
            obj.ElementName=elementName;
            obj.RepeatIndex=repeatIndex;
        end


        function fullString=get.StringIndex(obj)
            fullString=obj.getStringIdentifier();
        end


        function data=getData(obj,simData)
            signalData=obj.getSignalData(simData);
            if~isempty(signalData)&&~isempty(signalData.Data)
                data=signalData.Data(end);
            else
                data=NaN;
            end
        end
    end

    methods(Access=protected)
        function fullString=getStringIdentifier(obj)
            if obj.ElementName==""
                fullString=obj.Identifier+"{"+obj.DataIndex+"}";
            else
                if obj.RepeatIndex>0
                    fullString=obj.Identifier+"."+obj.ElementName+"{"+obj.RepeatIndex+"}";
                else
                    fullString=obj.Identifier+"."+obj.ElementName;
                end
            end
        end

        function signalData=getSignalData(obj,simData)
            if isfield(simData,obj.Identifier)
                data=simData.(obj.Identifier).get(obj.DataIndex);
                signalData=data.Values;
            else
                signalData=[];
            end
        end
    end
end
