
classdef FillCompiledInfoPass<coder.internal.MTreeVisitor












    properties(Access=private)
        functionMTree;
        compiledExprInfoMap;
    end


    methods
        function this=FillCompiledInfoPass(functionTypeInfo,compiledExprInfoMap)
            this.functionMTree=functionTypeInfo.tree;
            this.treeAttributes=functionTypeInfo.treeAttributes;
            this.compiledExprInfoMap=compiledExprInfoMap;
        end

        function output=visit(this,node,input)
            this.fillMxLocationInfo(node);
            output=visit@coder.internal.MTreeVisitor(this,node,input);
        end

        function run(this)
            data=[];
            this.visit(this.functionMTree,data);
        end

        function output=visitSUBSCR(this,subScrNode,input)
            output=[];
            vector=subScrNode.Left;
            this.visit(vector,input);

            index=subScrNode.Right;
            this.visitNodeList(index,input);
        end

        function output=visitMethodCall(this,node,input)
            output=[];
            this.visitNodeList(node.Right,input);
        end

        function output=visitDOT(this,node,input)
            output=[];
            this.visit(node.Left,input);
            this.visit(node.Right,input);
        end

        function output=visitFIELD(~,~,~)
            output=[];
        end
    end

    methods(Access=private)

        function fillMxLocationInfo(this,node)
            startPos=node.lefttreepos;
            endPos=node.righttreepos;
            assert(isscalar(startPos)&&isscalar(endPos),'Position is not scalar');
            nodeKey=[num2str(startPos),':',num2str(endPos)];

            if this.compiledExprInfoMap.isKey(nodeKey)
                compiledMxlocInfo=this.compiledExprInfoMap(nodeKey);
                this.treeAttributes(node).CompiledMxLocInfo=compiledMxlocInfo;
            end
        end

    end

end
