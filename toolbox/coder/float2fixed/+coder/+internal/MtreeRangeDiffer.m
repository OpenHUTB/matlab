classdef MtreeRangeDiffer<coder.internal.MTreeVisitor
    properties

Attributes

Registry
GoldRegistry

functionTypeInfo
GoldFcnInfo

ExprInfo
GoldExprInfo

ExprInfoMap
GoldExprInfoMap


FcnViolations


ViolationRegistry



NodeVisitationRegistry
    end

    properties(Access=private)
nodeLookup
nodeLookupRegistry


nodesVisited
    end

    methods(Access=public)




        function this=MtreeRangeDiffer(registry,goldRegistry,fcnId,goldFcnId,expressionInfoMap,goldExpressionInfoMap,violationRegistry,nodeLookupRegistry,nodeVisitationRegistry)

            this.Registry=registry;
            this.GoldRegistry=goldRegistry;
            this.functionTypeInfo=this.Registry.getFunctionTypeInfo(fcnId);
            this.GoldFcnInfo=this.GoldRegistry.getFunctionTypeInfo(goldFcnId);
            this.Attributes=this.functionTypeInfo.treeAttributes;
            this.ExprInfo=expressionInfoMap(fcnId);
            this.GoldExprInfo=goldExpressionInfoMap(goldFcnId);

            this.ExprInfoMap=expressionInfoMap;
            this.GoldExprInfoMap=goldExpressionInfoMap;

            this.FcnViolations={};
            this.FcnViolations=containers.Map();
            this.ViolationRegistry=violationRegistry;

            this.nodeLookup=containers.Map();
            this.nodeLookupRegistry=nodeLookupRegistry;

            this.nodesVisited={};
            this.NodeVisitationRegistry=nodeVisitationRegistry;
        end

        function run(this)
            fcnNode=this.functionTypeInfo.tree;
            this.visit(fcnNode,[]);

            fcnId=this.functionTypeInfo.uniqueId;
            this.ViolationRegistry(fcnId)=this.FcnViolations;
            this.nodeLookupRegistry(fcnId)=this.nodeLookup;
            this.NodeVisitationRegistry(fcnId)=this.nodesVisited;
        end
    end

    methods(Access=public)

        function output=visitCALL(this,callNode,input)
            output=visitCALL@coder.internal.MTreeVisitor(this,callNode,input);

            this.diff(callNode);

            [fcnId,goldFcnId]=mapFcn(this,callNode);
            if~isempty(fcnId)&&~isempty(goldFcnId)
                coder.internal.MtreeRangeDiffer(this.Registry,this.GoldRegistry,fcnId,goldFcnId,this.ExprInfoMap,this.GoldExprInfoMap,this.ViolationRegistry,this.nodeLookupRegistry,this.NodeVisitationRegistry).run();
            end
        end

        function output=visitEQUALS(this,assignNode,input)
            output=visitEQUALS@coder.internal.MTreeVisitor(this,assignNode,input);

            this.diff(assignNode);
        end
    end

    methods(Access=private)

        function[fcnId,goldFcnId]=mapFcn(this,callNode)
            fcnId=[];goldFcnId=[];
            calleeInfo=this.functionTypeInfo.getCalledFcnInfo(callNode);
            if~isempty(calleeInfo)
                fcnId=calleeInfo.uniqueId;


                goldCalleeInfo=this.GoldFcnInfo.getCalledFcnInfo(callNode);
                if~isempty(goldCalleeInfo)
                    goldFcnId=goldCalleeInfo.uniqueId;
                end
            end
        end

        function diff(this,node)
            [pos,goldPos]=this.map(node);
            if this.ExprInfo.isKey(pos)&&this.GoldExprInfo.isKey(goldPos)
                mxLocInfo=this.ExprInfo(pos);
                goldMxLocInfo=this.GoldExprInfo(goldPos);

                minDiff=(mxLocInfo.SimMin-goldMxLocInfo.SimMin);
                maxDiff=(mxLocInfo.SimMax-goldMxLocInfo.SimMax);

                this.FcnViolations(pos)=[minDiff,maxDiff];

                this.nodeLookup(pos)=node;
                this.nodesVisited{end+1}=pos;
            end
        end



        function[pos,goldPos]=map(~,node)
            pos=num2str(node.position);
            goldPos=pos;
        end
    end
end