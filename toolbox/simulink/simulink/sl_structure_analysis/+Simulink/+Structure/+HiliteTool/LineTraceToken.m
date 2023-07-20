classdef(Sealed=true)LineTraceToken<handle




    properties(SetAccess=private,GetAccess=public)
        BlockList=[];
        SegmentList=[];
        TokenOwner=0;
        BlockListIndex=0;
        BlockDiagram=[];
isHiliteToSrc
        isVisited=false;


        validationParams=struct('isValid',false,...
        'isValidated',false,...
        'numValidBlocks',0,...
        'validBlockIndices',[],...
        'SpecialBlocks',[],...
        'BlocksWithInternalInfo',[]);
    end

    methods(Access={?Simulink.Structure.HiliteTool.LineTraceToken,...
        ?Simulink.Structure.HiliteTool.LineTraceManager,...
        ?Simulink.Structure.HiliteTool.HiliteTree})



        function TokenObj=LineTraceToken(isHiliteToSrc,elements,TokenOwner,BlockDiagram)

            TokenObj.isHiliteToSrc=isHiliteToSrc;
            TokenObj.BlockDiagram=BlockDiagram;
            TokenObj.TokenOwner=TokenOwner;

            for i=1:length(elements)
                elemHandle=elements(i);
                elemType=get_param(elemHandle,'type');
                switch(elemType)
                case('line')
                    TokenObj.SegmentList=[TokenObj.SegmentList,elemHandle];
                case('block')
                    block=Simulink.Structure.HiliteTool.BlockManager(elemHandle,isHiliteToSrc,BlockDiagram);
                    TokenObj.BlockList=[TokenObj.BlockList,block];
                otherwise
                    error(message('Simulink:HiliteTool:LineTraceTokenInvalidElement'));
                end
            end

            if(~isempty(TokenObj.BlockList))
                updateBlockListIndex(TokenObj,1);
                sortBlocksForVisualOrdering(TokenObj);
            end

        end



        function sortBlocksForVisualOrdering(TokenObj)
            if(length(TokenObj.BlockList)>1)
                blockHandles=getBlockHandles(TokenObj);
                positions=get_param(blockHandles,'Position');
                if(~iscell(positions))
                    positions=mat2cell(positions);
                end
                verticalPos=cellfun(@(in)in(2),positions);
                [~,sortedInd]=sort(verticalPos);
                TokenObj.BlockList=TokenObj.BlockList(sortedInd);
                moveIndexToActiveVariant(TokenObj);
            end
        end



        function moveIndexToActiveVariant(TokenObj)
            sampleBlock=TokenObj.BlockList(1);
            block=getBlockHandle(sampleBlock);
            parent=get_param(get_param(block,'Parent'),'handle');
            isParentVariant=isSubSystemAndNotInExclusionList(parent)&&...
            strcmpi(get_param(parent,'Variant'),'on');
            if(isParentVariant)
                activeVariantName=get_param(parent,'ActiveVariantBlock');
                if(~isempty(activeVariantName))
                    activeVariant=get_param(activeVariantName,'handle');
                    blockHandles=getBlockHandles(TokenObj);
                    ind=find(blockHandles==activeVariant);
                    if(~isempty(ind))
                        TokenObj.BlockListIndex=ind;
                    end
                end
            end
        end



        function updateBlockListIndex(TokenObj,varargin)

            narginchk(1,2)
            if(nargin==1)
                n=1;
            else
                n=varargin{1};
            end
            N=length(TokenObj.BlockList);
            check=rem(TokenObj.BlockListIndex+n,N);
            if(check>0)
                TokenObj.BlockListIndex=check;
            elseif(check==0)
                TokenObj.BlockListIndex=N;
            end

        end



        function updatePortToggle(TokenObj,value)

            block=getActiveBlock(TokenObj);
            if(isempty(block))
                return;
            end

            updatePortIndexInTraceDirection(block,value);

        end





        function validateToken(TokenObj,traceManagerHandle)

            blocksValidationStruct=...
            validateAllBlocksInToken(TokenObj,traceManagerHandle);

            SpecialBlocks=blocksValidationStruct.SpecialBlocks;
            BlocksWithInternalInfo=blocksValidationStruct.BlocksWithInternalInfo;
            validBlockIndices=blocksValidationStruct.validBlockIndices;

            isTokenValid=numel(validBlockIndices);
            TokenObj.validationParams.isValid=isTokenValid;
            TokenObj.validationParams.isValidated=true;
            TokenObj.validationParams.numValidBlocks=numel(validBlockIndices);
            TokenObj.validationParams.validBlockIndices=validBlockIndices;
            TokenObj.validationParams.SpecialBlocks=SpecialBlocks;
            TokenObj.validationParams.BlocksWithInternalInfo=BlocksWithInternalInfo;

        end



        function blocksValidationStruct=validateAllBlocksInToken(TokenObj,traceManagerHandle)

            assert(isa(traceManagerHandle,'Simulink.Structure.HiliteTool.LineTraceManager'));

            blocksValidationStruct=struct('validBlockIndices',[],...
            'SpecialBlocks',[],...
            'BlocksWithInternalInfo',[]);

            if(isempty(TokenObj.BlockList))
                return;
            end

            blockValidity=true(length(TokenObj.BlockList),1);
            validBlockIndices=[];
            SpecialBlocks=[];
            BlocksWithInternalInfo=[];

            for i=1:length(TokenObj.BlockList)

                validateActiveTokenBlock(TokenObj,traceManagerHandle);

                block=getActiveBlock(TokenObj);
                blockIsSpl=getIsBlockSpecial(block);
                blockHasInfo=isInternalInfoAvailable(block);
                BlocksWithInternalInfo=[BlocksWithInternalInfo...
                ,blockHasInfo];

                SpecialBlocks=[SpecialBlocks,blockIsSpl];

                blkIsValid=isActiveBlockValid(TokenObj);
                if(blkIsValid)
                    validBlockIndices=[validBlockIndices...
                    ,TokenObj.BlockListIndex];
                end
                blockValidity(i)=blkIsValid;
                updateBlockListIndex(TokenObj);
            end

            blocksValidationStruct.validBlockIndices=validBlockIndices;
            blocksValidationStruct.SpecialBlocks=SpecialBlocks;
            blocksValidationStruct.BlocksWithInternalInfo=BlocksWithInternalInfo;
        end




        function validateActiveTokenBlock(TokenObj,traceManagerHandle)

            block=getActiveBlock(TokenObj);

            if(~isempty(block))
                validateBlock(block,traceManagerHandle);
            end

        end



        function invalidateActiveTokenBlock(TokenObj)

            block=getActiveBlock(TokenObj);
            if(~isempty(block))
                invalidateBlock(block);
            end

        end



        function bool=infoAvailableInsideToken(TokenObj,traceOpt)

            bool=false;
            i=1;
            while(i<=length(TokenObj.BlockList)&&~bool)
                bool=checkInfoWithinCurrentBlock(TokenObj,traceOpt);
                if bool


                    return
                end
                TokenObj.updateBlockListIndex;
                i=i+1;
            end

        end
    end


    methods(Access=public)



        function bool=eq(Token1,Token2)

            assert(isa(Token1,'Simulink.Structure.HiliteTool.LineTraceToken'))
            assert(isa(Token2,'Simulink.Structure.HiliteTool.LineTraceToken'))

            if(~isempty(Token1.BlockList))
                token1BlockHandles=getBlockHandles(Token1);
            else
                token1BlockHandles=0;
            end

            if(~isempty(Token2.BlockList))
                token2BlockHandles=getBlockHandles(Token2);
            else
                token2BlockHandles=0;
            end

            bool_blocks=all(ismember(token1BlockHandles,token2BlockHandles))&&...
            length(Token1.BlockList)==length(Token2.BlockList);

            bool_segs=all(ismember(Token1.SegmentList,Token2.SegmentList))&&...
            length(Token1.SegmentList)==length(Token2.SegmentList);

            bool=bool_blocks&&bool_segs;

        end



        function seg=getActiveBlockSegment(TokenObj)

            block=getActiveBlock(TokenObj);

            if(isempty(block))
                seg=[];
                return;
            end

            seg=getBlockSegmentInTraceDirection(block);

        end



        function block=getActiveBlock(TokenObj)
            if(~isempty(TokenObj.BlockList))
                block=TokenObj.BlockList(TokenObj.BlockListIndex);
            else
                block=[];
            end
        end



        function numports=getNumPortsForActiveBlock(TokenObj)

            block=getActiveBlock(TokenObj);
            if(isempty(block))
                numports=[];
                return
            end

            numports=getNumPortsInTraceDirection(block);

        end



        function numports=getNumValidPortsForActiveBlock(TokenObj)

            block=getActiveBlock(TokenObj);
            if(isempty(block))
                numports=[];
                return
            end

            numports=getNumValidPorts(block);

        end




        function bool=isActiveBlockValid(TokenObj)
            block=getActiveBlock(TokenObj);
            if(~isempty(block))
                bool=getIsBlkValid(block);
            else
                bool=false;
            end
        end



        function bool=doesActiveBlockHaveValidInternalTokens(TokenObj)
            block=getActiveBlock(TokenObj);
            if(~isempty(block))
                bool=isInternalInfoAvailable(block);
            else
                bool=false;
            end
        end



        function num=getNumBlocks(TokenObj)
            num=numel(TokenObj.BlockList);
        end



        function num=getNumValidBlocks(TokenObj)
            num=TokenObj.validationParams.numValidBlocks;
        end



        function blockHandles=getValidBlockHandles(TokenObj)
            if(~isempty(TokenObj.BlockList))
                blockHandles=[TokenObj.BlockList.blockHandle];
                ind=TokenObj.validationParams.validBlockIndices;
                blockHandles=blockHandles(ind);
            else
                blockHandles=[];
            end
        end



        function blockHandles=getBlockHandles(TokenObj)
            if(~isempty(TokenObj.BlockList))
                blockHandles=[TokenObj.BlockList.blockHandle];
            else
                blockHandles=[];
            end
        end



        function owner=getTokenOwner(TokenObj)
            owner=TokenObj.TokenOwner;
        end



        function bool=isTokenOwnerModelRef(TokenObj)
            bool=isBlockNonProtectedModelRef(TokenObj.TokenOwner);
        end



        function bool=isTokenValid(TokenObj)
            bool=TokenObj.validationParams.isValid;
        end



        function bool=isTokenValidated(TokenObj)
            bool=TokenObj.validationParams.isValidated;
        end



        function bool=hasTokenBeenVisited(TokenObj)
            bool=TokenObj.isVisited;
        end



        function segs=getSegmentList(TokenObj)
            segs=TokenObj.SegmentList;
        end


        function bool=isCurrentSegmentValid(TokenObj)
            block=getActiveBlock(TokenObj);
            if(~isempty(block))
                bool=isPortValidInTraceDirection(block);
            else
                bool=false;
            end
        end



        function bool=isTokenStateValid(TokenObj)

            bool=isCurrentSegmentValid(TokenObj);

        end



        function bool=isActiveSplTokenBlockTerminal(TokenObj,prevGraph)
            bool=false;
            block=getActiveBlock(TokenObj);
            if any(strcmpi(block.blockType,{'modelreference','subsystem'}))
                stepInGraph=getGraphForStepIn(block.blockHandle);
                bool=stepInGraph==prevGraph&&...
                (TokenObj.validationParams.numValidBlocks==1);
            end
        end

    end


    methods(Access={?Simulink.Structure.HiliteTool.LineTraceToken,...
        ?Simulink.Structure.HiliteTool.LineTraceManager,...
        ?Simulink.Structure.HiliteTool.HiliteTree})



        function setIsBlkValid(TokenObj,bool)
            assert(islogical(bool));
            block=getActiveBlock(TokenObj);
            if(~isempty(block))
                setIsBlkValid(block,bool);
            end
        end



        function invalidateToken(TokenObj)
            TokenObj.validationParams=struct('isValid',false,...
            'isValidated',false,...
            'numValidBlocks',0,...
            'validBlockIndices',[]);
            invalidateAllTokenBlocks(TokenObj);
        end



        function invalidateAllTokenBlocks(TokenObj)
            for i=1:length(TokenObj.BlockList)
                invalidateActiveTokenBlock(TokenObj);
                updateBlockListIndex(TokenObj);
            end
        end



        function invalidateActiveBlock(TokenObj)
            block=getActiveBlock(TokenObj);
            if(~isempty(block))
                invalidateBlock(block);
            end
        end



        function setCurrentBlock(TokenObj,index)

            assert(isa(index,'double'));
            assert(index>0&&index<=length(TokenObj.BlockList));
            TokenObj.BlockListIndex=index;

        end



        function bool=isActiveTokenBlockFirstValidBlock(TokenObj)
            bool=false;
            if(TokenObj.validationParams.isValidated)
                indices=TokenObj.validationParams.validBlockIndices;
                if(~isempty(indices))
                    bool=TokenObj.BlockListIndex==indices(1);
                end
            end
        end



        function bool=isActiveTokenBlockLastValidBlock(TokenObj)
            bool=false;
            if(TokenObj.validationParams.isValidated)
                indices=TokenObj.validationParams.validBlockIndices;
                if(~isempty(indices))
                    bool=TokenObj.BlockListIndex==indices(end);
                end
            end
        end



        function resetToFirstValidBlock(TokenObj)
            if(TokenObj.validationParams.isValidated)
                indices=TokenObj.validationParams.validBlockIndices;
                if(~isempty(indices))
                    TokenObj.BlockListIndex=indices(1);
                end
            end
        end



        function resetToLastValidBlock(TokenObj)
            if(TokenObj.validationParams.isValidated)
                indices=TokenObj.validationParams.validBlockIndices;
                if(~isempty(indices))
                    TokenObj.BlockListIndex=indices(end);
                end
            end
        end



        function bool=isActiveBlockSpecial(TokenObj)
            bool=false;
            if(TokenObj.validationParams.isValidated)
                block=getActiveBlock(TokenObj);
                if(~isempty(block))
                    bool=getIsBlockSpecial(block);
                end
            end
        end




        function printValidationParams(obj)
            fprintf(1,'\n TOKEN Validation Params\n');
            disp(obj.validationParams);
        end



        function markAsVisited(TokenObj)
            TokenObj.isVisited=true;
        end



        function markAsToVisit(TokenObj)
            TokenObj.isVisited=false;
        end


    end
end

