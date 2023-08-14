classdef(Abstract)NetworkWrapper




%#codegen

    properties

Network
    end

    properties(SetAccess=private)

NetworkWrapperIdentifier
    end

    methods
        function obj=NetworkWrapper(containsDLNetwork,matFile,varargin)
            coder.allowpcode('plain');
            coder.internal.prefer_const(containsDLNetwork,matFile);

            dlTargetLib=coder.internal.coderNetworkUtils.getTargetLib();

            fieldName=coder.const('');
            if coder.const(strcmp(dlTargetLib,'none'))
                if coder.const(containsDLNetwork)
                    obj.Network=coder.internal.ctarget.dlnetwork(matFile,fieldName,varargin{:});
                else
                    obj.Network=coder.internal.ctarget.DeepLearningNetwork(matFile,fieldName,varargin{:});
                end
            else
                if coder.const(containsDLNetwork)
                    obj.Network=coder.internal.dlnetwork(matFile,fieldName,varargin{:});
                else
                    obj.Network=coder.internal.DeepLearningNetwork(matFile,fieldName,varargin{:});
                end
            end
            obj.NetworkWrapperIdentifier=getNetworkWrapperIdentifier(obj);
            setup(obj);
        end
    end

    methods(Access=private)
        function setup(obj)
            coder.inline('always');
            obj.Network.setupNetworkWrapper(coder.const(obj.NetworkWrapperIdentifier));
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'NetworkWrapperIdentifier'};
        end
    end

    methods(Abstract)
        identifier=getNetworkWrapperIdentifier(obj)
    end
end
