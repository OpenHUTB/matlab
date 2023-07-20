


classdef SFAstFunction<slci.ast.SFAst
    properties
        fName='';
        fSfId=-1;
        MATH_FNS={'abs',...
        'acos',...
        'asin',...
        'atan',...
        'atan2',...
        'ceil',...
        'cos',...
        'cosh',...
        'exp',...
        'fabs',...
        'labs',...
        'floor',...
        'fmod',...
        'ldexp',...
        'log',...
        'log10',...
        'max',...
        'min',...
        'pow',...
        'rand',...
        'sin',...
        'sinh',...
        'sqrt',...
        'tan',...
        'tanh'};
        fIsSimulinkFunction=false;
        fHasBeenResolvedToSLFcn=false;
        fSLFcnInfo=[];
    end

    methods(Access=protected)

        function out=getFunctionPath(aObj)
            path=aObj.ParentChart.Path;
            name=sf('get',aObj.fSfId,'.simulink.blockName');
            out=[path,'/',name];

            out=strrep(out,'\n',newline);
        end


        function resolveSLFcnCall(aObj)
            assert(~aObj.fHasBeenResolvedToSLFcn)
            [resolved,func]=slci.internal.getSimulinkFcnInfoForSFAstFunction(...
            aObj);
            aObj.fHasBeenResolvedToSLFcn=true;
            if resolved
                aObj.fIsSimulinkFunction=true;
                aObj.fSLFcnInfo=func;
            end
        end

    end

    methods


        function out=isSimulinkFunctionCall(aObj)
            if~aObj.fHasBeenResolvedToSLFcn
                aObj.resolveSLFcnCall;
            end
            out=aObj.fIsSimulinkFunction;
        end


        function out=getName(aObj)
            out=aObj.fName;
        end


        function out=getSfId(aObj)
            out=aObj.fSfId;
        end


        function out=getSLFunctionSSHandle(aObj)
            fnPath=aObj.getFunctionPath;
            out=aObj.ParentChart.getSLFunction(fnPath);
        end


        function out=isSFSLFunction(aObj)%#ok
            out=false;
        end


        function out=IsGraphicalFunction(aObj)
            out=aObj.ParentChart.IsGraphicalFunction(aObj.fSfId);
        end


        function out=IsTruthTable(aObj)
            out=aObj.ParentChart.IsTruthTable(aObj.fSfId);
        end


        function aObj=SFAstFunction(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function ComputeDataType(aObj)

            assert(~aObj.fComputedDataType);
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);
        end


        function handle=getFunctionHandle(aObj)
            if~aObj.fHasBeenResolvedToSLFcn
                aObj.resolveSLFcnCall;
            end
            assert(aObj.fIsSimulinkFunction,"This is not a Simulink Function call")
            handle=aObj.fSLFcnInfo.getSrcBlkHandle;
        end

    end
end
