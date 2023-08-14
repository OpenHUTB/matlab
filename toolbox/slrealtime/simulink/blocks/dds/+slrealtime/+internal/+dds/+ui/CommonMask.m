classdef CommonMask






    properties(Constant,Abstract)


MaskType
    end

    properties(Constant,Abstract)












SysObjBlockName
    end

    properties(Constant)

    end

    methods(Static,Abstract)
        dispatch(methodName,varargin)
    end

    methods(Static)

        function out=isLibraryBlock(block)

            parentModel=bdroot(block);
            out=bdIsLibrary(parentModel)||bdIsSubsystem(parentModel);
        end
    end

    methods

    end

    methods(Abstract)
        updateSubsystem(obj,block)



    end

    methods










        function maskInitialize(obj,block)%#ok<INUSD>

        end

    end
end
