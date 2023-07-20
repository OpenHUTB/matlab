





classdef StructExtractor<MultiSim.internal.BaseExtractor

    properties(SetAccess=private)
Field
    end

    properties(Dependent,SetAccess=private)
StringIndex
    end

    methods
        function obj=StructExtractor(outputIdentifier,outputField,outputIndex)
            obj.Identifier=outputIdentifier;
            obj.Field=outputField;
            obj.DataIndex=outputIndex;
        end


        function fullString=get.StringIndex(obj)
            if obj.Field==""
                fullString=obj.Identifier+"("+obj.DataIndex+")";
            else
                fullString=obj.Identifier+"("+obj.DataIndex+") : "+obj.Field;
            end
        end


        function data=getData(obj,simData)
            signalVal=simData.(obj.Identifier).signals(obj.DataIndex).values;
            if~isempty(signalVal)
                data=signalVal(end);
            else
                data=NaN;
            end
        end
    end
end
