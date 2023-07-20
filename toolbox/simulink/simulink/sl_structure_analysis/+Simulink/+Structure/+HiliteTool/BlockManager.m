classdef(Sealed=true)BlockManager<handle


    properties(SetAccess=private,GetAccess=public)

outPortIndex
inPortIndex
inputPorts
inputPortCount
outputPorts
outputPortCount
blockType
blockHandle
validationParams
isHiliteToSrc
isSpecialBlock
BD
isVisited

    end

    methods(Access=public)



        function obj=BlockManager(blockHandle,isHiliteToSrc,BD)

            if(~strcmpi(get_param(blockHandle,'type'),'block'))
                error(message('Simulink:HiliteTool:ExpectedBlockHandle'));
            end

            obj.blockHandle=blockHandle;
            obj.blockType=get_param(blockHandle,'BlockType');
            PortHandles=get_param(blockHandle,'PortHandles');
            obj.inputPorts=PortHandles.Inport;
            obj.inputPortCount=length(obj.inputPorts);
            obj.outputPorts=[PortHandles.Outport,PortHandles.State];
            obj.outputPortCount=length(obj.outputPorts);
            obj.outPortIndex=0;
            obj.inPortIndex=0;
            obj.isHiliteToSrc=isHiliteToSrc;
            obj.BD=BD;
            obj.isVisited=false;
            obj.isSpecialBlock=false;
            obj.resetValidationParams;

            if(~(obj.inputPortCount==0))
                obj.inPortIndex=1;
            end

            if(~(obj.outputPortCount==0))
                obj.outPortIndex=1;
            end

        end



        function resetValidationParams(obj)

            obj.validationParams=struct('isValid',false,...
            'isValidated',false,...
            'numValidPorts',0,...
            'BlockHasInternalInfo',false,...
            'validPortIndices',[]);

        end





        function validateBlock(obj,TraceManagerObj)

            isValidSplBlk=blockIsValidSpecialBlock(obj,TraceManagerObj);
            if(~obj.validationParams.isValidated)
                numports=getNumPortsInTraceDirection(obj);

                if numports~=0
                    bool=false(1,numports);
                    for j=1:numports
                        seg=getBlockSegmentInTraceDirection(obj);
                        bool(j)=isSegmentInValid(TraceManagerObj,seg,obj.BD);
                        updatePortIndexInTraceDirection(obj,1);
                    end



                    bool=~bool;
                    obj.validationParams.isValid=nnz(bool)>0;
                    obj.validationParams.numValidPorts=nnz(bool);
                    obj.validationParams.validPortIndices=bool;
                end
                obj.validationParams.isValidated=true;
            end
            hasValidIndicies=any(obj.validationParams.validPortIndices);
            obj.validationParams.isValid=hasValidIndicies||isValidSplBlk;
        end



        function validateInfoWithinBlock(obj,TraceManagerObj)

            blockHasInternalTokens=true;
            stepInGraph=getGraphForStepIn(obj.blockHandle);

            if(~isempty(stepInGraph))
                blockHasInternalTokens=isEndTokenValid(TraceManagerObj,stepInGraph);
            end

            obj.validationParams.BlockHasInternalInfo=blockHasInternalTokens;
        end



        function bool=blockIsValidSpecialBlock(obj,TraceManagerObj)

            isSplBlk=isBlockAssociatedWithDelayedAction(obj.blockHandle,...
            obj.isHiliteToSrc);

            if(isSplBlk)
                if any(strcmpi(obj.blockType,{'from','goto'}))
                    bool=TraceManagerObj.traceHasGraphicalDiscontinuities;
                elseif any(strcmpi(obj.blockType,{'inport','outport'}))
                    bool=blockHasNonEmptyParent(TraceManagerObj,obj.blockHandle);
                elseif any(strcmpi(obj.blockType,{'subsystem','modelreference'}))
                    stepInGraph=getGraphForStepIn(obj.blockHandle);
                    bool=~isempty(stepInGraph)&&...
                    stepInGraph~=TraceManagerObj.oldGraph;
                elseif any(strcmpi(obj.blockType,{'observerport','injectorinport','injectoroutport'}))
                    bool=true;
                else
                    bool=true;
                end
            else
                bool=false;
            end

            obj.isSpecialBlock=bool;
        end

    end

    methods(Access={?BlockManager,?Simulink.Structure.HiliteTool.LineTraceToken})


        function updateinPortIndex(obj,varargin)

            if(nargin==1)
                n=1;
            else
                assert(strcmpi(class(varargin{1}),'double'));
                n=varargin{1};
            end
            check=rem(obj.inPortIndex+n,obj.inputPortCount);
            if(check>0)
                obj.inPortIndex=check;
            elseif(check==0)
                obj.inPortIndex=obj.inputPortCount;
            end

        end



        function updateoutPortIndex(obj,varargin)

            if(nargin==1)
                n=1;
            else
                assert(strcmpi(class(varargin{1}),'double'));
                n=varargin{1};
            end
            check=rem(obj.outPortIndex+n,obj.outputPortCount);
            if(check>0)
                obj.outPortIndex=check;
            elseif(check==0)
                obj.outPortIndex=obj.outputPortCount;
            end

        end



        function invalidateBlock(obj)
            resetValidationParams(obj);
        end

    end

    methods(Access=public)



        function inseg=getInPortSegment(obj)
            if(obj.inputPortCount>0)
                currentPortHandle=obj.inputPorts(obj.inPortIndex);
                inseg=get_param(currentPortHandle,'line');
            else
                inseg=[];
            end
        end



        function outseg=getOutPortSegment(obj)
            if(obj.outputPortCount>0)
                currentPortHandle=obj.outputPorts(obj.outPortIndex);
                outseg=get_param(currentPortHandle,'line');
            else
                outseg=[];
            end
        end



        function out=getBlockHandle(obj)
            out=obj.blockHandle;
        end



        function bool=getIsBlkValid(obj)
            bool=obj.validationParams.isValid;
        end



        function bool=isInternalInfoAvailable(obj)
            bool=obj.validationParams.BlockHasInternalInfo;
        end



        function out=getInputPortCount(obj)
            out=obj.inputPortCount;
        end



        function out=getOutputPortCount(obj)
            out=obj.outputPortCount;
        end



        function blocktype=getBlockType(obj)
            blocktype=obj.blockType;
        end



        function nValidPorts=getNumValidPorts(obj)
            nValidPorts=0;
            if(obj.validationParams.isValidated&&obj.validationParams.numValidPorts)
                nValidPorts=obj.validationParams.numValidPorts;
            end
        end



        function numports=getNumPortsInTraceDirection(obj)

            if(obj.isHiliteToSrc)
                numports=obj.inputPortCount;
            else
                numports=obj.outputPortCount;
            end

        end



        function seg=getBlockSegmentInTraceDirection(obj)

            if(obj.isHiliteToSrc)
                seg=obj.getInPortSegment;
            else
                seg=obj.getOutPortSegment;
            end

        end



        function bool=getIsBlockSpecial(obj)
            bool=obj.isSpecialBlock;
        end


        function updatePortIndexInTraceDirection(obj,value)

            if(obj.isHiliteToSrc)
                updateinPortIndex(obj,value);
            else
                updateoutPortIndex(obj,value);
            end

        end



        function bool=isPortValidInTraceDirection(obj)

            if(obj.validationParams.isValidated&&obj.validationParams.numValidPorts)
                if(obj.isHiliteToSrc)
                    bool=obj.validationParams.validPortIndices(obj.inPortIndex);
                else
                    bool=obj.validationParams.validPortIndices(obj.outPortIndex);
                end
            else
                bool=false;
            end
        end



        function bool=isCurrentPortSmallestValidPort(obj)
            bool=false;

            if(obj.validationParams.isValidated&&obj.validationParams.numValidPorts)
                if(obj.isHiliteToSrc)
                    currentIndex=obj.inPortIndex;
                else
                    currentIndex=obj.outPortIndex;
                end
                indices=find(obj.validationParams.validPortIndices);
                if(~isempty(indices))
                    startIndex=indices(1);
                    bool=startIndex==currentIndex;
                end
            end
        end



        function bool=isCurrentPortLargestValidPort(obj)
            bool=false;

            if(obj.validationParams.isValidated&&obj.validationParams.numValidPorts)
                if(obj.isHiliteToSrc)
                    currentIndex=obj.inPortIndex;
                else
                    currentIndex=obj.outPortIndex;
                end
                indices=find(obj.validationParams.validPortIndices);
                if(~isempty(indices))
                    endIndex=indices(end);
                    bool=endIndex==currentIndex;
                end
            end
        end



        function resetToLastValidPort(obj)
            if(obj.validationParams.isValidated&&obj.validationParams.numValidPorts)
                indices=find(obj.validationParams.validPortIndices);
                if(~isempty(indices))
                    endIndex=indices(end);
                    if(obj.isHiliteToSrc)
                        obj.inPortIndex=endIndex;
                    else
                        obj.outPortIndex=endIndex;
                    end
                end
            end
        end



        function resetToFirstValidPort(obj)
            if(obj.validationParams.isValidated&&obj.validationParams.numValidPorts)
                indices=find(obj.validationParams.validPortIndices);
                if(~isempty(indices))
                    startIndex=indices(1);
                    if(obj.isHiliteToSrc)
                        obj.inPortIndex=startIndex;
                    else
                        obj.outPortIndex=startIndex;
                    end
                end
            end
        end



        function printValidationParams(obj)
            fprintf(1,'\n Block Validation Params\n');
            disp(obj.validationParams);
        end
    end
end

