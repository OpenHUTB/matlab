


classdef DirectLookup<coder.algorithm.parameterset.AlgorithmParameterSet

    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)

    end

    properties(SetAccess=public,GetAccess=public)
        NumberOfTableDimensions=coder.algorithm.parameter.NumberOfTableDimensions('2');

        InputsSelectThisObjectFromTable=...
        coder.algorithm.parameter.InputsSelectThisObjectFromTable('Element');

        UseRowMajorAlgorithm=coder.algorithm.parameter.UseRowMajorAlgorithm('off');

        RemoveProtectionInput=coder.algorithm.parameter.RemoveProtectionInput({'on','off'});
    end

    methods

        function obj=DirectLookup(varargin)
            obj=setAlgorithmParameters(obj,varargin);
        end

        function obj=set.NumberOfTableDimensions(obj,value)

            obj.NumberOfTableDimensions=obj.NumberOfTableDimensions.setAP(value);
        end

        function obj=set.InputsSelectThisObjectFromTable(obj,value)

            obj.InputsSelectThisObjectFromTable=...
            obj.InputsSelectThisObjectFromTable.setAP(value);
        end

        function obj=set.UseRowMajorAlgorithm(obj,value)
            obj.UseRowMajorAlgorithm=obj.UseRowMajorAlgorithm.setAP(value);
        end

        function obj=set.RemoveProtectionInput(obj,value)
            obj.RemoveProtectionInput=obj.RemoveProtectionInput.setAP(value);
        end

    end
end

