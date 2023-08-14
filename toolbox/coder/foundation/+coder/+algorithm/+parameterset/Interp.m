classdef Interp<coder.algorithm.parameterset.AlgorithmParameterSet

    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)

    end

    properties(SetAccess=public,GetAccess=public)
        InterpMethod=coder.algorithm.parameter.InterpMethod('Linear');
        ExtrapMethod=coder.algorithm.parameter.ExtrapMethod('Linear');
        UseRowMajorAlgorithm=coder.algorithm.parameter.UseRowMajorAlgorithm('off');
        RndMeth=coder.algorithm.parameter.RndMeth(...
        {'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'});
        RemoveProtectionIndex=coder.algorithm.parameter.RemoveProtectionIndex({'on','off'});
        SaturateOnIntegerOverflow=coder.algorithm.parameter.SaturateOnIntegerOverflow({'on','off'});
        ValidIndexMayReachLast=coder.algorithm.parameter.ValidIndexMayReachLast({'on','off'});
    end

    methods
        function obj=Interp(varargin)
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

        function obj=set.RemoveProtectionIndex(obj,value)
            obj.RemoveProtectionIndex=obj.RemoveProtectionIndex.setAP(value);
        end

        function obj=set.SaturateOnIntegerOverflow(obj,value)
            obj.SaturateOnIntegerOverflow=obj.SaturateOnIntegerOverflow.setAP(value);
        end

        function obj=set.ValidIndexMayReachLast(obj,value)
            obj.ValidIndexMayReachLast=obj.ValidIndexMayReachLast.setAP(value);
        end

    end
end
