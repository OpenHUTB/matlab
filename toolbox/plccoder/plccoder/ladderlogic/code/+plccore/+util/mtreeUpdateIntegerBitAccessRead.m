



classdef mtreeUpdateIntegerBitAccessRead<plccore.frontend.L5X.MtreeVisitor

    properties
MFBScript
    end

    properties(Access=protected)
        defaultMsgID;
        operand;
        funNames;
        funReplaceMap;
        isRHS;
        replacementList;
    end

    methods(Access=public)

        function this=mtreeUpdateIntegerBitAccessRead(operand,isRHS)
            this@plccore.frontend.L5X.MtreeVisitor(plccore.util.operand2mtree(operand))
            this.operand=operand;
            this.isRHS=isRHS;
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
            nodeVal=node.string;
            nodeParentVal=node.Parent.Left.tree2str;

            bitToken=regexp(nodeVal,'xxx__BIT(\d+)','tokens');
            if~isempty(bitToken)
                if this.isRHS
                    replacementStr=sprintf('logical(bitget(%s, %s+1))',nodeParentVal,bitToken{1}{1});
                else
                    replacementStr=sprintf('bitset(%s, %s+1, %s)',nodeParentVal,bitToken{1}{1},'__u_VALUE__');
                end
                this.replacementList=[this.replacementList,{node.Parent,replacementStr}];
            end
        end



    end
end


