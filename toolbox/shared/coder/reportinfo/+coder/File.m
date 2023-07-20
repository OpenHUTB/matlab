classdef File<matlab.mixin.Heterogeneous&handle
















    properties(SetAccess=immutable)
        Path char=''
        Extension char=''
    end

    properties(SetAccess=immutable,Hidden)
        IsMathWorks logical=false
    end

    methods(Access={?codergui.internal.CodegenInfoBuilder,?coder.CodeFile,?coder.ScreenerInfo,?coder.CallSite})
        function obj=File(filePath,extension,isMathWorks)
            if nargin==0
                return
            end
            narginchk(3,3);
            obj.Path=filePath;
            obj.Extension=extension;
            obj.IsMathWorks=isMathWorks;
        end
    end
end
