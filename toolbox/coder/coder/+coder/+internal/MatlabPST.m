


classdef MatlabPST<coder.internal.MTreeVisitor







    properties(Access=public)
Path
Code
Tree


Fcns
Ifs
Fors
Whiles
Switches
BasicBlocks



DeadCodeBlocks



OptimizeForCoverage
    end

    methods
        function this=MatlabPST(code,path,optimizeForCoverage)
            if nargin>=2
                path=strrep(path,'\','/');
                this.Path=path;
            else
                this.Path=[];
            end

            if nargin>2
                this.OptimizeForCoverage=optimizeForCoverage;
            else
                this.OptimizeForCoverage=false;
            end

            this.Code=code;
            this.Tree=mtree(code,'-comments');


            this.Fcns=[];
            this.Ifs=[];
            this.Fors=[];
            this.Whiles=[];
            this.Switches=[];
            this.BasicBlocks=[];
            this.DeadCodeBlocks=[];


            this.visitNodeList(this.Tree.root,[]);





            this.Fcns=this.sortByStartCharIdx(this.Fcns);
            this.Ifs=this.sortByStartCharIdx(this.Ifs);
            this.Fors=this.sortByStartCharIdx(this.Fors);
            this.Whiles=this.sortByStartCharIdx(this.Whiles);
            this.Switches=this.sortByStartCharIdx(this.Switches);
            this.BasicBlocks=this.sortByStartCharIdx(this.BasicBlocks);
            this.DeadCodeBlocks=this.sortByStartCharIdx(this.DeadCodeBlocks);
        end
    end

    methods

        function infos=sortByStartCharIdx(~,infos)
            if~isempty(infos)
                [~,ind]=sort([infos.charStartIdx]);
                infos=infos(ind);
            end
        end

        function output=visitLB(visitor,node,input)
            if visitor.OptimizeForCoverage
                output=[];
                return;
            end
            output=visitLB@coder.internal.MTreeVisitor(visitor,node,input);
        end
    end

    methods(Access=protected)






        function recordDeadCodeBlocks(this,nodeList)
            node=nodeList;
            firstExitNode=[];

            while~isempty(node)
                switch node.kind
                case{'BREAK','CONTINUE','RETURN'}
                    firstExitNode=node;
                    break;
                end
                node=node.Next;
            end

            if~isempty(firstExitNode)





                firstDeadNode=firstExitNode.Next;
                if~isempty(firstDeadNode)


                    node=firstDeadNode;
                    while~isempty(node)
                        lastDeadNode=node;
                        node=node.Next;
                    end


                    bb.firstExitNode=firstExitNode;
                    bb.firstNode=firstDeadNode;
                    bb.lastNode=lastDeadNode;
                    bb.charStartIdx=bb.firstNode.lefttreepos;
                    bb.charEndIdx=bb.lastNode.righttreepos;
                    bb.code=this.Code(bb.charStartIdx:bb.charEndIdx);
                    if~isempty(this.DeadCodeBlocks)
                        this.DeadCodeBlocks(end+1)=bb;
                    else
                        this.DeadCodeBlocks=bb;
                    end
                end
            end
        end
















        function output=visitBody(this,nodeList,input)
            output=[];
            node=nodeList;


            this.recordDeadCodeBlocks(nodeList);

            basicBlockStart=[];
            basicBlockEnd=[];

            while~isempty(node)
                switch node.kind
                case{'COMMENT','GLOBAL','PERSISTENT'}







                case{'IF','ELSEIF','ELSE','FOR','WHILE','SWITCH','CASE','OTHERWISE'}

                    this.recordBasicBlock(basicBlockStart,basicBlockEnd);


                    basicBlockStart=[];
                    basicBlockEnd=[];

                case{'BREAK','CONTINUE','RETURN'}

                    basicBlockEnd=node;


                    if isempty(basicBlockStart)
                        basicBlockStart=node;
                    end


                    this.recordBasicBlock(basicBlockStart,basicBlockEnd);


                    break;

                otherwise

                    if isempty(basicBlockStart)

                        basicBlockStart=node;
                        basicBlockEnd=node;
                    else

                        basicBlockEnd=node;
                    end
                end


                output=this.visit(node,input);
                node=node.Next;


                if isempty(node)

                    this.recordBasicBlock(basicBlockStart,basicBlockEnd);
                end
            end

        end
    end


    methods


        function recordFunctionNode(this,node)
            fcn.node=node;
            fcn.charStartIdx=node.lefttreepos;
            fcn.charExprEndIdx=0;
            fcn.charEndIdx=node.righttreepos;
            if~isempty(this.Fcns)
                this.Fcns(end+1)=fcn;
            else
                this.Fcns=fcn;
            end
        end


        function recordBasicBlock(this,basicBlockStart,basicBlockEnd)
            if isempty(basicBlockStart)
                return;
            end

            bb.basicBlockStart=basicBlockStart;
            bb.basicBlockEnd=basicBlockEnd;
            bb.charStartIdx=basicBlockStart.lefttreepos;
            bb.charExprEndIdx=0;
            bb.charEndIdx=basicBlockEnd.righttreepos;


            pos=bb.charEndIdx;
            while pos<length(this.Code)
                switch this.Code(pos)
                case ';',break;
                case ' ',pos=pos+1;
                otherwise,break;
                end
            end

            if this.Code(pos)==';'
                bb.charEndIdx=pos;
            end
            bb.code=this.Code(bb.charStartIdx:bb.charEndIdx);


            if~isempty(this.BasicBlocks)
                this.BasicBlocks(end+1)=bb;
            else
                this.BasicBlocks=bb;
            end
        end


        function recordIfElseNode(this,ifNode,elseNode,charEndIdx)
            condition=ifNode.Left;
            IfInfo.node=ifNode;
            IfInfo.charStartIdx=ifNode.lefttreepos;
            IfInfo.charExprEndIdx=condition.righttreepos;
            if~isempty(elseNode)
                IfInfo.charElseStartIdx=elseNode.lefttreepos;
            else
                IfInfo.charElseStartIdx=0;
            end
            IfInfo.charEndIdx=charEndIdx;
            IfInfo.code=this.Code(IfInfo.charStartIdx:IfInfo.charEndIdx);
            if~isempty(this.Ifs)
                this.Ifs(end+1)=IfInfo;
            else
                this.Ifs=IfInfo;
            end
        end


        function recordForNode(this,forNode)
            vector=forNode.Vector;
            forInfo.node=forNode;
            forInfo.charStartIdx=forNode.lefttreepos;
            forInfo.charExprEndIdx=vector.righttreepos;
            forInfo.charEndIdx=forNode.righttreepos;
            forInfo.code=this.Code(forInfo.charStartIdx:forInfo.charEndIdx);
            if~isempty(this.Fors)
                this.Fors(end+1)=forInfo;
            else
                this.Fors=forInfo;
            end
        end


        function recordWhileNode(this,whileNode)
            condition=whileNode.Left;
            whileInfo.node=whileNode;
            whileInfo.charStartIdx=whileNode.lefttreepos;
            whileInfo.charExprEndIdx=condition.righttreepos;
            whileInfo.charEndIdx=whileNode.righttreepos;
            whileInfo.code=this.Code(whileInfo.charStartIdx:whileInfo.charEndIdx);
            if~isempty(this.Whiles)
                this.Whiles(end+1)=whileInfo;
            else
                this.Whiles=whileInfo;
            end
        end


        function recordSwitchNode(this,switchNode)
            expression=switchNode.Left;
            switchInfo.node=switchNode;
            switchInfo.charStartIdx=switchNode.lefttreepos;
            switchInfo.charExprEndIdx=expression.righttreepos;
            switchInfo.charEndIdx=switchNode.righttreepos;
            switchInfo.cases=[];
            switchInfo.code=this.Code(switchInfo.charStartIdx:switchInfo.charEndIdx);


            caseNode=switchNode.Body;
            while~isempty(caseNode)
                switch caseNode.kind
                case{'CASE','OTHERWISE'}
                    caseInfo.node=caseNode;
                    caseInfo.charStartIdx=caseNode.lefttreepos;
                    if strcmp(caseNode.kind,'CASE')
                        values=caseNode.Left;
                        caseInfo.charExprEndIdx=values.righttreepos;
                    else
                        caseInfo.charExprEndIdx=caseInfo.charStartIdx+length('OTHERWISE')-1;
                    end
                    caseInfo.charEndIdx=caseNode.righttreepos;
                    caseInfo.code=this.Code(caseInfo.charStartIdx:caseInfo.charEndIdx);


                    if isempty(switchInfo.cases)
                        switchInfo.cases=caseInfo;
                    else
                        if strcmp(caseNode.kind,'OTHERWISE')

                            switchInfo.cases=[caseInfo,switchInfo.cases(:)'];
                        else
                            switchInfo.cases(end+1)=caseInfo;
                        end
                    end
                end

                caseNode=caseNode.Next;
            end


            if isempty(switchInfo.cases)||~strcmp(switchInfo.cases(1).node.kind,'OTHERWISE')
                caseInfo.node=[];
                caseInfo.charStartIdx=0;
                caseInfo.charExprEndIdx=8;
                caseInfo.charEndIdx=0;
                caseInfo.code='';
                if isempty(switchInfo.cases)
                    switchInfo.cases=caseInfo;
                else
                    switchInfo.cases=[caseInfo,switchInfo.cases(:)'];
                end
            end


            if~isempty(this.Switches)
                this.Switches(end+1)=switchInfo;
            else
                this.Switches=switchInfo;
            end
        end
    end


    methods

        function out=visitFUNCTION(this,node,inp)
            this.recordFunctionNode(node);
            out=this.visitFUNCTION@coder.internal.MTreeVisitor(node,inp);
        end

        function out=visitIF(this,node,inp)
            ifHead=node.Arg;
            elseIfNode=ifHead.Next;
            charEndIdx=node.righttreepos;
            this.recordIfElseNode(ifHead,elseIfNode,charEndIdx);

            while~isempty(elseIfNode)
                if strcmp(elseIfNode.kind,'ELSE')

                    break;
                end
                this.recordIfElseNode(elseIfNode,elseIfNode.Next,charEndIdx);
                elseIfNode=elseIfNode.Next;
            end

            out=this.visitIF@coder.internal.MTreeVisitor(node,inp);
        end

        function out=visitFOR(this,node,inp)
            this.recordForNode(node);
            out=this.visitFOR@coder.internal.MTreeVisitor(node,inp);
        end

        function out=visitWHILE(this,node,inp)
            this.recordWhileNode(node);
            out=this.visitWHILE@coder.internal.MTreeVisitor(node,inp);
        end

        function out=visitSWITCH(this,node,inp)
            this.recordSwitchNode(node);
            out=this.visitSWITCH@coder.internal.MTreeVisitor(node,inp);
        end
    end
end