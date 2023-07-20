classdef ParameterMergeOverride<handle



    methods(Static)

        function doParameterOverride(parameterList)
            fcn=slxmlcomp.internal.merge.ParameterMergeOverride.getAndSetParamterOveride();
            fcn(parameterList);
        end

        function returnArgument=getAndSetParamterOveride(newOverride)
            narginchk(0,1);

            persistent override;

            if isempty(override)
                override=@doNothing;
            end

            returnArgument=override;

            if nargin==1
                override=newOverride;
            end
        end

    end

end


function doNothing(~)

end