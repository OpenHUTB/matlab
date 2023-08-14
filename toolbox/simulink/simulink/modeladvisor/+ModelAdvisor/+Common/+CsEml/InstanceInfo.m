
classdef InstanceInfo<handle

    methods(Access=public)

        function this=InstanceInfo(modelInfo,blockInfo,scriptInfo,...
            functionInfo,inferenceReport,irFunctionId,callTree,...
            callTreeNodes)
            this.m_ModelInfo=modelInfo;
            this.m_BlockInfo=blockInfo;
            this.m_ScriptInfo=scriptInfo;
            this.m_FunctionInfo=functionInfo;
            this.m_InferenceReport=inferenceReport;
            this.m_IrFunctionId=irFunctionId;
            this.m_CallTree=callTree;
            this.m_CallTreeNodes=callTreeNodes;
        end

        function modelName=getModelName(this)
            if numel(this)==1
                modelName=this.m_ModelInfo.getName();
            else
                modelName=arrayfun(@(x)(x.m_ModelInfo.getName()),this);
            end
        end

        function blockSid=getBlockSid(this)
            if numel(this)==1
                blockSid=this.m_BlockInfo.getSid();
            else
                blockSid=arrayfun(@(x)(x.m_BlockInfo.getSid()),this);
            end
        end

        function blockPath=getBlockPath(this)
            if numel(this)==1
                blockPath=this.m_BlockInfo.getPath();
            else
                blockPath=arrayfun(@(x)(x.m_BlockInfo.getPath()),this);
            end
        end

        function blockType=getBlockType(this)
            if numel(this)==1
                blockType=this.m_BlockInfo.getType();
            else
                blockType=arrayfun(@(x)(x.m_BlockInfo.getType()),this);
            end
        end

        function inferenceReport=getInferenceReport(this)
            if numel(this)==1
                inferenceReport=this.m_BlockInfo.getInferenceReport();
            else
                inferenceReport=arrayfun(@(x)(x.m_BlockInfo.getInferenceReport()),this);
            end
        end

        function scriptPath=getScriptPath(this)
            if numel(this)==1
                scriptPath=this.m_ScriptInfo.getPath();
            else
                scriptPath=arrayfun(@(x)(x.m_ScriptInfo.getPath()),this);
            end
        end

        function scriptType=getScriptType(this)
            if numel(this)==1
                scriptType=this.m_ScriptInfo.getType();
            else
                scriptType=arrayfun(@(x)(x.m_ScriptInfo.getType()),this);
            end
        end

        function scriptCode=getScriptCode(this)
            if numel(this)==1
                scriptCode=this.m_ScriptInfo.getCode();
            else
                scriptCode=arrayfun(@(x)(x.m_ScriptInfo.getCode()),this);
            end
        end

        function functionName=getFunctionName(this)
            if numel(this)==1
                functionName=this.m_FunctionInfo.getName();
            else
                functionName=arrayfun(@(x)(x.m_FunctionInfo.getName()),this);
            end
        end

        function functionType=getFunctionType(this)
            if numel(this)==1
                functionType=this.m_FunctionInfo.getType();
            else
                functionType=arrayfun(@(x)(x.m_FunctionInfo.getType()),this);
            end
        end

        function functionCode=getFunctionCode(this)
            if numel(this)==1
                functionCode=this.m_FunctionInfo.getCode();
            else
                functionCode=arrayfun(@(x)(x.m_FunctionInfo.getCode()),this);
            end
        end

        function functionCodeStart=getFunctionCodeStart(this)
            if numel(this)==1
                functionCodeStart=this.m_FunctionInfo.getCodeStart();
            else
                functionCodeStart=arrayfun(@(x)(x.m_FunctionInfo.getCodeStart()),this);
            end
        end

        function functionCodeEnd=getFunctionCodeEnd(this)
            if numel(this)==1
                functionCodeEnd=this.m_FunctionInfo.getCodeEnd();
            else
                functionCodeEnd=arrayfun(@(x)(x.m_FunctionInfo.getCodeEnd()),this);
            end
        end

        function irFunctionId=getIrFunctionId(this)
            if numel(this)==1
                irFunctionId=this.m_IrFunctionId;
            else
                irFunctionId=arrayfun(@(x)(x.m_IrFunctionId),this);
            end
        end

        function callTree=getCallTree(this)
            if numel(this)==1
                callTree=this.m_IrFunctionId;
            else
                callTree=arrayfun(@(x)(x.m_CallTree),this);
            end
        end

        function callTreeNodes=getCallTreeNodes(this)
            if numel(this)==1
                callTreeNodes=this.m_CallTree.getCallTreeNodes(this.m_IrFunctionId);
            else
                callTreeNodes=arrayfun(@(x)(x.m_CallTree.getCallTreeNodes(x.m_IrFunctionId)),this,'UniformOutput',false);
            end
        end

        function mTree=getMTree(this)
            functionCode=this.m_FunctionInfo.getCode();
            mTree=mtree(functionCode,'-comments');
        end

        function results=getResults(this)
            results=this.m_Results;
        end

        function nodeInfo=getNodeInfo(this,node)

            inferenceReport=this.m_InferenceReport;
            ir=inferenceReport.getIR();
            irFunction=ir.Functions(this.m_IrFunctionId);
            mxInfoLocations=irFunction.MxInfoLocations;
            functionOffset=irFunction.TextStart;
            nodeL=node.lefttreepos+functionOffset;
            nodeR=node.righttreepos+functionOffset;


            nodeInfo.isTypeInfoAvailable=false;
            nodeInfo.isComplex=false;
            nodeInfo.className='unknown';
            nodeInfo.size=[0,0];
            nodeInfo.isSizeDynamic=false;
            nodeInfo.left=nodeL;
            nodeInfo.right=nodeR;

            L=[mxInfoLocations.TextStart]'+1;
            R=[mxInfoLocations.TextStart]'+[mxInfoLocations.TextLength]';
            index=find(L==nodeL&R==nodeR);
            if numel(index)==1
                inferMxInfoLocation=mxInfoLocations(index);
                mxInfoID=inferMxInfoLocation.MxInfoID;
                mxNumericInfo=ir.MxInfos{mxInfoID};
            elseif numel(index)>1
                inferMxInfoLocation=mxInfoLocations(index(1));
                mxInfoID=inferMxInfoLocation.MxInfoID;
                mxNumericInfo=ir.MxInfos{mxInfoID};
            else
                mxNumericInfo=[];
            end

            if isempty(mxNumericInfo)
                nodeInfo=this.handleNoMatch(node,nodeInfo);
                return;
            else
                nodeInfo.isTypeInfoAvailable=true;
                if isfield(mxNumericInfo,'Complex')
                    nodeInfo.isComplex=mxNumericInfo.Complex;
                else
                    nodeInfo.isComplex=false;
                end
                nodeInfo.className=mxNumericInfo.Class;
                nodeInfo.size=double(mxNumericInfo.Size);
                nodeInfo.isSizeDynamic=mxNumericInfo.SizeDynamic;



                if node.iskind('UMINUS')||node.iskind('UPLUS')
                    argNode=node.Arg;
                    tempNodeInfo=this.getNodeInfo(argNode);
                    if strcmp(nodeInfo.className,'logical')
                        if strcmp(tempNodeInfo.className,'logical')

                            nodeInfo.className='double';
                            nodeInfo.size=tempNodeInfo.size;
                        elseif~strcmp(nodeInfo.className,tempNodeInfo.className)
                            nodeInfo.className=tempNodeInfo.className;
                            nodeInfo.size=tempNodeInfo.size;
                        end
                    end
                end

            end
        end

        function nodeInfo=handleNoMatch(this,node,nodeInfoIn)
            nodeInfo=nodeInfoIn;

            nodeInfo.isTypeInfoAvailable=false;
            nodeInfo.className='unknown';
            nodeL=nodeInfo.left;
            nodeR=nodeInfo.right;

            switch node.kind()

            case{'INT','DOUBLE'}
                nodeInfo.isTypeInfoAvailable=true;
                nodeInfo.className='double';
                nodeInfo.size=[1,1];
                if isreal(str2double(node.stringval))
                    nodeInfo.isComplex=false;
                else
                    nodeInfo.isComplex=true;
                end
                return;
            case 'PARENS'
                tempNodeInfo=this.getNodeInfo(node.Arg);
                nodeInfo=tempNodeInfo;
                nodeInfo.left=nodeL;
                nodeInfo.right=nodeR;
                return;
            case 'SUBSCR'
                tempNodeInfo=this.getNodeInfo(node.Left);
                if numel(tempNodeInfo.size)==2
                    numRows=tempNodeInfo.size(1);
                    numColumns=tempNodeInfo.size(2);
                    if numRows==1&&numColumns==1
                        nodeInfo=tempNodeInfo;
                        nodeInfo.left=nodeL;
                        nodeInfo.right=nodeR;
                        return;
                    end
                end
            case{'TRANS','DOTTRANS'}
                tempNodeInfo=this.getNodeInfo(node.Arg);
                if numel(tempNodeInfo.size)==2
                    numRows=tempNodeInfo.size(1);
                    numColumns=tempNodeInfo.size(2);
                    if numRows==1&&numColumns==1
                        nodeInfo=tempNodeInfo;
                        nodeInfo.left=nodeL;
                        nodeInfo.right=nodeR;
                        return;
                    end
                end
            case{'UMINUS','UPLUS'}
                tempNodeInfo=this.getNodeInfo(node.Arg);
                if strcmp(tempNodeInfo.className,'logical')
                    nodeInfo=tempNodeInfo;
                    nodeInfo.className='double';
                    nodeInfo.left=nodeL;
                    nodeInfo.right=nodeR;
                    return;
                else
                    nodeInfo=tempNodeInfo;
                    nodeInfo.left=nodeL;
                    nodeInfo.right=nodeR;
                    return;
                end
            case 'CALL'
                try
                    result=eval(node.tree2str());
                    nodeInfo.isTypeInfoAvailable=true;
                    nodeInfo.className=class(result);
                    nodeInfo.size=size(result);
                    return;
                catch

                end
            otherwise

            end
        end

        function addResult(this,status,nodeInfo)
            entry.status=status;
            entry.nodeInfo=nodeInfo;
            this.m_Results{end+1}=entry;
        end

        function sortResults(this)
            results=this.m_Results;

            numResults=numel(results);
            pos=zeros(numResults,2);
            for j=1:numResults
                thisResult=results{j};
                nodeInfo=thisResult.nodeInfo;
                numNodes=numel(nodeInfo);
                for k=1:numNodes
                    if iscell(thisResult)
                        thisNodeInfo=nodeInfo{k};
                    else
                        thisNodeInfo=nodeInfo(k);
                    end
                    if k==1
                        pos(j,1)=thisNodeInfo.left;
                        pos(j,2)=thisNodeInfo.right;
                    else
                        pos(j,1)=min(pos(j,1),thisNodeInfo.left);
                        pos(j,2)=min(pos(j,2),thisNodeInfo.right);
                    end
                end
            end
            [~,idx]=sortrows(pos);
            this.m_Results=results(idx);
        end

        function lineNumber=getLineNumberFromPosition(this,position)
            lineNumber=this.m_ScriptInfo.getLineNumberFromPosition(position);
        end

        function[lineStart,lineEnd]=getLinePosition(this,lineNumber)
            [lineStart,lineEnd]=this.m_ScriptInfo.getLinePosition(lineNumber);
        end

    end

    properties
        m_ModelInfo;
        m_BlockInfo;
        m_ScriptInfo;
        m_FunctionInfo;
        m_InferenceReport;
        m_IrFunctionId;
        m_CallTree;
        m_CallTreeNodes;
        m_Results;
    end

end

