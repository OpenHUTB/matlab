classdef HDLCodeView<simulinkcoder.internal.CodeView




    properties
        reportInfo,
        codeGenDir,
        preSub,
traceStyleForLastBuild
    end


    methods
        function obj=HDLCodeView(studio)
            obj@simulinkcoder.internal.CodeView(studio);
        end
    end

    methods(Static)
        saveGeneratedFilesPath(pir,codegenDir,varargin);
        [fileToDisp,files,traceStyle,error]=getGeneratedHDLFiles(reportPath,modelName,isRef);
        highlightBlock(sid);
    end

    methods(Access=public)

        init(obj);
        sendData(obj,uid);
        onSelect(obj,src,data);
        data=getCodeData(obj,reportPath,modelName,isRef);
        switchModel(obj,current);
        url=getUrl(obj);
        traceInfo=getTraceInfoObj(obj,varargin);
        data=getSidToFileLineData(obj,sid,traceInfo,isStateFlowObj);
        highlightForSid(obj,sid,isStateFlowObj);
        dir=getHDLBuildDir(obj,modelName)
    end

end

