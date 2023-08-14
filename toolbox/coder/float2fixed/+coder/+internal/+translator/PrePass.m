classdef PrePass<coder.internal.MTreeVisitor
    properties(Access=protected)
        functionRegistry;
        functionNode;
        functionTypeInfo;
        addedCfolds;
    end

    methods(Access=public)
        function prePass=PrePass(functionRegistry,functionNode,mtreeAttributes,functionTypeInfo)
            prePass=prePass@coder.internal.MTreeVisitor(mtreeAttributes);
            prePass.functionRegistry=functionRegistry;
            prePass.functionNode=functionNode;
            prePass.functionTypeInfo=functionTypeInfo;
        end

        function addedCfolds=run(this)
            this.addedCfolds={};

            if~this.functionTypeInfo.isDead
                this.visit(this.functionNode,[]);
            end



            addedCfolds=this.addedCfolds;
        end
    end

    methods(Access=public)


        function output=visitFUNCTION(this,functionNode,input)
            output=visitFUNCTION@coder.internal.MTreeVisitor(this,functionNode,input);
        end

        function output=visitEXPR(this,node,input)
            if this.treeAttributes(node).isExecutedInSimulation
                output=this.visit(node.Arg,input);
            else
                output.tag=node.UNDEF;
            end
        end

        function output=visitCALL(this,callNode,~)
            calledFunction=this.treeAttributes(callNode).CalledFunction;

            if~isempty(calledFunction)&&calledFunction.isDead
                calledFunction.isDead=false;
                calledFunction.isConstantFolded=true;
                this.addedCfolds{end+1}=calledFunction;
            end

            output.tag=callNode.UNDEF;
        end

        function output=visitDCALL(this,callNode,~)
            calledFunction=this.treeAttributes(callNode).CalledFunction;

            if~isempty(calledFunction)&&calledFunction.isDead
                calledFunction.isDead=false;
                calledFunction.isConstantFolded=true;
                this.addedCfolds{end+1}=calledFunction;
            end

            output=[];
        end

        function output=visitMethodCall(this,callNode,~)
            calledFunction=this.treeAttributes(callNode).CalledFunction;

            if~isempty(calledFunction)&&calledFunction.isDead
                calledFunction.isDead=false;
                calledFunction.isConstantFolded=true;
                this.addedCfolds{end+1}=calledFunction;
            end

            output=[];
        end
    end
end