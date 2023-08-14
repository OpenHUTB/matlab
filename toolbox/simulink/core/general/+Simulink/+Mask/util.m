

classdef util
    methods(Static)



        function str=mat2str(mxValue)
            if(ismatrix(mxValue))
                str=mat2str(mxValue);
            else
                str=sprintf('reshape(%s, %s)',mat2str(mxValue(:)'),mat2str(size(mxValue)));
            end
        end
    end
end
