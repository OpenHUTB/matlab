classdef(Sealed)DLCodegenErrorThrower<coder.internal.DLCodegenErrorHandler




    methods

        function handleLayerError(~,~,msg)
            coder.internal.DLCodegenErrorThrower.throwException(msg);
        end

        function handleNetworkError(~,msg)
            coder.internal.DLCodegenErrorThrower.throwException(msg);
        end

    end

    methods(Static,Access=private)

        function throwException(msg)

            error(msg);
        end

    end

end