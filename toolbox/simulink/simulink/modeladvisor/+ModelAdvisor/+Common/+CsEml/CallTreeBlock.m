
classdef CallTreeBlock<ModelAdvisor.Common.CsEml.CallTreeBase

    methods(Access=public)

        function this=CallTreeBlock(blockPath,inferenceReport)

            this=this@ModelAdvisor.Common.CsEml.CallTreeBase();
            this.m_BlockPath=blockPath;
            this.m_InstanceInfo=ModelAdvisor.Common.CsEml.InstanceInfo.empty;

            IR=inferenceReport.getIR();
            irRootFunctionIds=IR.RootFunctionIDs;
            for i=1:numel(irRootFunctionIds)
                irFid=irRootFunctionIds(i);
                callTreeFunction=ModelAdvisor.Common.CsEml.CallTreeFunction(this,inferenceReport,irFid);
                this.addChild(callTreeFunction);
            end
        end

        function html=getFunctionTypeText(~)
            html=Advisor.Element('span','class','function-type');
            text='Blk';
            html.setContent(text);
        end

        function text=getFunctionNameText(this)
            text=Advisor.Text(this.m_BlockPath);
        end

        function blockPath=getBlockPath(this)
            blockPath=this.m_BlockPath;
        end

        function blockSid=getBlockSid(this)
            blockSid=Simulink.ID.getSID(this.m_BlockPath);
        end

        function scriptCode=getScriptCode(this,irSid)
            scriptCode=this.IR.getScriptCode(irSid);
        end

        function functionCode=getFunctionCode(this,irFid)
            functionInfo=this.IR.getFunctionInfo(irFid);
            functionCode=functionInfo.getCode();
        end

        function addInstancesToCallTree(this,blockInstances)
            numChildren=this.getNumberOfChildren();
            for i=1:numChildren
                child=this.getChild(i);
                child.addInstancesToCallTree(blockInstances);
            end
        end

        function callTreeNodes=getCallTreeNodes(this,irFunctionId)
            callTreeNodes=ModelAdvisor.Common.CsEml.CallTreeFunction.empty;
            numChildren=this.getNumberOfChildren();
            for i=1:numChildren
                child=this.getChild(i);
                newCallTreeNodes=child.getCallTreeNodes(irFunctionId);
                callTreeNodes=[callTreeNodes;newCallTreeNodes];%#ok<AGROW>
            end
        end
    end

    methods(Access=private)


    end

    properties
        m_BlockPath;
        m_InstanceInfo;
    end

end

