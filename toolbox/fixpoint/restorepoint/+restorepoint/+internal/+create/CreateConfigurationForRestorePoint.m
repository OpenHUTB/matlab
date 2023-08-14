classdef CreateConfigurationForRestorePoint<restorepoint.internal.create.CreateConfigurationInterface





    methods
        function obj=CreateConfigurationForRestorePoint(createDataStrategy,fileDependencyStrategy,variableDependencyStrategy,storeElementsStrategy,calculatePathStrategy)







            if nargin>0

                obj.CreateDataStrategy=createDataStrategy;
                obj.FileDependencyStrategy=fileDependencyStrategy;
                obj.VariableDependencyStrategy=variableDependencyStrategy;
                obj.StoreElementsStrategy=storeElementsStrategy;
                obj.CalculatePathStrategy=calculatePathStrategy;
            else
                obj.CreateDataStrategy=restorepoint.internal.create.CreateDataRestorePoint;
                obj.FileDependencyStrategy=restorepoint.internal.create.FileDependencyWithSave;
                obj.VariableDependencyStrategy=restorepoint.internal.create.VariableDependencyModelOnly;
                obj.StoreElementsStrategy=restorepoint.internal.create.StoreElementsStandard;
                obj.CalculatePathStrategy=restorepoint.internal.create.CalculatePathRestorePoint;
            end
        end
    end
end
