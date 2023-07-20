classdef(Sealed=true)LineTraceManager<handle




    properties(Access=public)
        GlobalElements;
        GlobalElementsHistory;
        LineTraceStack;
        LineTraceStackHistory;
        isHiliteToSrc;
        traceHasGraphicalDiscontinuities;
        oldGraph;
        BDModelRefMap;
    end

    properties(Access=public)
        timeStamp;
    end



    methods(Access=public)

        function obj=LineTraceManager(isHiliteToSrc)
            obj.isHiliteToSrc=isHiliteToSrc;
            obj.LineTraceStack=containers.Map('KeyType','double','ValueType','any');
            obj.LineTraceStackHistory=containers.Map('KeyType','double','ValueType','any');
            obj.timeStamp=0;
            obj.GlobalElements=containers.Map('KeyType','double','ValueType','any');
            obj.GlobalElementsHistory=containers.Map('KeyType','double','ValueType','any');
            obj.BDModelRefMap=containers.Map('KeyType','double','ValueType','any');
            obj.traceHasGraphicalDiscontinuities=false;
        end
    end



    methods(Access=public)
        function delete(obj)

            keys=obj.LineTraceStack.keys;
            if(~isempty(keys))
                for i=1:length(keys)
                    key=keys{i};
                    TokenList=obj.LineTraceStack(key);
                    delete(TokenList);
                end
            end

        end
    end



    methods(Access=public)
        function createTokens(obj,HiliteOwner,hiliteInfos)
            incrementTraceManagerTimeStamp(obj,1);
            for i=1:length(hiliteInfos)
                hiliteInfo=hiliteInfos(i);
                push(obj,hiliteInfo,HiliteOwner);
            end
            checkIfTraceHasGraphicalDiscontinuities(obj);
        end
    end



    methods(Access=public)
        function appendTokens(obj,HiliteOwner,hiliteInfos)
            for i=1:length(hiliteInfos)
                hiliteInfo=hiliteInfos(i);
                push(obj,hiliteInfo,HiliteOwner);
            end
            checkIfTraceHasGraphicalDiscontinuities(obj);
        end
    end




    methods(Access=private)
        function incrementTraceManagerTimeStamp(obj,val)
            if(obj.timeStamp+val>0)
                obj.timeStamp=obj.timeStamp+val;
            end
        end
    end



    methods(Access=private)
        function push(obj,hiliteInfo,HiliteOwner)

            graphHandles=[hiliteInfo.graphHighlightMap{:,1}];

            for i=1:length(graphHandles)
                key=graphHandles(i);
                elements=unique(hiliteInfo.graphHighlightMap{i,2});

                if(isempty(elements)||isSubSystemAndInExclusionList(key))
                    continue;
                end

                addTokenToStack(obj,key,elements,HiliteOwner,bdroot(key))
            end

            updateGlobalElementList(obj,hiliteInfo)
        end
    end



    methods(Access=private)
        function addTokenToStack(obj,key,elements,tokenOwner,traceBD)
            import Simulink.Structure.HiliteTool.*
            token=LineTraceToken(obj.isHiliteToSrc,elements,tokenOwner,traceBD);

            if(~isKey(obj.LineTraceStack,key))
                obj.LineTraceStack(key)=token;
            else
                obj.LineTraceStack(key)=[obj.LineTraceStack(key),token];
            end






            addTokenToStackHistory(obj,key,token);
        end
    end





    methods(Access=private)
        function bool=isHiliteOwnerUnique(obj,key,Token)

            if(~isKey(obj.GlobalElements,key))
                bool=true;
            else
                globalElements=obj.GlobalElements(key);
                elements=[getBlockHandles(Token),Token.SegmentList];
                bool=~all(ismember(elements,globalElements));
            end

            if(isKey(obj.LineTraceStack,key))
                TraceTokenList=obj.LineTraceStack(key);
                ind=arrayfun(@(token)Token==token,TraceTokenList);
                bool=bool&&(~any(ind));
            end

        end
    end



    methods(Access=private)
        function addTokenToStackHistory(obj,key,tokenReference)
            import Simulink.Structure.HiliteTool.*

            if(~isKey(obj.LineTraceStackHistory,obj.timeStamp))
                currentTraceStack=containers.Map('KeyType','double',...
                'ValueType','any');
                obj.LineTraceStackHistory(obj.timeStamp)=currentTraceStack;
            else
                currentTraceStack=obj.LineTraceStackHistory(obj.timeStamp);
            end

            if(~isKey(currentTraceStack,key))
                currentTraceStack(key)=tokenReference;
            else
                currentTraceStack(key)=[currentTraceStack(key),tokenReference];
            end
            obj.LineTraceStackHistory(obj.timeStamp)=currentTraceStack;
        end
    end



    methods(Access=private)
        function updateGlobalElementList(obj,hiliteInfo)

            hiliteMap=hiliteInfo.graphHighlightMap;
            participatingGraphHandles=[hiliteMap{:,1}];

            for i=1:length(participatingGraphHandles)
                key=bdroot(hiliteMap{i,1});
                GlobalElementList=unique(hiliteMap{i,2});
                if(isKey(obj.GlobalElements,key))
                    obj.GlobalElements(key)=[obj.getGlobalElementList(key),GlobalElementList];
                else
                    obj.GlobalElements(key)=GlobalElementList;
                end
                updateGlobalElementListHistory(obj,key,GlobalElementList);
            end
        end
    end



    methods(Access=private)
        function updateGlobalElementListHistory(obj,key,GlobalElementList)

            if(~isKey(obj.GlobalElementsHistory,obj.timeStamp))
                currentElementsMap=containers.Map('KeyType','double',...
                'ValueType','any');
                obj.GlobalElementsHistory(obj.timeStamp)=currentElementsMap;
            else
                currentElementsMap=obj.GlobalElementsHistory(obj.timeStamp);
            end

            if(~isKey(currentElementsMap,key))
                currentElementsMap(key)=GlobalElementList;
            else
                currentElementsMap(key)=[currentElementsMap(key),GlobalElementList];
            end
            obj.GlobalElementsHistory(obj.timeStamp)=currentElementsMap;
        end
    end




    methods(Access=public)
        function globalElementsMap=getElementsMapForCurrentTrace(obj)

            if(isKey(obj.GlobalElementsHistory,obj.timeStamp))
                globalElementsMap=obj.GlobalElementsHistory(obj.timeStamp);
            else
                globalElementsMap=[];
            end
        end



        function graphs=getGraphsFromCurrentTimeStamp(obj)
            if(isKey(obj.LineTraceStackHistory,obj.timeStamp))
                tokenMap=obj.LineTraceStackHistory(obj.timeStamp);
                graphs=tokenMap.keys;
            else
                graphs=[];
            end
        end



        function n=getNumKeysForTokenStackInCurrentTrace(obj)
            tokenMap=obj.LineTraceStackHistory(obj.timeStamp);
            n=length(tokenMap.keys);
        end




        function[LastToken,varargout]=getEndTokens(obj,CurrentGraph)

            key=CurrentGraph;
            if(isKey(obj.LineTraceStack,key))
                TraceTokenList=obj.LineTraceStack(key);
            else
                error(message('Simulink:HiliteTool:InvalidGraphKey'));
            end

            LastToken=TraceTokenList(end);
            varargout{1}=TraceTokenList(1);

            if(length(TraceTokenList)>1)
                varargout{2}=TraceTokenList(end-1);
            else
                varargout{2}=TraceTokenList(1);
            end

        end



        function stackLen=getStackLength(obj,key)

            if(isKey(obj.LineTraceStack,key))
                TraceTokenList=obj.LineTraceStack(key);
                stackLen=numel(TraceTokenList);
            else
                stackLen=0;
            end

        end




        function GlobalElementList=getGlobalElementList(obj,CurrentBD)

            key=CurrentBD;
            if(isKey(obj.GlobalElements,key))
                GlobalElementList=obj.GlobalElements(key);
            else
                GlobalElementList=[];
            end

        end
    end



    methods(Access=public)
        function[discardedGlobalElementMap,newGlobalElementMap]=restoreTraceManagerToPrevState(obj)

            discardedGlobalElementMap=containers.Map('KeyType','double','ValueType','any');
            newGlobalElementMap=containers.Map('KeyType','double','ValueType','any');


            if(obj.timeStamp>0)
                remove(obj.LineTraceStackHistory,obj.timeStamp);

                discardedGlobalElementMap=obj.GlobalElementsHistory(obj.timeStamp);
                remove(obj.GlobalElementsHistory,obj.timeStamp);

                incrementTraceManagerTimeStamp(obj,-1);
                restoreTraceStack(obj);
                newGlobalElementMap=restoreGlobalElementMaps(obj);
            end

            checkIfTraceHasGraphicalDiscontinuities(obj);
        end
    end



    methods(Access=private)
        function restoreTraceStack(obj)
            keys=obj.LineTraceStack.keys;
            for i=1:length(keys)
                obj.LineTraceStack(keys{i})=[];
            end
            timestamps=obj.LineTraceStackHistory.keys;
            for i=1:length(timestamps)
                tokenmap=obj.LineTraceStackHistory(timestamps{i});
                keys=tokenmap.keys;
                for j=1:length(keys)
                    key=keys{j};
                    tokenList=tokenmap(key);
                    if(isKey(obj.LineTraceStack,key))
                        obj.LineTraceStack(key)=[obj.LineTraceStack(key),tokenList];
                    end
                end
            end
        end
    end



    methods(Access=private)
        function newGlobalElementMap=restoreGlobalElementMaps(obj)
            keys=obj.GlobalElements.keys;
            for i=1:length(keys)
                obj.GlobalElements(keys{i})=[];
            end
            timestamps=obj.GlobalElementsHistory.keys;
            for i=1:length(timestamps)
                elementmap=obj.GlobalElementsHistory(timestamps{i});
                keys=elementmap.keys;
                for j=1:length(keys)
                    key=keys{j};
                    elements=elementmap(key);
                    if(isKey(obj.GlobalElements,key))
                        obj.GlobalElements(key)=[obj.GlobalElements(key),elements];
                    end
                end
            end
            newGlobalElementMap=obj.GlobalElements;
        end
    end




    methods(Access=public)
        function[newToken,index]=popLineTraceStack(obj,CurrentGraph)

            key=CurrentGraph;
            if(~isKey(obj.LineTraceStack,key))
                error(message('Simulink:HiliteTool:InvalidGraphKey'));
            end

            TraceTokenList=obj.LineTraceStack(key);
            stackLength=length(TraceTokenList);

            if(stackLength>1)
                TraceTokenList(end)=[];
                obj.LineTraceStack(key)=TraceTokenList;
                index=stackLength-1;
            else
                index=1;
            end

            newToken=TraceTokenList(end);

        end
    end





    methods(Access=public)
        function foundValidToken=anyValidTokensInGraph(obj,key)
            foundValidToken=false;
            if(isKey(obj.LineTraceStack,key))
                TokenList=obj.LineTraceStack(key);
                for i=1:length(TokenList)
                    token=TokenList(i);
                    if(~isTokenValidated(token))
                        validateToken(token,obj);
                    end
                    foundValidToken=isTokenValid(token);
                    if(foundValidToken)
                        break;
                    end
                end
            end
        end
    end



    methods(Access=public)
        function bool=isEndTokenValid(obj,key)
            bool=false;
            if(isKey(obj.LineTraceStack,key))
                token=obj.getEndTokens(key);
                if(~isTokenValidated(token))
                    validateToken(token,obj);
                end
                bool=isTokenValid(token);
            end
        end
    end





    methods(Access=public)
        function isInvalid=isSegmentInValid(obj,seg,CurrentBD)

            isInvalid=true;
            if(isempty(seg)||seg==-1)
                return;
            end

            if(obj.isHiliteToSrc)
                block=get_param(seg,'DstBlockHandle');
            else
                block=get_param(seg,'SrcBlockHandle');
            end
            blockType=get_param(block,'BlockType');

            isBlockDisqualified=any(strcmpi(blockType,{'BusCreator',...
            'BusSelector',...
            'BusAssignment',...
            'VariantSource',...
            'VariantSink'}));

            if(~isBlockDisqualified)


                if(isempty(getGraphForStepIn(block)))
                    GlobalElementList=getGlobalElementList(obj,CurrentBD);
                    if(isempty(GlobalElementList))
                        isInvalid=false;
                    else
                        isInvalid=ismember(seg,GlobalElementList);
                    end
                end
            end
        end
    end



    methods(Access=private)
        function checkIfTraceHasGraphicalDiscontinuities(obj)
            obj.traceHasGraphicalDiscontinuities=false;
            elementsMap=obj.getElementsMapForCurrentTrace;
            if(isempty(elementsMap))
                return;
            end

            keys=elementsMap.keys;
            for i=1:length(keys)
                TraceBD=keys{i};
                elements=elementsMap(TraceBD);
                bool=obj.doElementsHaveGraphicalDiscontinuities(elements);
                if(bool)
                    obj.traceHasGraphicalDiscontinuities=true;
                    break;
                end
            end
        end
    end



    methods(Static,Access=private)
        function bool=doElementsHaveGraphicalDiscontinuities(elements)
            import Simulink.Structure.HiliteTool.*
            bool=false;
            coSimPortBlocks=find_system(elements,...
            'SearchDepth',0,...
            'regexp','on',...
            'BlockType','(\<ObserverPort|InjectorInport|InjectorOutport\>)');
            if(~isempty(coSimPortBlocks))
                bool=true;
                return;
            end

            goToFromBlocks=find_system(elements,...
            'SearchDepth',0,...
            'regexp','on',...
            'BlockType','(\<From\>)|(\<Goto\>)');

            if(~isempty(goToFromBlocks))
                if length(goToFromBlocks)<2










                    bool=false;
                else


                    bool=~LineTraceManager.doGoToFromBlocksBelongToSameGraph(goToFromBlocks);
                end
            end
        end
    end



    methods(Static,Access=private)
        function bool=doGoToFromBlocksBelongToSameGraph(goToFromBlocks)
            bool=true;
            tags=get_param(goToFromBlocks,'GoToTag');
            [C,~,ic]=unique(tags);
            for i=1:length(C)
                blocksWithTag=goToFromBlocks(ic==i);
                parents=get_param(blocksWithTag,'parent');
                if(~iscell(parents))
                    parents={parents};
                end
                parentHandles=get_param(parents,'handle');
                firstParent=parentHandles{1};
                sameParent=all(cellfun(@(in)in==firstParent,parentHandles));
                if(~sameParent)
                    bool=false;
                    return;
                end
            end
        end
    end



    methods(Access=public)
        function bool=doesTraceHaveGraphicalDiscontinuity(obj)
            bool=obj.traceHasGraphicalDiscontinuities;
        end
    end



    methods(Access=public)
        function setOldGraph(obj,oldGraph)
            obj.oldGraph=oldGraph;
        end
    end



    methods(Access=public)
        function bool=blockHasNonEmptyParent(obj,block)
            currentGraph=get_param(block,'Parent');
            currentGraphHandle=get_param(currentGraph,'handle');
            parentGraph=get_param(currentGraph,'Parent');
            bool=false;
            if(~isempty(parentGraph)||...
                ~isempty(getOwnerModelRefForBD(obj,currentGraphHandle)))
                bool=true;
            end

        end
    end



    methods(Access=public)
        function addBDModelRefPair(obj,childBD,ModelRefBlk)
            obj.BDModelRefMap(childBD)=ModelRefBlk;
        end
    end



    methods(Access=public)
        function owner=getOwnerModelRefForBD(obj,BD)
            if(isKey(obj.BDModelRefMap,BD))
                owner=obj.BDModelRefMap(BD);
            else


                owner=getContextFromStudioSpawningInfo(BD);
            end
        end
    end

end

