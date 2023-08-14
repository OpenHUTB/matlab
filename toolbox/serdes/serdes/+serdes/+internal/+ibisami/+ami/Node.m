classdef Node<serdes.utilities.generictree.AbstractGenericTreeNode




    properties


        Description=""
        NameLocked(1,1)=false
        Hidden(1,1)=false
    end
    methods

        function copiedNode=copyNodeWithNewName(node,newName)

            copiedNode=serdes.internal.ibisami.ami.Node(newName,node.Description,node.NameLocked);
        end

    end
    methods
        function node=Node(varargin)





            nodeName="";
            if nargin==1

                nodeName=varargin{1};
            elseif nargin>1

                p=serdes.internal.ibisami.ami.parameter.ArgumentParser;
                p.parse(varargin{:});
                args=p.Results;
                nodeName=args.Name;
            end
            node=node@serdes.utilities.generictree.AbstractGenericTreeNode(nodeName);
            if nargin>1
                node.Description=args.Description;
            end
        end

        function set.Description(node,description)



            node.Description=description;
        end
    end
end

