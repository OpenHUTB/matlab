



classdef mtreeUpdateDSMNames<plccore.frontend.L5X.MtreeVisitor

    properties
MFBScript
    end

    properties(Access=protected)
        defaultMsgID;
        operand;
        DSMMap;

        replacementList;
    end

    methods(Access=public)

        function this=mtreeUpdateDSMNames(operand,DSMMap)
            this@plccore.frontend.L5X.MtreeVisitor(plccore.util.operand2mtree(operand))
            this.operand=operand;
            this.DSMMap=DSMMap;
            this.run;
        end

        function messages=run(this)
            this.visit(this.tree)
            messages=this.messages;
            this.MFBScript=this.tree.tree2str(0,1,this.replacementList);
        end
    end

    methods(Access=protected)
        function addMessage(this,node,~,~,~)

        end

        function preProcessFIELD(this,node)
            nodeVal=this.getNodeVal(node);
        end

        function postProcessID(this,node)
            nodeVal=this.getNodeVal(node);
            if ismember(nodeVal,this.DSMMap.keys)
                DSMName=this.DSMMap(nodeVal);
                this.replacementList=[this.replacementList,{node,DSMName}];
            end
        end

        function out=getNodeVal(this,node)
            out=node.string;
        end

    end
end


