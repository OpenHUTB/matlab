classdef RefactorResults<handle
    properties(SetAccess='private',GetAccess='public')
ModelName
ModelDirectory
TraceabilityInfo
    end


    methods
        function obj=RefactorResults(m2mObj)
            if isempty(m2mObj)||~isa(m2mObj,'slEnginePir.m2m_CommonSourceInterpolation')...
                ||~isprop(m2mObj,'fTraceabilityMap')||~isprop(m2mObj,'fModelFilepath')...
                ||~isprop(m2mObj,'fXformDir')

                DAStudio.error('sl_pir_cpp:creator:InvalidRefactorResultInput');
            end
            obj.TraceabilityInfo=m2mObj.fTraceabilityMap;
            if(m2mObj.fInModelXform)
                obj.ModelDirectory=m2mObj.fModelFilepath;
            else
                obj.ModelDirectory=m2mObj.fXformDir;
            end
            obj.ModelName=[m2mObj.fPrefix,m2mObj.fMdl];
        end
    end
end
