classdef SupportScalarVarSize<matlab.System




%#codegen
%#ok<*EMCLS>



    methods(Access=protected)
        function out=supportsScalarVarsizeImpl(~)
            coder.allowpcode('plain');
            out=true;
        end
    end
end