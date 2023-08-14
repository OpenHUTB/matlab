





classdef ArrayExtractor<MultiSim.internal.BaseExtractor

    properties(SetAccess=private)
NumberOfColumns
    end

    properties(Dependent=true,SetAccess=private)
StringIndex
    end

    methods
        function obj=ArrayExtractor(outputIdentifier,outputIndex,numColumns)
            obj.Identifier=outputIdentifier;
            obj.DataIndex=outputIndex;
            obj.NumberOfColumns=numColumns;
        end


        function fullString=get.StringIndex(obj)
            if obj.NumberOfColumns==1
                fullString=string(obj.Identifier);
            else
                fullString=obj.Identifier+"("+obj.DataIndex+")";
            end
        end


        function data=getData(obj,simData)
            if isfield(simData,obj.Identifier)&&~isempty(simData.(obj.Identifier))
                dataArr=simData.(obj.Identifier);
                data=dataArr(end,obj.DataIndex);
            else
                data=NaN;
            end
        end
    end
end
