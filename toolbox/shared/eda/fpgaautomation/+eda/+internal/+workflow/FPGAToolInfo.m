classdef FPGAToolInfo<handle




    properties(Abstract,SetAccess=protected)
FPGAToolName
FPGAToolCmd
FPGAToolTclShell
FPGAToolProcess

ProjectFileExt
ProgrammingFileExt
NetlistType
FPGABuildProcess
    end

    methods(Abstract,Static)
        checkFPGATool;
    end

    methods
        function result=isFPGAToolRunning(h)
            result=any(cellfun(@lookforprocess,h.FPGAToolProcess));
        end
        function setProgrammingFileExt(h,ext)
            h.ProgrammingFileExt=ext;
        end
    end
end

