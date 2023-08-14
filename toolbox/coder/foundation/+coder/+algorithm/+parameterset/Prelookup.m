classdef Prelookup<coder.algorithm.parameterset.AlgorithmParameterSet

    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)


    end

    properties(SetAccess=public,GetAccess=public)
        ExtrapMethod=coder.algorithm.parameter.ExtrapMethod('Linear');
        RndMeth=coder.algorithm.parameter.RndMeth(...
        {'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'});
        IndexSearchMethod=coder.algorithm.parameter.IndexSearchMethod(...
        {'Evenly spaced points','Linear search','Binary search'});
        UseLastBreakpoint=coder.algorithm.parameter.UseLastBreakpoint({'on','off'});
        RemoveProtectionInput=coder.algorithm.parameter.RemoveProtectionInput({'on','off'});
        BeginIndexSearchUsingPreviousIndexResult=coder.algorithm.parameter.BeginIndexSearchUsingPreviousIndexResult({'on','off'});
    end

    methods

        function obj=Prelookup(varargin)
            obj=setAlgorithmParameters(obj,varargin);
        end

        function obj=set.ExtrapMethod(obj,value)
            obj.ExtrapMethod=obj.ExtrapMethod.setAP(value);
        end

        function obj=set.RndMeth(obj,value)
            obj.RndMeth=obj.RndMeth.setAP(value);
        end

        function obj=set.IndexSearchMethod(obj,value)
            obj.IndexSearchMethod=obj.IndexSearchMethod.setAP(value);
        end

        function obj=set.UseLastBreakpoint(obj,value)
            obj.UseLastBreakpoint=obj.UseLastBreakpoint.setAP(value);
        end

        function obj=set.RemoveProtectionInput(obj,value)
            obj.RemoveProtectionInput=obj.RemoveProtectionInput.setAP(value);
        end

        function obj=set.BeginIndexSearchUsingPreviousIndexResult(obj,value)
            obj.BeginIndexSearchUsingPreviousIndexResult=obj.BeginIndexSearchUsingPreviousIndexResult.setAP(value);
        end
    end
end

