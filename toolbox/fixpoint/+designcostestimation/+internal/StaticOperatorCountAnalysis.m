classdef StaticOperatorCountAnalysis<designcostestimation.internal.OperatorCountAnalysis




    methods


        function analyzeThis(~,aCostObj)

            Buildservice=designcostestimation.internal.services.Build(aCostObj.ModelName);
            Buildservice.runService();
            DBservice=designcostestimation.internal.services.DatabaseInterface(aCostObj.ModelName);
            DBservice.Query='select SequenceId,NodeName,NodeValue,NodeExpr,TypeName,Count from NodeCount where NodeValue != ''VAR'';';
            DBservice.runService();
            if isempty(DBservice.Result)
                return;
            end
            aCostObj.setOperatorCount(designcostestimation.internal.util.processResultsFromDB(DBservice.Result,aCostObj.ModelName));
        end
    end
end
