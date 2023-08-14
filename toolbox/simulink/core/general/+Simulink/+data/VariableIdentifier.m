classdef VariableIdentifier<handle









    properties(SetAccess=private,GetAccess=public)
Name
    end
    properties(Hidden=true)
DataSourceId
VariableIdWithinSource

    end
    methods
        function obj=VariableIdentifier(varName,uniqueVarId,dataSrcId)
            obj.Name=varName;
            obj.VariableIdWithinSource=uniqueVarId;
            obj.DataSourceId=dataSrcId;
        end

        function dataSourceFriendlyName=getDataSourceFriendlyName(obj)
            dataSourceFriendlyName=obj.DataSourceId;
        end
    end

    methods(Hidden=true)
        function varObj=sdwTemp_getVariableUsage(obj)

            varObj=Simulink.VariableUsage(obj.Name,obj.DataSourceId);
        end
    end

    methods(Static=true)
        function varIDs=setdiffVarIds(varIDsA,varIDsB)



            varNameAndSourceA=arrayfun(@(x)[x.Name,'+',x.getDataSourceFriendlyName],...
            varIDsA,'UniformOutput',false);
            varNameAndSourceB=arrayfun(@(x)[x.Name,'+',x.getDataSourceFriendlyName],...
            varIDsB,'UniformOutput',false);
            [~,indices]=setdiff(varNameAndSourceA,varNameAndSourceB,'stable');
            varIDs=varIDsA(indices);
        end
    end
end


