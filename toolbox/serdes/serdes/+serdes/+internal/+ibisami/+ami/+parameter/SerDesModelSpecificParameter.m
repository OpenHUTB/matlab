classdef SerDesModelSpecificParameter<serdes.internal.ibisami.ami.parameter.ModelSpecificParameter&...
    serdes.internal.ibisami.ami.SerDesNode






    properties
    end

    methods
        function param=SerDesModelSpecificParameter(varargin)

            param=param@serdes.internal.ibisami.ami.parameter.ModelSpecificParameter(varargin{:});
        end
    end
    methods
        function copiedParam=copy(param)




            copiedParam=serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter(...
            'Name',param.NodeName,...
            'Description',param.Description,...
            'Usage',param.Usage.copy,...
            'Type',param.Type.copy,...
            'Format',param.Format.copy,...
            'CurrentValue',param.CurrentValue);
            copiedParam.NameLocked=param.NameLocked;
            copiedParam.Hidden=param.Hidden;
            copiedParam.New=param.New;
        end
    end
    methods(Access=protected)
        function vName=validName(~,nodeName)
            if nodeName~=""
                serdes.internal.ibisami.ami.VerifySerDesParameterName(nodeName);
            end
            vName=nodeName;
        end
    end
end

