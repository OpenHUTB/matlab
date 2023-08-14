

classdef SimulinkFunctionInfo
    properties(Access=private)
        fFcnName;

        fSrcBlkHdl;


        fFcnBlkHdl;
        fReturnTypes=[];
        fScopeName;
        fNumArgIns;
        fNumArgOuts;
        fReturnWidth=[];

        fCallerHandles={};

        fSrcMdl;

    end
    methods(Access=private)



        function dim=computeDataWidth(~,aCompiledDim)
            dim=1;
            for i=1:aCompiledDim.Size
                dim=dim*aCompiledDim(i);
            end
        end
    end
    methods



        function obj=SimulinkFunctionInfo(aCompFunction)
            assert(isa(aCompFunction,...
            'Simulink.ModelReference.internal.compileInfo.CompFunction'),...
            ['wrong compiled function info arg for'...
            ,'slci.SimulinkFunctionInfo']);
            obj.fSrcMdl=aCompFunction.sourceModel;
            obj.fSrcBlkHdl=get_param(aCompFunction.variantFunctionBlockPath,...
            'Handle');
            obj.fFcnBlkHdl=get_param(aCompFunction.functionBlock,'Handle');
            obj.fFcnName=aCompFunction.functionName;
            obj.fScopeName=aCompFunction.scopeName;
            obj.fNumArgIns=aCompFunction.fcnArgs.inArgs.Size;

            argOuts=aCompFunction.fcnArgs.outArgs;
            obj.fNumArgOuts=argOuts.Size;
            if obj.fNumArgOuts~=0
                for i=1:obj.fNumArgOuts
                    retArgStr=argOuts(i).dataType.dataTypeName;
                    typeCell=extractBetween(retArgStr,"'","'");
                    if isempty(typeCell)
                        obj.fReturnTypes{end+1}=retArgStr;
                    else
                        obj.fReturnTypes{end+1}=typeCell{1};
                    end
                    obj.fReturnWidth{end+1}=obj.computeDataWidth(argOuts(i).dims);
                end
            else
                obj.fReturnTypes={'void'};
                obj.fReturnWidth={1};
            end

            callers=aCompFunction.callerBlocks;
            for j=1:callers.Size
                callerPath=callers(j);
                obj.fCallerHandles{end+1}=get_param(callerPath{1},'Handle');
            end
        end


        function type=getSrcBlockType(aObj)
            blkObj=get_param(aObj.fSrcBlkHdl,'Object');
            if isa(blkObj,'Simulink.SubSystem')
                type=slci.internal.getSubsystemType(blkObj);
            else
                type=blkObj.BlockType;
            end
        end


        function type=getFunctionBlockType(aObj)
            blkObj=get_param(aObj.fFcnBlkHdl,'Object');
            if isa(blkObj,'Simulink.SubSystem')
                type=slci.internal.getSubsystemType(blkObj);
            else
                type=blkObj.BlockType;
            end
        end


        function retTypes=getReturnTypes(aObj)
            retTypes=aObj.fReturnTypes;
        end

        function num=getNumArgIn(aObj)
            num=aObj.fNumArgIns;
        end


        function num=getNumArgOut(aObj)
            num=aObj.fNumArgOuts;
        end


        function hdl=getSrcBlkHandle(aObj)
            hdl=aObj.fSrcBlkHdl;
        end


        function scope=getScope(aObj)
            scope=aObj.fScopeName;
        end


        function fcnName=getFunctionName(aObj)
            fcnName=aObj.fFcnName;
        end


        function path=getFunctionBlockPath(aObj)
            path=getfullname(aObj.fFcnBlkHdl);
        end


        function type=getReturnTypeAt(aObj,idx)
            assert(idx<=numel(aObj.fReturnTypes),...
            'Index exceeds number of return arguments');
            type=aObj.fReturnTypes{idx};
        end

        function dim=getReturnWidthAt(aObj,idx)
            assert(idx<=numel(aObj.fReturnTypes),...
            'Index exceeds number of return arguments');
            dim=aObj.fReturnWidth{idx};
        end


        function out=getCallers(aObj)
            out=aObj.fCallerHandles;
        end


        function out=getFcnBlkHdl(aObj)
            out=aObj.fFcnBlkHdl;
        end

        function out=getSrcBlkHdl(aObj)
            out=aObj.fSrcBlkHdl;
        end


        function out=getSrcMdl(aObj)
            out=aObj.fSrcMdl;
        end
    end
end