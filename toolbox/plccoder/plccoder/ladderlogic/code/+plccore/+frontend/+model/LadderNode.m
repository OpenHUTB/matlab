classdef LadderNode<handle





    properties
        NextNode(1,:);
        PrevNode(1,:);
        BlkHdl(1,1){double};
        Name(1,:)char;
        RungID(1,1){double}=-1;
    end

    methods
        function obj=LadderNode(blkHdl,rungID)


            obj.BlkHdl=blkHdl;
            obj.Name=get_param(blkHdl,'Name');
            obj.RungID=rungID;
        end

        function insertSuccessor(obj,succNode)


            import plccore.frontend.model.LadderNode;

            if isempty(succNode)
                return;
            end

            if~LadderNode.isPresentAlready(succNode,obj.NextNode)
                if isempty(obj.NextNode)
                    obj.NextNode=succNode;
                else
                    obj.NextNode(end+1)=succNode;
                end
            end
        end

        function insertPredecessor(obj,predNode)


            import plccore.frontend.model.LadderNode;

            if isempty(predNode)
                return;
            end

            if~LadderNode.isPresentAlready(predNode,obj.PrevNode)
                if isempty(obj.PrevNode)
                    obj.PrevNode=predNode;
                else
                    obj.PrevNode(end+1)=predNode;
                end
            end
        end

        function willHaveNoPredecessors(obj)
            obj.PrevNode=[];
        end

        function willHaveNoSuccessors(obj)
            obj.NextNode=[];
        end

        function ret=toString(obj,tabstring)

            nodeName=[newline,tabstring,obj.Name,newline,tabstring,'Next Blocks : '];
            nodeNextNames=cell(1,length(obj.NextNode));
            nodePrevNames=cell(1,length(obj.PrevNode));

            for ii=1:length(obj.NextNode)
                nodeNextNames{ii}=obj.NextNode(ii).Name;
            end

            import plccore.frontend.model.RoutineParser;
            if RoutineParser.isParallelJunctionBlock(obj.BlkHdl)

                for ii=1:length(obj.PrevNode)
                    nodePrevNames{ii}=obj.PrevNode(ii).Name;
                end
                ret=[tabstring,nodeName,newline...
                ,tabstring,strjoin(nodeNextNames,', '),newline...
                ,tabstring,'Previous Blocks : ',newline...
                ,tabstring,strjoin(nodePrevNames,', ')];
            else

                ret=[tabstring,nodeName,newline...
                ,tabstring,strjoin(nodeNextNames,', ')];
            end

        end

        function disp(obj,tabcount)
            if nargin==1
                tabcount=0;
            end
            tabstring=repmat('     ',1,tabcount);
            fprintf('%s',[newline,tabstring,obj.toString(tabstring)],tabstring);

            for ii=1:length(obj.NextNode)
                disp(obj.NextNode(ii),tabcount+1);
            end
        end


    end

    methods(Access=private,Static)
        function isPresent=isPresentAlready(newNode,existingNodes)
            nextBlkHdl=newNode.BlkHdl;


            isPresent=false;
            for ii=1:length(existingNodes)
                if existingNodes(ii).BlkHdl==nextBlkHdl
                    isPresent=true;
                end
            end


        end
    end
end


