classdef(Hidden=true)LibUtils

    methods(Static)

        function ret=isCoverageCompatible(libPath)
            narginchk(1,1);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            ret=internal.slcc.cov.slcc_cov_mgr_mex('isCoverageCompatible',char(libPath));
        end


        function ret=getTraceabilityDb(libPath)
            narginchk(1,1);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            ret=internal.slcc.cov.slcc_cov_mgr_mex('getCodeCoverageTraceabilityDb',char(libPath));
        end


        function clearCoverage(libPath)
            narginchk(1,1);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            internal.slcc.cov.slcc_cov_mgr_mex('clearCoverage',char(libPath));
        end


        function initCoverage(libPath,varargin)
            narginchk(1,4);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            internal.slcc.cov.slcc_cov_mgr_mex('initCoverage',char(libPath),varargin{:});
        end


        function termCoverage(libPath)
            narginchk(1,1);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            internal.slcc.cov.slcc_cov_mgr_mex('termCoverage',char(libPath));
        end


        function res=uploadCoverage(libPath)
            narginchk(1,1);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            res=internal.slcc.cov.slcc_cov_mgr_mex('uploadCoverage',char(libPath));
        end


        function loadLibrary(libPath)
            narginchk(1,1);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            internal.slcc.cov.slcc_cov_mgr_mex('loadLibrary',char(libPath));
        end


        function unloadLibrary(libPath)
            narginchk(1,1);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            internal.slcc.cov.slcc_cov_mgr_mex('unloadLibrary',char(libPath));
        end


        function res=isLibraryLoaded(libPath)
            narginchk(1,1);
            validateattributes(libPath,{'string','char'},{'scalartext','nonempty'},1);
            res=internal.slcc.cov.slcc_cov_mgr_mex('isLibraryLoaded',char(libPath));
        end
    end

end


