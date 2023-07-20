
classdef InferenceReport<handle

    methods(Access=public)

        function this=InferenceReport(blockPath)
            this.m_IR=ModelAdvisor.Common.CsEml.Utilities.getInferenceReportFromBlockPath(blockPath);





















        end

        function IR=getIR(this)
            IR=this.m_IR;
        end

        function result=isFunctionUserVisible(this,irFunctionId)
            result=false;
            irFunction=this.m_IR.Functions(irFunctionId);
            if irFunction.TextLength>0
                irScriptId=irFunction.ScriptID;
                if irScriptId>0
                    irScript=this.m_IR.Scripts(irScriptId);
                    if irScript.IsUserVisible
                        result=true;
                    end
                end
            end
        end

    end

    methods(Access=private)


    end

    properties
        m_IR;
    end

end

