classdef CustomDisplayBase<handle&matlab.mixin.CustomDisplay





%#codegen

    methods(Hidden,Static)
        function name=matlabCodegenRedirect(~)


            coder.allowpcode("plain");

            name='matlabshared.satellitescenario.coder.internal.CustomDisplayCG';
        end
    end
end

