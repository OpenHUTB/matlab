














classdef ODESimulationData<matlab.mixin.SetGet
    properties(Access=public)
PNames
XNames
        JPatternStates double
        JPatternParams double
        JPatternSens double
        Stoich double
        X0 double
        Sens0 double
        P double
        U double
Code
        UnitMultipliers double
        sensStateInputs double
        sensParamInputs double
        sensOutputs double
        DAE logical
        SensitivityAnalysis logical
        Mass double
X0Objects
PObjects
XUuids
PUuids
        numNonReactingSpeciesWithRateDoses double
        XUCM double
        PUCM double
        speciesIndexToVaryingCompartment double
        speciesIndexToConstantCompartment double
        assignmentVarIndex double
algebraicXUuids
constantXUuids
repeatedXUuids
RepeatedCodeGenerator
InitialCodeGenerator
InitialJacobianFcn
FluxCodeGenerator
ComplexFluxCodeGenerator
Units
        UserSuppliedSensStateInputs double
        UserSuppliedSensParamInputs double
        IARDependencyMatrix double
        IARlhsIdx double

    end

    properties(Access=public,Transient)


PKCompileData
EquationViewData
    end

    properties(SetAccess=private,Dependent)
DependentFiles
    end

    methods(Access=public)
        function obj=ODESimulationData()
        end
    end

    methods
        function value=get.DependentFiles(objArray)
            codeObjects=[SimBiology.internal.Code.Generator.empty,...
            objArray.RepeatedCodeGenerator,...
            objArray.InitialCodeGenerator,...
            objArray.FluxCodeGenerator,...
            objArray.ComplexFluxCodeGenerator];
            value=[codeObjects.DependentFiles];
        end
    end

    methods(Static)






        function obj=loadobj(obj)
            if isempty(obj.UserSuppliedSensStateInputs)&&~isempty(obj.sensStateInputs)
                obj.UserSuppliedSensStateInputs=obj.sensStateInputs;
            end

            if isempty(obj.UserSuppliedSensParamInputs)&&~isempty(obj.sensParamInputs)
                obj.UserSuppliedSensParamInputs=obj.sensParamInputs;
            end
        end
    end
end
