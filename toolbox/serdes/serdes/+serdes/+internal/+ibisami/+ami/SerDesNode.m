classdef SerDesNode<serdes.internal.ibisami.ami.Node








    properties
        New(1,1)logical=false


    end

    methods
        function node=SerDesNode(varargin)
            node=node@serdes.internal.ibisami.ami.Node(varargin{:});
        end
    end
    methods(Access=protected)
        function vName=validName(~,nodeName)
            serdes.internal.ibisami.ami.VerifySerDesParameterName(nodeName);
            vName=nodeName;
        end
    end
end