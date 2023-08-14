


classdef(Hidden=true)CodeInfoUtils<handle
    properties(SetAccess=private,GetAccess=public)
ModelParameters
GlobalParameters
CodeInfo
    end


    methods(Access=public)
        function this=CodeInfoUtils(codeInfo)
            assert(isa(codeInfo,'RTW.ComponentInterface'));
            this.CodeInfo=codeInfo;
            this.ModelParameters=this.getModelParameters;
            this.GlobalParameters=this.getGlobalParameters;
        end


        function codeInfo=getCodeInfo(this)
            codeInfo=this.CodeInfo;
        end


        function status=isInport(this,dataInterface)
            status=dataInterface.findIndex(this.CodeInfo.Inports)>0;
        end


        function portIdx=getInportIndex(this,dataInterface)
            portIdx=dataInterface.findIndex(this.CodeInfo.Inports);
        end


        function status=isOutport(this,dataInterface)
            status=dataInterface.findIndex(this.CodeInfo.Outports)>0;
        end

        function portIdx=getOutportIndex(this,dataInterface)
            portIdx=dataInterface.findIndex(this.CodeInfo.Outports);
        end


        function status=isInternalData(this,dataInterface)
            status=any(this.CodeInfo.InternalData==dataInterface);
        end


        function status=isParameter(this,dataInterface)
            status=any(this.CodeInfo.Parameters==dataInterface);
        end


        function usedParams=getModelParameters(this)
            if isempty(this.CodeInfo.Parameters)
                usedParams=[];
            else
                usedParams=this.CodeInfo.Parameters(strcmp(get(this.CodeInfo.Parameters,'SID'),this.CodeInfo.GraphicalPath));
            end
        end


        function globalParams=getGlobalParameters(this)
            if isempty(this.CodeInfo.Parameters)
                globalParams=[];
            else
                globalParams=this.CodeInfo.Parameters(~strcmp(get(this.CodeInfo.Parameters,'SID'),this.CodeInfo.GraphicalPath));
            end
        end


        function isModelArgParam=isModelArgumentParameter(this,dataInterface)
            isModelArgParam=strcmp(get(dataInterface,'SID'),this.CodeInfo.GraphicalPath);
        end
    end
end
