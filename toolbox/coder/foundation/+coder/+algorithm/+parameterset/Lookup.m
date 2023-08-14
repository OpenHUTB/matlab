classdef Lookup<coder.algorithm.parameterset.AlgorithmParameterSet

    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)

    end

    properties(SetAccess=public,GetAccess=public)
        InterpMethod=coder.algorithm.parameter.InterpMethod('Linear');
        ExtrapMethod=coder.algorithm.parameter.ExtrapMethod('Linear');
        UseRowMajorAlgorithm=coder.algorithm.parameter.UseRowMajorAlgorithm('off');
        RndMeth=coder.algorithm.parameter.RndMeth(...
        {'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'});
        IndexSearchMethod=coder.algorithm.parameter.IndexSearchMethod(...
        {'Evenly spaced points','Linear search','Binary search'});
        UseLastTableValue=coder.algorithm.parameter.UseLastTableValue({'on','off'});
        ApplyFullPrecisionForLinearInterpolation=coder.algorithm.parameter.ApplyFullPrecisionForLinearInterpolation({'on','off'});
        RemoveProtectionInput=coder.algorithm.parameter.RemoveProtectionInput({'on','off'});
        SaturateOnIntegerOverflow=coder.algorithm.parameter.SaturateOnIntegerOverflow({'on','off'});
        SupportTunableTableSize=coder.algorithm.parameter.SupportTunableTableSize({'on','off'});
        BPPower2Spacing=coder.algorithm.parameter.BPPower2Spacing({'on','off'});
        BeginIndexSearchUsingPreviousIndexResult=coder.algorithm.parameter.BeginIndexSearchUsingPreviousIndexResult({'on','off'});
    end

    methods
        function obj=Lookup(varargin)
            obj=setAlgorithmParameters(obj,varargin);
        end

        function obj=set.InterpMethod(obj,value)
            obj.InterpMethod=obj.InterpMethod.setAP(value);
        end

        function obj=set.ExtrapMethod(obj,value)
            obj.ExtrapMethod=obj.ExtrapMethod.setAP(value);
        end

        function obj=set.UseRowMajorAlgorithm(obj,value)
            obj.UseRowMajorAlgorithm=obj.UseRowMajorAlgorithm.setAP(value);
        end

        function obj=set.RndMeth(obj,value)
            obj.RndMeth=obj.RndMeth.setAP(value);
        end

        function obj=set.IndexSearchMethod(obj,value)
            obj.IndexSearchMethod=obj.IndexSearchMethod.setAP(value);
        end

        function obj=set.UseLastTableValue(obj,value)
            obj.UseLastTableValue=obj.UseLastTableValue.setAP(value);
        end

        function obj=set.ApplyFullPrecisionForLinearInterpolation(obj,value)
            obj.ApplyFullPrecisionForLinearInterpolation=obj.ApplyFullPrecisionForLinearInterpolation.setAP(value);
        end

        function obj=set.RemoveProtectionInput(obj,value)
            obj.RemoveProtectionInput=obj.RemoveProtectionInput.setAP(value);
        end

        function obj=set.SaturateOnIntegerOverflow(obj,value)
            obj.SaturateOnIntegerOverflow=obj.SaturateOnIntegerOverflow.setAP(value);
        end

        function obj=set.SupportTunableTableSize(obj,value)
            obj.SupportTunableTableSize=obj.SupportTunableTableSize.setAP(value);
        end

        function obj=set.BPPower2Spacing(obj,value)
            obj.BPPower2Spacing=obj.BPPower2Spacing.setAP(value);
        end

        function obj=set.BeginIndexSearchUsingPreviousIndexResult(obj,value)
            obj.BeginIndexSearchUsingPreviousIndexResult=obj.BeginIndexSearchUsingPreviousIndexResult.setAP(value);
        end

    end
end

