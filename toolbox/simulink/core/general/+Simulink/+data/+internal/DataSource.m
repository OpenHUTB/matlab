classdef DataSource<handle






    properties(Hidden)
IsPersistent
DataSourceId
    end

    methods(Access=public)

        function varIDs=identifyVisibleVariablesOfNumericType(obj,types)
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);

            for i=1:length(types)
                newVarIDs=obj.identifyVisibleVariablesDerivedFromClass(types{i});
                varIDs=[varIDs;newVarIDs];%#ok<*AGROW>
            end
        end
    end

    methods(Access=public,Abstract=true)






        varIDs=identifyVisibleVariables(obj);
        varIDs=identifyVisibleVariablesByClass(obj,classType)
        varIDs=identifyVisibleVariablesDerivedFromClass(obj,baseClassType);



        varIDs=identifyByName(obj,varName)
        isVisible=isVariableVisible(obj,varID);
        value=getVariable(obj,varID)
        varExist=hasVariable(obj,varName)




        success=updateVariable(obj,varID,value)
        success=deleteVariable(obj,varID)
        success=save(obj)
        success=revert(obj)
    end
end
