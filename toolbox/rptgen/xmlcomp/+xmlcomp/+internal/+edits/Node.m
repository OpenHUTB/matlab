


classdef Node<xmlcomp.internal.BaseNode

    methods(Access=public)

        function obj=Node(varargin)

            if nargin<1
                return
            end
            jNode=varargin{1};

            obj.Edited=jNode.isEdited();
            obj.Name=char(jNode.getName());
            obj.createParameters(...
            jNode.getParameters()...
            );
        end
    end

    methods(Access=private)

        function params=createParameters(obj,parameters)
            params=[];
            iterator=parameters.iterator();
            while iterator.hasNext()
                jParam=iterator.next();
                obj.addParameter(jParam);
            end
        end

    end

end

